"""Subscription availability + doğru price point ile fiyat set"""
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
SUB_GROUP_ID = "22192173"

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
        print(f"  GET {r.status_code}: {r.text[:300]}")
        return {}
    return r.json()

def post(path, body):
    r = requests.post(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.status_code in (200, 201)
    print(f"  POST {r.status_code}: {r.text[:400] if not ok else 'OK'}")
    return r.json() if (r.text and ok) else None

def patch(path, body):
    r = requests.patch(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.status_code in (200, 201)
    print(f"  PATCH {r.status_code}: {r.text[:400] if not ok else 'OK'}")
    return r.json() if (r.text and ok) else None

# 1. Availability kontrol
print("=== Availability ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    av = get(f"/subscriptions/{sid}/subscriptionAvailability")
    print(f"  {name}: {av.get('data', {}).get('attributes', 'NOT SET')}")

# 2. Availability yoksa oluştur (availableInAllTerritories: true)
print("\n=== Availability set ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    av = get(f"/subscriptions/{sid}/subscriptionAvailability")
    av_data = av.get("data")
    if av_data:
        avid = av_data["id"]
        print(f"  {name}: mevcut availability var id={avid}, patch ediliyor")
        patch(f"/subscriptionAvailabilities/{avid}", {"data": {
            "type": "subscriptionAvailabilities",
            "id": avid,
            "attributes": {"availableInNewTerritories": True},
        }})
    else:
        print(f"  {name}: availability yok, olusturuluyor")
        post("/subscriptionAvailabilities", {"data": {
            "type": "subscriptionAvailabilities",
            "attributes": {"availableInNewTerritories": True},
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": sid}},
                "availableTerritories": {"data": []}  # bos = all territories
            }
        }})

# 3. Price point listesi (fields olmadan)
print("\n=== Price points ===")
for sid, name, target in [(MONTHLY_ID, "monthly", "4.99"), (YEARLY_ID, "yearly", "39.99")]:
    pts = get(f"/subscriptions/{sid}/pricePoints",
              {"filter[territory]": "USA", "limit": 200})
    found = []
    for pp in pts.get("data", []):
        cp = pp["attributes"].get("customerPrice")
        if cp == target or (target == "39.99" and cp in ("39.99", "34.99", "49.99")):
            found.append((cp, pp["id"]))
    print(f"  {name} yakın fiyatlar: {found}")

# 4. Fiyat POST (tam attributes ile)
print("\n=== Price POST (tam) ===")
for sid, name, target in [(MONTHLY_ID, "monthly", "4.99"), (YEARLY_ID, "yearly", "39.99")]:
    pts = get(f"/subscriptions/{sid}/pricePoints",
              {"filter[territory]": "USA", "limit": 200})
    candidates = [(float(pp["attributes"].get("customerPrice", 0)), pp["id"])
                  for pp in pts.get("data", [])]
    # En yakın fiyatı bul
    target_f = float(target)
    best = min(candidates, key=lambda x: abs(x[0] - target_f), default=(None, None))
    if not best[1]:
        print(f"  {name}: price point yok")
        continue
    best_price, pp_id = best
    print(f"  {name}: ${best_price} price point: {pp_id[:30]}...")
    post("/subscriptionPrices", {"data": {
        "type": "subscriptionPrices",
        "attributes": {"preserveCurrentPrice": False},
        "relationships": {
            "subscription": {"data": {"type": "subscriptions", "id": sid}},
            "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
        }
    }})

# 5. Son durum
print("\n=== Son durum ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    r = get(f"/subscriptions/{sid}", {"fields[subscriptions]": "state,productId"})
    print(f"  {name}: {r.get('data', {}).get('attributes', {})}")
