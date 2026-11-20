# iOS 1.0.1 Submit Hazırlık (PixReveal / Reveal Zone)

**Oluşturulma:** 2026-11-20
**Sıra:** Codemagic dakikası yenilenince build (25+) → TestFlight → (o zamana kadar reddedildiyse) metadata güncelle + submit.
**Mevcut iOS 1.0 submission durumu:** `881b8776-8068-44dc-8460-6e10c7b42a61` (2026-11-05) WAITING_FOR_REVIEW — **GERİ ÇEKİLMİYOR** (user kararı). ASC'ye dokunulmuyor.

---

## §1 Doğrulanmış metadata (1.0.1 submission'ında kullanılacak)

### ASC — EN (en-US)

| Alan | Limit | Önce | Sonra | Char |
|---|---|---|---|---|
| name | 30 | `Reveal Zone` (11) | `Reveal Zone: Pixel Area Dash` | 28/30 |
| subtitle | 30 | `Reveal pics, beat the spider` | `Territory Capture, Arcade` | 25/30 |
| keywords | 100 | `reveal,puzzle,qix,volfied,jezzball,arcade,spider,pixel,area,capture,xonix,bix,paint` (82) | `territory,capture,arcade,puzzle,retro,neon,80s,maze,area,paint,pixel,classic,spider,dash` | 88/100 |
| promotionalText | 170 | `A spider hunts… Hundreds of levels` (138) | `Dash, claim territory, outrun the spider. Reveal hidden pics across 72 levels in 6 themed packs. Core gameplay runs offline. Free to play.` | 139/170 |

**Yeni ASC EN description (submission payload):**

```
Reveal Zone is a fast-paced retro arcade puzzle. Dash across the arena, claim territory, and reveal beautiful hidden images — all while a spider hunts you down.

If you love classic 80s/90s territory-capture arcade games, this is the modern spiritual sequel you have been waiting for.

HOW TO PLAY
1. Tap and drag to carve a path across the board.
2. Close a shape to claim that area and reveal part of the hidden picture.
3. Reveal enough of the image to clear the level — but never let the spider touch your trail.

FEATURES
- 72 handcrafted levels across 6 themed image packs
- Themes: Super Cars, Deep Space, Wild Animals, Beach, Fitness, Fantasy
- Power-ups: Freeze, Speed Boost and Shield
- Earn tokens, chase three-star perfection, beat your high score
- Smooth premium visuals in a vibrant neon style
- Core gameplay runs offline once installed

GO PREMIUM
Unlock ad-free play, unlimited lives, and exclusive power-ups.

PRICING
- Monthly and Yearly subscription plans
- Manage or cancel anytime in Apple ID > Subscriptions

Terms of Use: https://cytbilisim.com/pixreveal/terms
Privacy Policy: https://cytbilisim.com/pixreveal/privacy
```

### ASC — TR (tr)

| Alan | Limit | Önce | Sonra | Char |
|---|---|---|---|---|
| name | 30 | `PixReveal` (9) | `PixReveal: Alan Kapma Oyunu` | 28/30 |
| subtitle | 30 | `Resimleri aç, örümceği yen` | `Alan Kapma, Arcade Macera` | 25/30 |
| keywords | 100 | `resim,bulmaca,qix,volfied,jezzball,arcade,orumcek,piksel,alan,kaplama,xonix,oyun` (80) | `alan,kaplama,arcade,bulmaca,retro,neon,80s,klasik,orumcek,piksel,refleks,dash,oyun,strateji` | 92/100 |
| promotionalText | 170 | `Bir örümcek pesinde!… Yüzlerce bölüm` (134) | `Alan kap, örümcekten kaç, resimleri aç. 72 bölüm, 6 tema paketi, çekirdek oynanış çevrimdışı. Ücretsiz başla, abonelik opsiyonel.` | 131/170 |

**Yeni ASC TR description:**

