"""Subscription mevcut fiyatları gör + doğru price point ile set et"""
import os, time, base64, json, requests
import jwt as pyjwt
from pathlib import Path

KEY_ID    = "YF3T88XKW5"
ISSUER_ID = "37ca6f84-e761-49dd-9577-aa0e349a5953"
KEY_FILE  = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE      = "https://api.appstoreconnect.apple.com/v1"
os.environ["PYTHONIOENCODING"] = "utf-8"

MONTHLY_ID = "6784972491"
YEARLY_ID  = "6784972888"

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
        print(f"  GET -> {r.status_code}: {r.text[:300]}")
        return {}
    return r.json()

def post(path, body):
    r = requests.post(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.status_code in (200, 201)
    status = "OK" if ok else f"FAIL {r.status_code}"
    print(f"  POST {status}: {r.text[:300] if not ok else ''}")
    return r.json() if (r.text and ok) else None

# Mevcut fiyatları kontrol et
print("=== Mevcut subscription fiyatlari ===")
for sid, name in [(MONTHLY_ID, "MONTHLY"), (YEARLY_ID, "YEARLY")]:
    prices = get(f"/subscriptions/{sid}/prices")
    data = prices.get("data", [])
    print(f"  {name}: {len(data)} mevcut fiyat")
    for p in data[:5]:
        print(f"    {p}")

# Price points'leri decode et
print("\n=== Price point ID decode ===")
for sid, name, target in [(MONTHLY_ID, "MONTHLY", "4.99"), (YEARLY_ID, "YEARLY", "39.99")]:
    pts = get(f"/subscriptions/{sid}/pricePoints",
              {"filter[territory]": "USA", "limit": 200,
               "fields[subscriptionPricePoints]": "customerPrice,priceTier,territory"})
    for pp in pts.get("data", []):
        if pp["attributes"]["customerPrice"] == target:
            pp_id = pp["id"]
            try:
                # Pad base64
                padded = pp_id + "=" * (4 - len(pp_id) % 4)
                decoded = base64.b64decode(padded).decode()
                print(f"  {name} ${target}: {pp_id}")
                print(f"    decoded: {decoded}")
            except Exception as e:
                print(f"  {name}: decode error: {e}")
            break

# Doğru format ile dene
print("\n=== Price set (yeni format) ===")
# Mevcut fiyat varsa delete et önce
for sid, name in [(MONTHLY_ID, "MONTHLY"), (YEARLY_ID, "YEARLY")]:
    prices = get(f"/subscriptions/{sid}/prices")
    for p in prices.get("data", []):
        pid = p["id"]
        r = requests.delete(f"{BASE}/subscriptionPrices/{pid}", headers=hdr(), timeout=30)
        print(f"  DELETE price {pid}: {r.status_code}")

# Şimdi fiyat ekle (sadece attributes, ilişki olmadan dene)
for sid, name, target in [(MONTHLY_ID, "MONTHLY", "4.99"), (YEARLY_ID, "YEARLY", "39.99")]:
    pts = get(f"/subscriptions/{sid}/pricePoints",
              {"filter[territory]": "USA", "limit": 200,
               "fields[subscriptionPricePoints]": "customerPrice"})
    pp_id = next((pp["id"] for pp in pts.get("data", [])
                  if pp["attributes"]["customerPrice"] == target), None)
    if not pp_id:
        print(f"  {name}: ${target} yok")
        continue
    print(f"\n  {name}: price set deneniyor...")
    post("/subscriptionPrices", {"data": {
        "type": "subscriptionPrices",
        "attributes": {"preserveCurrentPrice": False},
        "relationships": {
            "subscription": {"data": {"type": "subscriptions", "id": sid}},
            "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
        }
    }})

print("\n=== Son durum ===")
for sid, name in [(MONTHLY_ID, "MONTHLY"), (YEARLY_ID, "YEARLY")]:
    r = get(f"/subscriptions/{sid}", {"fields[subscriptions]": "state,productId"})
    print(f"  {name}: {r.get('data', {}).get('attributes', {})}")
