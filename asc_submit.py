"""Subscription submit + token pack submit + version resubmit"""
import os, time, requests
import jwt as pyjwt
from pathlib import Path

KEY_ID    = "YF3T88XKW5"
ISSUER_ID = "37ca6f84-e761-49dd-9577-aa0e349a5953"
KEY_FILE  = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE      = "https://api.appstoreconnect.apple.com/v1"
os.environ["PYTHONIOENCODING"] = "utf-8"

MONTHLY_ID = "6784972491"
YEARLY_ID  = "6784972888"
VERSION_ID = "aa153be0-e036-422b-ab7e-293556c2a82e"
TOKEN_PACK_IDS = ["6784972364", "6784972806", "6784972613", "6784972807", "6784972484"]

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
        print(f"  GET {r.status_code}: {r.text[:400]}")
        return {}
    return r.json()

def post(path, body, label=""):
    r = requests.post(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.status_code in (200, 201)
    msg = "OK" if ok else r.text[:500]
    print(f"  POST {label} {r.status_code}: {msg}")
    return r.json() if (r.text and ok) else None

# 1. Subscription price detayı
print("=== Price detay ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    prices = get(f"/subscriptions/{sid}/prices",
                 {"include": "subscriptionPricePoint,territory",
                  "fields[subscriptionPricePoints]": "customerPrice,territory"})
    for p in prices.get("data", []):
        print(f"  {name} price id={p['id']} attrs={p['attributes']}")
        # included price point
    for inc in prices.get("included", []):
        print(f"    included: {inc['type']} attrs={inc['attributes']}")

# 2. Subscription submit dene
print("\n=== Sub submit ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    post("/subscriptionSubmissions", {"data": {
        "type": "subscriptionSubmissions",
        "relationships": {
            "subscription": {"data": {"type": "subscriptions", "id": sid}}
        }
    }}, label=f"sub-{name}")

# 3. Token pack submit dene (v2 format)
print("\n=== Token pack submit ===")
for iap_id in TOKEN_PACK_IDS:
    # Try inAppPurchaseV2 relationship (not inAppPurchase)
    post("/inAppPurchaseSubmissions", {"data": {
        "type": "inAppPurchaseSubmissions",
        "relationships": {
            "inAppPurchaseV2": {"data": {"type": "inAppPurchasesV2", "id": iap_id}}
        }
    }}, label=f"token-{iap_id}")

# 4. Version mevcut submission bul
print("\n=== Version submission durumu ===")
ver_subs = get(f"/appStoreVersions/{VERSION_ID}/appStoreVersionSubmission")
print(f"  {ver_subs.get('data', {})}")

# 5. Yeni versiyon submission yolu — version'ı PREPARE_FOR_SUBMISSION'a al
# REJECTED → delete current submission → PREPARE_FOR_SUBMISSION → submit again
sub_data = ver_subs.get("data")
if sub_data:
    sub_id = sub_data["id"]
    print(f"\n  Mevcut submission: {sub_id}")
    print("  DELETE ile PREPARE_FOR_SUBMISSION'a getiriliyor...")
    r = requests.delete(f"{BASE}/appStoreVersionSubmissions/{sub_id}",
                        headers=hdr(), timeout=30)
    print(f"  DELETE {r.status_code}: {r.text[:200] if r.text else 'OK'}")

    # State güncellenmesini bekle
    time.sleep(3)
    ver = get(f"/appStoreVersions/{VERSION_ID}", {"fields[appStoreVersions]": "appStoreState"})
    new_state = ver.get("data", {}).get("attributes", {}).get("appStoreState")
    print(f"  Yeni version state: {new_state}")

    if new_state in ("PREPARE_FOR_SUBMISSION",):
        print("  Yeniden submit ediliyor...")
        post("/appStoreVersionSubmissions", {"data": {
            "type": "appStoreVersionSubmissions",
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
            }
        }}, label="version-resubmit")
else:
    print("  Mevcut submission yok, direkt submit...")
    post("/appStoreVersionSubmissions", {"data": {
        "type": "appStoreVersionSubmissions",
        "relationships": {
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
        }
    }}, label="version-submit")

print("\n=== Final durum ===")
ver = get(f"/appStoreVersions/{VERSION_ID}", {"fields[appStoreVersions]": "appStoreState,versionString"})
print(f"  Version: {ver.get('data', {}).get('attributes', {})}")
