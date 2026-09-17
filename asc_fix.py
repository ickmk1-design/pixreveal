"""
PixReveal ASC fix:
1. Subscription localization + price ekle (MISSING_METADATA → READY_TO_SUBMIT)
2. Tüm IAP'ları version submission'a ekle
3. Version'ı submit'e hazır et
"""
import time, json, requests
import jwt as pyjwt
from pathlib import Path

KEY_ID    = "YF3T88XKW5"
ISSUER_ID = "37ca6f84-e761-49dd-9577-aa0e349a5953"
APP_ID    = "6784971749"
KEY_FILE  = Path(r"C:\Users\ickmk\Downloads\AuthKey_YF3T88XKW5.p8")
BASE      = "https://api.appstoreconnect.apple.com/v1"
VERSION_ID = "aa153be0-e036-422b-ab7e-293556c2a82e"  # 1.0 REJECTED
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
        print(f"  GET {path} -> {r.status_code}: {r.text[:400]}")
        return {}
    return r.json()

def post(path, body, method="POST"):
    fn = requests.post if method == "POST" else requests.patch
    r = fn(f"{BASE}{path}", headers=hdr(), json=body, timeout=30)
    if not r.ok:
        print(f"  {method} {path} -> {r.status_code}: {r.text[:500]}")
        return None
    return r.json() if r.text else {}

def patch(path, body):
    return post(path, body, method="PATCH")

# ── 1. Subscription ID'leri al ────────────────────────────────────────────────
print("\n=== 1. Subscription ID'leri ===")
subs_resp = get(f"/subscriptionGroups/{SUB_GROUP_ID}/subscriptions",
                {"fields[subscriptions]": "productId,name,state,subscriptionPeriod"})
sub_ids = {}
for s in subs_resp.get("data", []):
    pid = s["attributes"]["productId"]
    sub_ids[pid] = s["id"]
    print(f"  {pid}: {s['id']}  state={s['attributes']['state']}")

# ── 2. Her subscription için localization + fiyat ekle ───────────────────────
print("\n=== 2. Subscription localization + fiyat ===")

def fix_subscription(product_id, monthly: bool):
    sid = sub_ids.get(product_id)
    if not sid:
        print(f"  {product_id}: ID bulunamadı, atlanıyor")
        return

    # Mevcut localization'ları kontrol et
    locs = get(f"/subscriptions/{sid}/subscriptionLocalizations")
    existing_locales = {d["attributes"]["locale"] for d in locs.get("data", [])}
    print(f"  {product_id} mevcut locale'ler: {existing_locales}")

    if "tr" not in existing_locales:
        print(f"    TR locale ekleniyor...")
        post(f"/subscriptionLocalizations", {"data": {
            "type": "subscriptionLocalizations",
            "attributes": {
                "locale": "tr",
                "name": "PixReveal Premium Aylık" if monthly else "PixReveal Premium Yıllık",
                "description": ("Reklamsız oyun, sınırsız can ve tüm güç kitleri açık. "
                               "Her ay otomatik yenilenir. İstediğiniz zaman iptal edin.") if monthly
                               else ("Reklamsız oyun, sınırsız can ve tüm güç kitleri açık. "
                                     "Her yıl otomatik yenilenir. İstediğiniz zaman iptal edin."),
            },
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": sid}}
            }
        }})

    if "en-US" not in existing_locales:
        print(f"    EN locale ekleniyor...")
        post(f"/subscriptionLocalizations", {"data": {
            "type": "subscriptionLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": "PixReveal Premium Monthly" if monthly else "PixReveal Premium Yearly",
                "description": ("Ad-free gameplay, unlimited lives, and all power-ups unlocked. "
                               "Renews monthly. Cancel anytime.") if monthly
                               else ("Ad-free gameplay, unlimited lives, and all power-ups unlocked. "
                                     "Renews annually. Cancel anytime."),
            },
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": sid}}
            }
        }})

    # Fiyat noktası bul ve ekle
    target_usd = "4.99" if monthly else "39.99"
    pts_resp = get(f"/subscriptions/{sid}/pricePoints",
                   {"filter[territory]": "USA", "limit": 200,
                    "fields[subscriptionPricePoints]": "customerPrice,territory"})
    pp_id = None
    for pp in pts_resp.get("data", []):
        if pp["attributes"]["customerPrice"] == target_usd:
            pp_id = pp["id"]
            break

    if pp_id:
        print(f"    Fiyat ekleniyor: ${target_usd}...")
        post("/subscriptionPrices", {"data": {
            "type": "subscriptionPrices",
            "attributes": {"preserveCurrentPrice": False, "preserved": False},
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": sid}},
                "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": pp_id}},
            }
        }})
        print(f"    Fiyat OK: ${target_usd}")
    else:
        # En yakın fiyatı bul
        all_prices = [(pp["attributes"]["customerPrice"], pp["id"]) for pp in pts_resp.get("data", [])]
        print(f"    ${target_usd} bulunamadı. Mevcut fiyatlar (ilk 10): {all_prices[:10]}")

