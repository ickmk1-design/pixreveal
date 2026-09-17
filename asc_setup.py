"""
PixReveal — ASC IAP setup + version submission
Key: YF3T88XKW5 / Issuer: 37ca6f84-e761-49dd-9577-aa0e349a5953
App: 6784971749
"""
import sys, json, time, requests
import jwt as pyjwt
from datetime import datetime, timezone
from pathlib import Path

KEY_ID      = "YF3T88XKW5"
ISSUER_ID   = "37ca6f84-e761-49dd-9577-aa0e349a5953"
APP_ID      = "6784971749"
KEY_FILE    = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE        = "https://api.appstoreconnect.apple.com/v1"

def token():
    pk = KEY_FILE.read_text()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 900,
                "aud": "appstoreconnect-v1"}
    return pyjwt.encode(payload, pk, algorithm="ES256",
                         headers={"kid": KEY_ID, "typ": "JWT"})

def hdr():
    return {"Authorization": f"Bearer {token()}",
            "Content-Type": "application/json"}

def get(path, params=None):
    r = requests.get(f"{BASE}{path}", headers=hdr(), params=params, timeout=30)
    r.raise_for_status()
    return r.json()

def post(path, body):
    r = requests.post(f"{BASE}{path}", headers=hdr(),
                      json=body, timeout=30)
    if not r.ok:
        print(f"  ERROR {r.status_code}: {r.text[:400]}")
        return None
    return r.json()

# ── 1. Mevcut IAP'ları listele ────────────────────────────────────────────────
print("\n=== 1. Mevcut IAP listesi ===")
existing = get(f"/apps/{APP_ID}/inAppPurchasesV2",
               {"limit": 200, "fields[inAppPurchasesV2]": "productId,name,inAppPurchaseType,state"})
iap_map = {}
for d in existing.get("data", []):
    pid = d["attributes"]["productId"]
    st  = d["attributes"]["state"]
    iap_map[pid] = d["id"]
    print(f"  {pid:45s} {st}")

# ── 2. Subscription Group ─────────────────────────────────────────────────────
print("\n=== 2. Subscription Groups ===")
grps = get(f"/apps/{APP_ID}/subscriptionGroups",
           {"fields[subscriptionGroups]": "referenceName"})
sub_group_id = None
for g in grps.get("data", []):
    print(f"  group: {g['id']}  name={g['attributes']['referenceName']}")
    sub_group_id = g["id"]

if not sub_group_id:
    print("  Grup yok — olusturuluyor...")
    resp = post("/subscriptionGroups", {"data": {
        "type": "subscriptionGroups",
        "attributes": {"referenceName": "PixReveal Premium"},
        "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}
    }})
    if resp:
        sub_group_id = resp["data"]["id"]
        print(f"  Grup olusturuldu: {sub_group_id}")

# ── 3. Subscriptions ──────────────────────────────────────────────────────────
SUBS = [
    ("pixreveal_premium_monthly", "PixReveal Premium Monthly", 1),   # 1 month
    ("pixreveal_premium_yearly",  "PixReveal Premium Yearly",  12),  # 12 months
]

def ensure_sub(product_id, name, duration_months):
    if product_id in iap_map:
        print(f"  [EXISTS] {product_id}")
        return iap_map[product_id]
    print(f"  [CREATE] {product_id}")
    dur = "ONE_MONTH" if duration_months == 1 else "ONE_YEAR"
    resp = post("/subscriptions", {"data": {
        "type": "subscriptions",
        "attributes": {
            "productId": product_id,
            "name": name,
            "subscriptionPeriod": dur,
            "reviewNote": "Subscription for ad-free gameplay, unlimited lives, and all power-ups unlocked.",
            "familySharable": False,
        },
        "relationships": {
            "group": {"data": {"type": "subscriptionGroups", "id": sub_group_id}}
        }
    }})
    if not resp:
        return None
    sid = resp["data"]["id"]
    iap_map[product_id] = sid

    # Localization TR
    post(f"/subscriptions/{sid}/localizations", {"data": {
        "type": "subscriptionLocalizations",
        "attributes": {
            "locale": "tr",
            "name": "PixReveal Premium" if duration_months == 1 else "PixReveal Premium Yillik",
            "description": ("Reklamsiz oyun, sinirsi can ve tum guc kitleri acik. "
                           "Her ay otomatik yenilenir. Istediginiz zaman iptal.") if duration_months == 1
                           else ("Reklamsiz oyun, sinirsi can ve tum guc kitleri acik. "
                                 "Her yil otomatik yenilenir. Istediginiz zaman iptal."),
        }
    }})
    # Localization EN
    post(f"/subscriptions/{sid}/localizations", {"data": {
        "type": "subscriptionLocalizations",
        "attributes": {
            "locale": "en-US",
            "name": "PixReveal Premium" if duration_months == 1 else "PixReveal Premium Yearly",
            "description": ("Ad-free gameplay, unlimited lives, and all power-ups unlocked. "
                           "Renews monthly. Cancel anytime.") if duration_months == 1
                           else ("Ad-free gameplay, unlimited lives, and all power-ups unlocked. "
                                 "Renews annually. Cancel anytime."),
        }
    }})

    # Price — US territory, find price point for $4.99 (monthly) or $39.99 (yearly)
    target_usd = "4.99" if duration_months == 1 else "39.99"
    try:
        pts = get(f"/subscriptions/{sid}/pricePoints",
                  {"filter[territory]": "USA", "limit": 200,
                   "fields[subscriptionPricePoints]": "customerPrice,proceeds,territory"})
        pp_id = None
        for pp in pts.get("data", []):
            if pp["attributes"]["customerPrice"] == target_usd:
                pp_id = pp["id"]
                break
        if pp_id:
            post("/subscriptionPrices", {"data": {
                "type": "subscriptionPrices",
                "attributes": {"preserveCurrentPrice": False, "preserved": False},
                "relationships": {
                    "subscription": {"data": {"type": "subscriptions", "id": sid}},
                    "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
                }
            }})
            print(f"    Fiyat set: ${target_usd}/{'ay' if duration_months==1 else 'yil'} (US)")
        else:
            print(f"    UYARI: ${target_usd} price point bulunamadi — ASC'den elle set et")
    except Exception as e:
        print(f"    Price point hatasi: {e}")
    return sid