```
PixReveal, hızlı tempolu bir retro arcade bulmaca oyunudur. Arenada ilerle, alanı ele geçir ve bir örümcek seni avlarken gizli resimleri ortaya çıkar.

80'ler/90'lar alan-kapma arcade klasiklerini seviyorsan, bu oyun tam modern mirasçı.

NASIL OYNANIR
1. Parmağını sürükleyerek tahtada bir yol çiz.
2. Bir şekli kapattığında o alanı ele geçir ve resmin bir parçasını aç.
3. Bölümü geçmek için yeterince aç — ama izine örümcek değmesin.

ÖZELLİKLER
- 6 temada 72 özenle hazırlanmış bölüm
- Temalar: Süper Arabalar, Derin Uzay, Vahşi Hayvanlar, Plaj, Fitness, Fantezi
- Güçlendirmeler: Dondurma, Hız ve Kalkan
- Jeton kazan, üç yıldızı kovala, en yüksek skorunu geç
- Canlı neon tarzı, akıcı premium görseller
- Çekirdek oynanış kurulumdan sonra çevrimdışı çalışır

PREMIUM OL
Reklamsız oyna, sınırsız can ve özel güçlendirmelerin keyfini çıkar.

FİYATLANDIRMA
- Aylık ve Yıllık abonelik planları
- Apple ID > Abonelikler üzerinden istediğin an iptal

Kullanım Koşulları: https://cytbilisim.com/pixreveal/terms
Gizlilik Politikası: https://cytbilisim.com/pixreveal/privacy
```