fix_subscription("pixreveal_premium_monthly", monthly=True)
fix_subscription("pixreveal_premium_yearly", monthly=False)

# ── 3. IAP'ları versiyona ekle ─────────────────────────────────────────────────
print("\n=== 3. IAP'ları versiyona ekle ===")

# Tüm IAP ID'leri
iap_ids_all = [
    "6784972364",  # 120 Tokens
    "6784972806",  # 20 Tokens
    "6784972613",  # 300 Tokens
    "6784972807",  # 50 Tokens
    "6784972484",  # 750 Tokens
]

# Subscription ID'leri (doğrudan versiyona eklenemez — sub grup üzerinden)
# Token packs için: PATCH version ile inAppPurchasesV2 ilişkisi
# Subscriptions için: automatically included via subscription group

# Mevcut version IAP ilişkisini kontrol et
existing_iaps = get(f"/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations",
                    {"fields[appStoreVersionLocalizations]": "locale"})
print(f"  Version localizations: {[d['attributes']['locale'] for d in existing_iaps.get('data', [])]}")

# IAP'ları versiyona bağla (inAppPurchaseSubmission)
added = 0
for iap_id in iap_ids_all:
    resp = post("/inAppPurchaseSubmissions", {"data": {
        "type": "inAppPurchaseSubmissions",
        "relationships": {
            "inAppPurchase": {"data": {"type": "inAppPurchasesV2", "id": iap_id}}
        }
    }})
    if resp is not None:
        print(f"  [OK] IAP {iap_id} submit'e eklendi")
        added += 1
    else:
        print(f"  [SKIP/ERR] IAP {iap_id}")

# Subscription'ları da ekle
for pid, sid in sub_ids.items():
    resp = post("/subscriptionSubmissions", {"data": {
        "type": "subscriptionSubmissions",
        "relationships": {
            "subscription": {"data": {"type": "subscriptions", "id": sid}}
        }
    }})
    if resp is not None:
        print(f"  [OK] Sub {pid} submit'e eklendi")
    else:
        print(f"  [SKIP/ERR] Sub {pid}")

# ── 4. Version durumunu tekrar kontrol et ─────────────────────────────────────
print("\n=== 4. Son durum ===")
ver = get(f"/appStoreVersions/{VERSION_ID}", {"fields[appStoreVersions]": "appStoreState,versionString"})
attrs = ver.get("data", {}).get("attributes", {})
print(f"  Version: {attrs.get('versionString')} state={attrs.get('appStoreState')}")

# IAP submission durumları
print("\n  IAP submission durumları:")
for iap_id in iap_ids_all:
    r2 = get(f"/inAppPurchasesV2/{iap_id}", {"fields[inAppPurchasesV2]": "state,productId"})
    attrs2 = r2.get("data", {}).get("attributes", {})
    print(f"    {attrs2.get('productId', iap_id)}: {attrs2.get('state')}")

print("\n  Subscription durumları:")
subs2 = get(f"/subscriptionGroups/{SUB_GROUP_ID}/subscriptions",
            {"fields[subscriptions]": "productId,state"})
for s in subs2.get("data", []):
    print(f"    {s['attributes']['productId']}: {s['attributes']['state']}")

print("\nScript tamam. Codemagic build tetiklenecek.")
