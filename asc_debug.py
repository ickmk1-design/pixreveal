"""Debug - mevcut IAP yapısını gör"""
import sys, time, requests
import jwt as pyjwt
from pathlib import Path

KEY_ID    = "YF3T88XKW5"
ISSUER_ID = "37ca6f84-e761-49dd-9577-aa0e349a5953"
APP_ID    = "6784971749"
KEY_FILE  = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE      = "https://api.appstoreconnect.apple.com/v1"

def token():
    pk = KEY_FILE.read_text()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now+900, "aud": "appstoreconnect-v1"}
    return pyjwt.encode(payload, pk, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"})

def hdr():
    return {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}

def get(path, params=None):
    r = requests.get(f"{BASE}{path}", headers=hdr(), params=params, timeout=30)
    if not r.ok:
        print(f"  {r.status_code}: {r.text[:600]}")
        return {}
    return r.json()

# Uygulamayı doğrula
print("=== App info ===")
app = get(f"/apps/{APP_ID}", {"fields[apps]": "name,bundleId"})
print(app.get("data", {}).get("attributes", {}))

# IAP v2 listesi - fields olmadan
print("\n=== IAP v2 (fields yok) ===")
iaps = get(f"/apps/{APP_ID}/inAppPurchasesV2", {"limit": 50})
for d in iaps.get("data", []):
    print(f"  {d['id']}  {d['attributes']}")

# Subscription groups
print("\n=== Subscription Groups ===")
grps = get(f"/apps/{APP_ID}/subscriptionGroups")
for g in grps.get("data", []):
    gid = g["id"]
    print(f"  {gid}  {g['attributes']}")
    subs = get(f"/subscriptionGroups/{gid}/subscriptions", {"fields[subscriptions]": "productId,name,state,subscriptionPeriod"})
    for s in subs.get("data", []):
        print(f"    sub: {s['attributes']}")

# App Store Versions
print("\n=== App Store Versions ===")
vers = get(f"/apps/{APP_ID}/appStoreVersions", {"filter[platform]": "IOS", "limit": 5})
for v in vers.get("data", []):
    print(f"  {v['id']}  {v['attributes']['versionString']}  {v['attributes']['appStoreState']}")
