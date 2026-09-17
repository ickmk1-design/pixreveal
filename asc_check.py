"""Subscription mevcut durumunu detaylı gör"""
import os, time, requests
import jwt as pyjwt
from pathlib import Path

KEY_ID    = "YF3T88XKW5"
ISSUER_ID = "37ca6f84-e761-49dd-9577-aa0e349a5953"
KEY_FILE  = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE      = "https://api.appstoreconnect.apple.com/v1"
os.environ["PYTHONIOENCODING"] = "utf-8"

MONTHLY_ID   = "6784972491"
YEARLY_ID    = "6784972888"
SUB_GROUP_ID = "22192173"
VERSION_ID   = "aa153be0-e036-422b-ab7e-293556c2a82e"

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
        print(f"  {r.status_code}: {r.text[:300]}")
        return {}
    return r.json()

def post(path, body):
    r = requests.post(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.status_code in (200, 201)
    print(f"  POST {r.status_code}: {r.text[:400] if not ok else 'OK'}")
    return r.json() if (r.text and ok) else None

# Tüm sub detayları
for sid, name in [(MONTHLY_ID, "MONTHLY"), (YEARLY_ID, "YEARLY")]:
    print(f"\n=== {name} subscription detay ===")
    r = get(f"/subscriptions/{sid}")
    print(f"  attrs: {r.get('data', {}).get('attributes', {})}")

    prices = get(f"/subscriptions/{sid}/prices")
    print(f"  prices ({len(prices.get('data', []))}): {[p['attributes'] for p in prices.get('data', [])]}")

    locs = get(f"/subscriptions/{sid}/subscriptionLocalizations",
               {"fields[subscriptionLocalizations]": "locale,name,state"})
    print(f"  localizations: {[l['attributes'] for l in locs.get('data', [])]}")

    av = get(f"/subscriptions/{sid}/subscriptionAvailability",
             {"fields[subscriptionAvailabilities]": "availableInNewTerritories"})
    print(f"  availability: {av.get('data', {}).get('attributes', {})}")

# Subscription group localization
print("\n=== Sub Group localizations ===")
gl = get(f"/subscriptionGroups/{SUB_GROUP_ID}/subscriptionGroupLocalizations",
         {"fields[subscriptionGroupLocalizations]": "locale,name,state"})
print(f"  {[l['attributes'] for l in gl.get('data', [])]}")

# Grup locale yoksa ekle
if not gl.get("data"):
    print("  Grup locale yok — ekleniyor...")
    post("/subscriptionGroupLocalizations", {"data": {
        "type": "subscriptionGroupLocalizations",
        "attributes": {"locale": "en-US", "name": "PixReveal Premium"},
        "relationships": {
            "subscriptionGroup": {"data": {"type": "subscriptionGroups", "id": SUB_GROUP_ID}}
        }
    }})
    post("/subscriptionGroupLocalizations", {"data": {
        "type": "subscriptionGroupLocalizations",
        "attributes": {"locale": "tr", "name": "PixReveal Premium"},
        "relationships": {
            "subscriptionGroup": {"data": {"type": "subscriptionGroups", "id": SUB_GROUP_ID}}
        }
    }})

# Yıllık için $39.99 fiyat noktasını geniş arama ile bul
print("\n=== YEARLY price point genis arama ===")
all_pts = []
cursor = None
while True:
    params = {"filter[territory]": "USA", "limit": 200}
    if cursor:
        params["cursor"] = cursor
    resp = get(f"/subscriptions/{YEARLY_ID}/pricePoints", params)
    data = resp.get("data", [])
    all_pts.extend(data)
    nxt = resp.get("links", {}).get("next")
    if not nxt:
        break
    import re
    m = re.search(r"cursor=([^&]+)", nxt)
    if not m:
        break
    cursor = m.group(1)

prices_available = sorted(
    [(float(pp["attributes"].get("customerPrice", 0)), pp["id"]) for pp in all_pts],
    key=lambda x: x[0]
)
near_40 = [(p, i) for p, i in prices_available if 30 <= p <= 50]
print(f"  $30-50 arasi: {[(p, i[:20]) for p, i in near_40]}")

# $39.99 veya en yakın $39.99 üstü fiyatı set et
targets = [39.99, 49.99, 34.99]
for target in targets:
    match = next(((p, i) for p, i in near_40 if abs(p - target) < 0.01), None)
    if match:
        price_val, pp_id = match
        print(f"  ${price_val} price point bulundu, set ediliyor...")
        post("/subscriptionPrices", {"data": {
            "type": "subscriptionPrices",
            "attributes": {"preserveCurrentPrice": False},
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": YEARLY_ID}},
                "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
            }
        }})
        break

# Son durum
print("\n=== Son durum ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    r = get(f"/subscriptions/{sid}", {"fields[subscriptions]": "state,productId"})
    print(f"  {name}: {r.get('data', {}).get('attributes', {})}")

# Version
ver = get(f"/appStoreVersions/{VERSION_ID}", {"fields[appStoreVersions]": "appStoreState,versionString"})
print(f"\n  Version: {ver.get('data', {}).get('attributes', {})}")