print("\n=== 3. Subscriptions ===")
if sub_group_id:
    for pid, name, dur in SUBS:
        ensure_sub(pid, name, dur)
else:
    print("  Subscription group yok, atlanıyor")

# ── 4. Consumable token packs ─────────────────────────────────────────────────
TOKENS = [
    ("pixreveal_tokens_20",  "20 Tokens",   "0.99"),
    ("pixreveal_tokens_50",  "50 Tokens",   "1.99"),
    ("pixreveal_tokens_120", "120 Tokens",  "3.99"),
    ("pixreveal_tokens_300", "300 Tokens",  "7.99"),
    ("pixreveal_tokens_750", "750 Tokens",  "14.99"),
]

def ensure_consumable(product_id, name, usd_price):
    if product_id in iap_map:
        print(f"  [EXISTS] {product_id}")
        return iap_map[product_id]
    print(f"  [CREATE] {product_id} ${usd_price}")
    resp = post("/inAppPurchasesV2", {"data": {
        "type": "inAppPurchasesV2",
        "attributes": {
            "productId": product_id,
            "name": name,
            "inAppPurchaseType": "CONSUMABLE",
            "reviewNote": "Consumable token pack for extra lives in gameplay.",
            "familySharable": False,
            "availableInAllTerritories": True,
        },
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }
    }})
    if not resp:
        return None
    iid = resp["data"]["id"]
    iap_map[product_id] = iid

    # Localization EN
    post(f"/inAppPurchasesV2/{iid}/inAppPurchaseLocalizations", {"data": {
        "type": "inAppPurchaseLocalizations",
        "attributes": {
            "locale": "en-US",
            "name": name,
            "description": f"Get {name.split()[0]} tokens to continue playing with extra lives.",
        }
    }})
    # Localization TR
    tokens_num = name.split()[0]
    post(f"/inAppPurchasesV2/{iid}/inAppPurchaseLocalizations", {"data": {
        "type": "inAppPurchaseLocalizations",
        "attributes": {
            "locale": "tr",
            "name": f"{tokens_num} Jeton",
            "description": f"Oyunda ekstra can kazanmak icin {tokens_num} jeton al.",
        }
    }})

    # Price schedule
    try:
        pts = get(f"/inAppPurchasesV2/{iid}/pricePoints",
                  {"filter[territory]": "USA", "limit": 200,
                   "fields[inAppPurchasePricePoints]": "customerPrice,proceeds,territory"})
        pp_id = None
        for pp in pts.get("data", []):
            if pp["attributes"]["customerPrice"] == usd_price:
                pp_id = pp["id"]
                break
        if pp_id:
            post(f"/inAppPurchasesV2/{iid}/priceSchedule", {"data": {
                "type": "inAppPurchasePriceSchedules",
                "relationships": {
                    "inAppPurchase": {"data": {"type": "inAppPurchasesV2", "id": iid}},
                    "manualPrices": {"data": [{"type": "inAppPurchasePrices", "id": "NEW_IAP_PRICE"}]},
                },
            }})
            print(f"    Fiyat set: ${usd_price}")
        else:
            print(f"    UYARI: ${usd_price} price point bulunamadi — ASC'den elle set et")
    except Exception as e:
        print(f"    Price set error: {e}")

    return iid

print("\n=== 4. Token Packs ===")
for pid, name, price in TOKENS:
    ensure_consumable(pid, name, price)

# ── 5. Mevcut version'u bul + IAP ekle ───────────────────────────────────────
print("\n=== 5. App Store Version ===")
try:
    vers = get(f"/apps/{APP_ID}/appStoreVersions",
               {"filter[platform]": "IOS",
                "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,WAITING_FOR_REVIEW,IN_REVIEW,DEVELOPER_REJECTED,REJECTED,METADATA_REJECTED",
                "limit": 5})
    for v in vers.get("data", []):
        st = v["attributes"]["appStoreState"]
        vn = v["attributes"]["versionString"]
        print(f"  Version {vn} state={st} id={v['id']}")
except Exception as e:
    print(f"  Version query error: {e}")

print("\n=== TAMAMLANDI ===")
print(f"IAP map ({len(iap_map)} urun):")
for pid, iid in iap_map.items():
    print(f"  {pid}: {iid}")