### Kategori (1.0.1 submission ile)
- Önce: GAMES + ENTERTAINMENT
- Sonra: GAMES / Primary Sub **GAMES_PUZZLE**, Secondary Sub **GAMES_CASUAL** (NOT: GAMES_ARCADE Apple'da yok)
- App Info v2 PATCH: `relationships.primaryCategory + primarySubcategoryOne + primarySubcategoryTwo`

---

## §2 "Own Image" geçen screenshot setlerinin listesi

`GameCategory.ownImage` enum'dan kaldırıldığı için (de25d61) kategori grid 6→5'e düştü, categories_screen layout değişti. Mevcut iOS 1.0 ASC screenshot'larında "Own Image / Kendi Fotoğrafın" içeren setler 1.0.1 submit öncesi yeniden çekilecek.

| Set | iOS cihaz | Own-image içeriği potansiyeli | Yeniden çekim? |
|---|---|---|---|
| Categories grid | iPhone 6.7" (1290×2796) | **YÜKSEK** — kategori grid'inde 6. satır "Own Image / Kendi Fotoğrafın" | ✅ EVET |
| Categories grid | iPhone 6.5" (1242×2688) | YÜKSEK | ✅ EVET |
| Categories grid | iPhone 5.5" (1242×2208) | YÜKSEK | ✅ EVET |
| Categories grid | iPad Pro 12.9" (2048×2732) | YÜKSEK | ✅ EVET |
| Paywall | tüm cihazlar | ORTA — paywall içinde "unlock own image" promise olabilir | ⚠️ KONTROL |
| Gameplay (level sırasında) | tüm cihazlar | DÜŞÜK — HUD, own-image içermez | ❌ (tut) |
| Victory/game-over | tüm cihazlar | DÜŞÜK | ❌ (tut) |
| Main menu | tüm cihazlar | DÜŞÜK | ❌ (tut) |

**Önerilen screenshot inventory komutu (1.0.1 submit öncesi):**

```bash
# 1. Mevcut ASC screenshot'larını indir (önizleme için)
python pixreveal/scripts/asc_screenshots_download.py \
  --app-id 6784971749 --version 1.0 \
  --out ./asc_screenshots_check/

# 2. Manuel: "OWN PHOTO" / "KENDİ FOTOĞRAFIN" metin içeren setleri işaretle
# 3. Yeniden çekim (fiziksel cihaz + export OR flutter integration_test golden)
# 4. Yeni screenshot'ları appStoreVersionLocalizations → screenshotSets'e upload
#    (upload script falomi/scripts/asc_screenshots.py pattern'inden adapte)
```

**Not:** Mobile code 1.0.1'de categories ekranında 5-6 kategori (cars/space/animals/beach/fitness/fantasy) gösterecek — eski 6-row ownImage içeren screenshot'lar uyumsuz, yeni çekim şart.

---

## §3 Review Notes (1.0.1 Apple'a gönderilecek)

```
PixReveal / Reveal Zone — v1.0.1 Review Notes

### What changed since v1.0
- REMOVED "Own Image / Kendi Fotoğrafın" category UI — feature was never
  implemented (no image_picker in pubspec, no custom image handler).
  Button removed to match actual functionality.
- Marketing claims updated to match code:
  - "Hundreds of levels" → "72 handcrafted levels across 6 themed packs"
  - "Weekly plan" → "Monthly and Yearly subscriptions"
  - "Own Photo" feature mention removed (EN + TR description)
- Startup ANR fix (cold-start safety):
  - Firebase, RevenueCat, AdMob, audio init moved AFTER first frame via
    SchedulerBinding.addPostFrameCallback + scheduleMicrotask
  - Each service wrapped in _safe() with 4-15s timeout + try/catch
  - Fixes cold-launch channel-error chain (reproduced on Pixel API 34)
- Asset payload reduced 77.7% via WebP conversion (124.7 MB -> 27.8 MB)

### Reviewer notes
- No account/login required to play.
- Subscription products (monthly + yearly) are OPTIONAL — core game loop
  (6 themes × 12 levels = 72 levels) is free to play, ad-supported.
- Ads: Google AdMob (interstitial + rewarded + banner). UMP consent form
  shown on first launch per Apple/Google requirements.
- Firebase (Auth + Analytics + Messaging) initializes on first frame;
  app functions normally without network (offline-first after install).
- No user-generated content, no social features, no third-party chat.
- Content rating: 4+. All image packs are original or licensed stock
  (Super Cars, Deep Space, Wild Animals, Beach, Fitness, Fantasy).

### Demo account
Not required. App launches directly into gameplay menu.

### Contact
- Developer: ickmk1@gmail.com
- Support: https://cytbilisim.com/pixreveal
```

---

## §4 Codemagic dakika yenilenmesi

- **Hesap tipi:** Personal (team yok)
- **Kota:** 500 macOS M2 dakikası/ay (Codemagic Free)
- **Yenileme:** Calendar month başı (UTC midnight)
- **Sonraki reset:** **2026-12-01 00:00 UTC** (= 03:00 TRT 1 Aralık) — **bugünden 11 gün sonra**
- **Kaynak:** Codemagic community docs: "500 free macOS M2 minutes refilled every month" — calendar-month standart
- **Mevcut durum (2026-11-20):** Son build 2026-11-09 — o gün 30 build ardışık (debug döngüsü). Dakikalar o günde bitti. 11 gün önce kota tükendi.
- **Reset onayı:** Codemagic UI → Settings → Billing & plans'ta "Next refill" alanı var. 2026-12-01 ≠ ise bu dosyayı güncelle.

---

## §5 Submission adımları (Codemagic sıfırlandıktan sonra)

### Önce Apple review sonucunu bekle
- Resolution Center kontrolü: ASC → App → Version 1.0 → Resolution
- Apple soru gönderdiyse cevapla (version 1.0 submission'ında)
- Onay/red geldiğinde 1.0 state değişir

### Build (2026-12-01+)
1. Codemagic ios workflow trigger:
   ```
   curl -X POST -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
     -H "Content-Type: application/json" \
     https://api.codemagic.io/builds \
     -d '{"appId":"<pixreveal-app-id>","workflowId":"ios-production","branch":"main"}'
   ```
2. Build 25 (ya da 26+) TestFlight'a push; processing bekle (~5-30 dk)
3. TestFlight'ta smoke: açılış 3 saniyede menü, kategorilerden 2'sini oyna, paywall aç, satın alma iptal et

### Submit (user "gönder" dedikten sonra)
4. Yeni appStoreVersion oluştur (1.0.1 / build 25)
5. Metadata'yı §1'deki EN + TR "Sonra" değerleriyle PATCH
6. Kategori: GAMES + GAMES_PUZZLE primary sub + GAMES_CASUAL secondary sub
7. Screenshot setlerini §2 tablosuna göre yeniden çek + upload
8. v2 reviewSubmission: appStoreVersion + varsa yeni subscriptionVersion ekle
9. `reviewSubmissions {submitted:true}` PATCH

### Rollback planı
Submit edildikten sonra Apple'dan red gelirse:
- Resolution Center'da red nedeni oku
- Gerekli düzeltmeleri yap (build gerekiyorsa Codemagic'te yeni build, metadata gerekiyorsa sadece appStoreVersionLocalizations PATCH)
- `reviewSubmissions` yeni submission oluştur (eskisi COMPLETE kalır)

---

## §6 Mevcut aktif submission — kabul edilen riskler

ASC: `881b8776-8068-44dc-8460-6e10c7b42a61` (2026-11-05 submit) — WAITING_FOR_REVIEW, lastUpdatedByActor=APPLE.
- Build 24 (2026-10-22 upload) hâlâ bağlı — **ANR fix içermez** (f824d97 commit'i 2026-11-20'de, build 24 üretiminden 29 gün sonra)
- Cold-start ANR regression riski var (Firebase channel-error senaryosunda watchdog kill 0x8badf00d)
- Metadata iddiaları eski ("Hundreds of levels", "Your Own Image", "Weekly plan")
- **Riski kabul ediyoruz** — Codemagic kota yenilenmeden iOS tarafına dokunulmuyor.
- Eğer Apple approve ederse: 1.0 canlıya çıkar (eski kodla); 1.0.1 yukarıdaki plan ile ayrı sürüm olarak submit edilir.
- Eğer Apple reject ederse: red nedenine göre §5'teki yol izlenir.
