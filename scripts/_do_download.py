"""Download the universal APK for vc31."""
import sys, io, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

SA = r'C:\Users\ickmk\desktop\projeler-claude\galeripost\google-service-account.json'
PKG = 'com.cytbilisim.pixreveal'
VC = 31
OUT = r'C:\Users\ickmk\Desktop\projeler-claude\pixreveal\scripts\pixreveal_vc31_universal.apk'
DOWNLOAD_ID = 'MTs1ODo4Qjo4RTo2Qzo0MjpCMjpBODo5Njo0MToxQjo4NTpEQjowQjo3RDpFODoxMjoxMDpFNTo1RjoxQToyRjo4RjpCMjoyNjpEMjpBOTpDNTozQTpEOTo4Mjo3RToxMTt1bml2ZXJzYWw='

creds = service_account.Credentials.from_service_account_file(
    SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)

req = svc.generatedapks().download_media(
    packageName=PKG, versionCode=VC, downloadId=DOWNLOAD_ID)

with open(OUT, 'wb') as f:
    dl = MediaIoBaseDownload(f, req, chunksize=4 * 1024 * 1024)
    done = False
    while not done:
        status, done = dl.next_chunk(num_retries=3)
        if status:
            print(f"  {int(status.progress() * 100)}%")
print(f"saved: {OUT}  size: {os.path.getsize(OUT)} bytes")
