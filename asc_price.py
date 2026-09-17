"""Subscription fiyat fix — tüm territory için otomatik fiyat"""
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
        print(f"  GET {path} -> {r.status_code}: {r.text[:300]}")
        return {}
    return r.json()

def post(path, body, method="POST"):
    fn = requests.post if method == "POST" else requests.patch
    r = fn(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    ok = r.ok or r.status_code == 201
    if not ok:
        print(f"  {method} {path} -> {r.status_code}: {r.text[:400]}")
    else:
        print(f"  {method} {path} -> {r.status_code} OK")
    return r.json() if (r.text and ok) else None

def find_price_point(sub_id, target):
    """USA price point ID for given price string"""
    cursor = None
    while True:
        params = {"filter[territory]": "USA", "limit": 200,
                  "fields[subscriptionPricePoints]": "customerPrice,territory"}
        if cursor:
            params["cursor"] = cursor
        resp = get(f"/subscriptions/{sub_id}/pricePoints", params)
        for pp in resp.get("data", []):
            if pp["attributes"]["customerPrice"] == target:
                return pp["id"]
        next_cursor = resp.get("links", {}).get("next")
        if not next_cursor:
            break
        # Extract cursor from next URL
        import re
        m = re.search(r"cursor=([^&]+)", next_cursor)
        if not m:
            break
        cursor = m.group(1)
    return None

def set_price(sub_id, price_str, label):
    """USA price + automatic territory extension"""
    pp_id = find_price_point(sub_id, price_str)
    if not pp_id:
        print(f"  {label}: ${price_str} price point yok, mevcut fiyatlar:")
        pts = get(f"/subscriptions/{sub_id}/pricePoints",
                  {"filter[territory]": "USA", "limit": 50,
                   "fields[subscriptionPricePoints]": "customerPrice"})
        prices = [d["attributes"]["customerPrice"] for d in pts.get("data", [])]
        print(f"    {sorted(prices, key=float)}")
        return False

    resp = post("/subscriptionPrices", {"data": {
        "type": "subscriptionPrices",
        "attributes": {"preserveCurrentPrice": False},
        "relationships": {
            "subscription": {"data": {"type": "subscriptions", "id": sub_id}},
            "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
        }
    }})
    print(f"  {label}: ${price_str} ayarlandi")
    return True

# 1. Monthly $4.99
print("=== Monthly: $4.99 ===")
set_price(MONTHLY_ID, "4.99", "monthly")

# 2. Yearly: check what's available near $39.99
print("\n=== Yearly: price point ara ===")
# Apple yearly tiers: 39.99 var mi?
for candidate in ["39.99", "34.99", "49.99"]:
    pp = find_price_point(YEARLY_ID, candidate)
    if pp:
        print(f"  ${candidate} bulundu: {pp}")
        set_price(YEARLY_ID, candidate, "yearly")
        break
else:
    print("  Standart fiyat yok — tum price point listesi:")
    pts = get(f"/subscriptions/{YEARLY_ID}/pricePoints",
              {"filter[territory]": "USA", "limit": 200,
               "fields[subscriptionPricePoints]": "customerPrice"})
    all_prices = sorted([d["attributes"]["customerPrice"] for d in pts.get("data", [])], key=float)
    print(f"  {all_prices}")

# 3. Subscription durumlarini goster
print("\n=== Durum kontrol ===")
for sid, name in [(MONTHLY_ID, "monthly"), (YEARLY_ID, "yearly")]:
    r = get(f"/subscriptions/{sid}", {"fields[subscriptions]": "state,productId"})
    attrs = r.get("data", {}).get("attributes", {})
    print(f"  {name}: {attrs}")

# 4. Version submit
print("\n=== Version submit ===")
ver_state = get(f"/appStoreVersions/{VERSION_ID}", {"fields[appStoreVersions]": "appStoreState"})
state = ver_state.get("data", {}).get("attributes", {}).get("appStoreState")
print(f"  Version state: {state}")

if state in ("REJECTED", "DEVELOPER_REJECTED", "METADATA_REJECTED", "PREPARE_FOR_SUBMISSION"):
    print("  Submitting for review...")
    sub = post("/appStoreVersionSubmissions", {"data": {
        "type": "appStoreVersionSubmissions",
        "relationships": {
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
        }
    }})
    if sub:
        print("  Submit OK")
    else:
        print("  Submit failed (subscription fiyatlari eksik olabilir)")
else:
    print(f"  Submit yapilamaz state={state}")
