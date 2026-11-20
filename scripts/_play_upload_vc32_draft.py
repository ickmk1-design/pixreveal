"""Upload PixReveal vc32 AAB to Play production as DRAFT (no rollout)."""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SA = r'C:\Users\ickmk\desktop\projeler-claude\galeripost\google-service-account.json'
PKG = 'com.cytbilisim.pixreveal'
AAB = r'C:\Users\ickmk\Desktop\projeler-claude\pixreveal\mobile\build\app\outputs\bundle\release\app-release.aab'
TRACK = 'production'

RELEASE_NOTES_TR = (
    "1.0.4'te neler yeni:\n"
    "- Acilista donma (ANR) hatasi duzeltildi\n"
    "- Agir servisler (reklam, satin alma, ses) artik ilk ekran cizildikten\n"
    "  sonra baslatilir, oyun aninda aciliyor"
)
RELEASE_NOTES_EN = (
    "What's new in 1.0.4:\n"
    "- Fixed startup freeze (ANR) on cold launch\n"
    "- Heavy services (ads, purchases, audio) now initialize after the first\n"
    "  frame is drawn, so the app opens instantly"
)

creds = service_account.Credentials.from_service_account_file(
    SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)

edit = svc.edits().insert(packageName=PKG, body={}).execute()
EDIT = edit['id']
print(f"edit id: {EDIT}")

media = MediaFileUpload(AAB, mimetype='application/octet-stream',
                       resumable=True, chunksize=4 * 1024 * 1024)
req = svc.edits().bundles().upload(packageName=PKG, editId=EDIT, media_body=media)
resp = None
while resp is None:
    try:
        status, resp = req.next_chunk(num_retries=3)
        if status:
            print(f"  upload {int(status.progress()*100)}%")
    except Exception as e:
        print(f"  chunk error: {e} - retrying")
vc = resp['versionCode']
print(f"uploaded AAB - versionCode: {vc}")

# IMPORTANT: status='draft' (not 'completed') — Play Console shows it as a
# saved draft; user must manually click 'Submit for review' / rollout.
track = svc.edits().tracks().update(
    packageName=PKG, editId=EDIT, track=TRACK,
    body={'track': TRACK, 'releases': [{
        'name': f'1.0.4 (build {vc})',
        'status': 'draft',
        'versionCodes': [str(vc)],
        'releaseNotes': [
            {'language': 'en-US', 'text': RELEASE_NOTES_EN},
            {'language': 'tr-TR', 'text': RELEASE_NOTES_TR},
        ],
    }]}).execute()
print(f"track updated: {track.get('track')} - releases: {len(track.get('releases',[]))}")
print(f"release status: {track.get('releases',[{}])[0].get('status')}")

commit = svc.edits().commit(packageName=PKG, editId=EDIT).execute()
print(f"COMMITTED (draft saved): editId={commit.get('id')}")
print("NO ROLLOUT — status=draft. User must click 'Review and release' in Play Console.")
