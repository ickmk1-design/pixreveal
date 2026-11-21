"""Promote PixReveal vc32 production release from draft → completed, commit, verify."""
import sys, io, json
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from google.oauth2 import service_account
from googleapiclient.discovery import build

SA  = r"C:\Users\ickmk\Desktop\projeler-claude\galeripost\google-service-account.json"
PKG = "com.cytbilisim.pixreveal"
VC  = 32

creds = service_account.Credentials.from_service_account_file(
    SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)

# 1) Fresh edit
edit = svc.edits().insert(packageName=PKG, body={}).execute()
EID = edit['id']
print(f"edit id: {EID}")

# 2) Read current prod track so we can carry over release notes + name
tr = svc.edits().tracks().get(packageName=PKG, editId=EID, track='production').execute()
target = None
for rel in tr.get('releases', []):
    if str(VC) in (rel.get('versionCodes') or []):
        target = rel
        break
if target is None:
    print(f"no release with vc={VC} found in production track; tracks state:")
    print(json.dumps(tr, indent=2)[:1500])
    raise SystemExit(1)

print(f"before: status={target.get('status')}  userFraction={target.get('userFraction')}  name={target.get('name')}")

# 3) Build the new release object: status=completed, drop userFraction (full rollout)
new_release = {
    "name": target.get("name"),
    "status": "completed",
    "versionCodes": target.get("versionCodes"),
    "releaseNotes": target.get("releaseNotes", []),
}

# A completed release supersedes the previous completed release, so we send
# only the new vc32 release in the body. Including vc31 (also completed) alongside
# triggers "Only one completed release is allowed." (HTTP 400).
body = {"track": "production", "releases": [new_release]}

updated = svc.edits().tracks().update(
    packageName=PKG, editId=EID, track='production', body=body
).execute()
print("track updated (pre-commit):")
for r in updated.get('releases', []):
    print(f"  vc={r.get('versionCodes')}  status={r.get('status')}  userFraction={r.get('userFraction')}  name={r.get('name')}")

# 4) Commit the edit → this is what sends the release to review
commit = svc.edits().commit(packageName=PKG, editId=EID).execute()
print(f"COMMITTED: {commit.get('id')}")

# 5) Re-read track in a fresh edit to prove it stuck
edit2 = svc.edits().insert(packageName=PKG, body={}).execute()
try:
    tr2 = svc.edits().tracks().get(packageName=PKG, editId=edit2['id'], track='production').execute()
    print("post-commit production track:")
    for r in tr2.get('releases', []):
        print(f"  vc={r.get('versionCodes')}  status={r.get('status')}  userFraction={r.get('userFraction')}  name={r.get('name')}")
finally:
    svc.edits().delete(packageName=PKG, editId=edit2['id']).execute()
