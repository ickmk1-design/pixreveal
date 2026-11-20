"""Download PixReveal vc31 generated universal APK from Play."""
import sys, io, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
import urllib.request
from google.oauth2 import service_account
from googleapiclient.discovery import build

SA = r'C:\Users\ickmk\desktop\projeler-claude\galeripost\google-service-account.json'
PKG = 'com.cytbilisim.pixreveal'
VC = 31
OUT = r'C:\Users\ickmk\Desktop\projeler-claude\pixreveal\scripts\pixreveal_vc31.apk'

creds = service_account.Credentials.from_service_account_file(
    SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)

# List generated APKs for versionCode 31
print(f"Listing generated apks for {PKG} vc={VC} ...")
res = svc.generatedapks().list(packageName=PKG, versionCode=VC).execute()
print(f"Response keys: {list(res.keys())}")
print(f"generatedApks: {len(res.get('generatedApks', []))}")
import json
with open(r'C:\Users\ickmk\Desktop\projeler-claude\pixreveal\scripts\_vc31_apks.json', 'w', encoding='utf-8') as f:
    json.dump(res, f, indent=2)
# Dump universal APK + arm64/x86_64 splits only
for ga in res.get('generatedApks', []):
    if ga.get('generatedUniversalApk'):
        print("UNIVERSAL:", ga['generatedUniversalApk'])
    for sp in ga.get('generatedSplitApks', []):
        sid = sp.get('splitId', '')
        if not sid or 'arm64' in sid or 'x86_64' in sid or sid.startswith('config.en') or sid == '':
            print(f"  variant={sp.get('variantId')} module={sp.get('moduleName')} splitId={sid!r} downloadId={sp.get('downloadId')}")
    print("---")
    print("assetSliceSet count:", len(ga.get('generatedAssetPackSlices', [])))
