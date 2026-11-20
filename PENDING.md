## Crash/ANR monitoring eksikliği (2026-11-20 audit)

- **Durum**: `mobile/pubspec.yaml` içinde `sentry_flutter` **yok**, `firebase_crashlytics` **yok**. `lib/main.dart` içinde hiçbir crash reporter init çağrısı yok.
- **Risk**: Play Vitals düşük user sayılarında boş dönüyor (Google threshold); production crash/ANR sinyalini tamamen kaybediyoruz. Flutter engine Dart uncaught exception'ları veya platform channel crash'leri hiç görülmüyor.
- **Yapılacak**: [bir sonraki build'den önce]
  - `pubspec.yaml` → `sentry_flutter: ^8.x` ekle
  - `lib/main.dart` → `main()` içinde:
    ```dart
    await SentryFlutter.init(
      (o) {
        o.dsn = const String.fromEnvironment('SENTRY_DSN');
        o.environment = kReleaseMode ? 'production' : 'dev';
        o.tracesSampleRate = 0.1;
        o.anrEnabled = true; // Android ANR default true, explicit yine de
      },
      appRunner: () => runApp(const MyApp()),
    );
    ```
  - `--dart-define=SENTRY_DSN=...` ile build (Codemagic env)
- **DSN**: Sentry dashboard → ickmk org → yeni project `pixreveal-mobile` (platform=dart-flutter) aç, DSN al, Codemagic'e `SENTRY_DSN` olarak ekle
- **Doğrulama**: Build sonrası ilk cihaz launch'tan 5 dk içinde `app:launch` breadcrumb Sentry'de görünmeli

---

# PixReveal / Reveal Zone — ASO PENDING

**Durum (2026-11-20):** ⚠️ iOS 1.0 `WAITING_FOR_REVIEW` (Haziran 2026'dan beri; en son submit 2026-11-05). **ASC'ye DOKUNULMUYOR** — review bitene kadar hiçbir alan değiştirilmez.

**ÖNEMLİ — Apple Review Durumu (ayrı rapor):**
- Build 24 (2026-10-22) `VALID`
- 5 ayrı reviewSubmission (2026-08 → 2026-11) — hepsi daha önce `COMPLETE` oldu ama app **hiçbir zaman READY_FOR_SALE'e geçmedi** → her biri **rejected** olarak yorumlanmalı
- Aktif submission `881b8776-...` 2026-11-05 submitted, WAITING_FOR_REVIEW, lastUpdatedByActor=APPLE
- **Red riski:** description'daki "Hundreds of levels" yanlış (gerçek 72) ve "Your Own Image" fonksiyonu UI stub (`image_picker` kodu yok) — Apple 2.3.1 (yanıltıcı metadata) ya da 2.5.2 (missing functionality) nedeniyle reddediyor olabilir. Geri çekme kararı için bkz. `aso_current/analysis_b_v2.md` § 1.1 ve Reveal Zone Review Durum Raporu.

## ✅ UYGULANDI (bu turda — Play only)
- Google Play title/shortDesc/fullDesc TR + EN: güncel
  - Play title TR: `PixReveal: Alan Kapma Arcade`
  - Play title EN: `Reveal Zone: Area Capture Dash`
  - "qix / volfied / jezzball / xonix" rakip markaları tüm Play metinlerinden kaldırıldı
  - "Hundreds of levels" → **72 bölüm, 6 tema**
  - Power-up list → gerçek: **Freeze, Speed Boost, Shield**
  - "Weekly plan" + "3-day trial" iddiası kaldırıldı — Monthly + Yearly

## PENDING — iOS (review bittiğinde)

### Name (30/30)
- Önce (TR): `PixReveal` (9)  /  (EN): `Reveal Zone` (11)
- Sonra (TR): `PixReveal: Alan Kapma Oyunu` (28)  /  (EN): `Reveal Zone: Pixel Area Dash` (28)

### Subtitle
- Önce (TR): `Resimleri aç, örümceği yen`  /  (EN): `Reveal pics, beat the spider`
- Sonra (TR): `Qix Bulmaca, Arcade Macera` → **jenerikleştir:** `Alan Kapma, Arcade Macera` (NOT: "Qix" rakip marka çıkar)
- Sonra (EN): `Territory Capture, Arcade` (jenerik, marka içermez)

### Keywords
- Önce (TR): `resim,bulmaca,qix,volfied,jezzball,arcade,orumcek,piksel,alan,kaplama,xonix,oyun`
- Sonra (TR): `alan,kaplama,arcade,bulmaca,retro,neon,80s,klasik,orumcek,piksel,refleks,dash,oyun,strateji`
- Önce (EN): `reveal,puzzle,qix,volfied,jezzball,arcade,spider,pixel,area,capture,xonix,bix,paint`
- Sonra (EN): `territory,capture,arcade,puzzle,retro,neon,80s,maze,area,paint,pixel,classic,spider,dash`

### Description — iddia düzeltmeleri
- "Hundreds of levels" → **72 handcrafted levels across 6 themed image packs**
- Power-ups → **Freeze, Speed Boost and Shield**
- "Own photo" KALDIRILDI (UI stub, implement değil)
- "Weekly plan" + "3-day trial" KALDIRILDI → **Monthly and Yearly**
- Tüm `qix/volfied/jezzball/xonix` rakip markaları kaldırıldı → "classic 80s/90s territory-capture arcade"
- Tam metin: `aso_current/analysis_b_v2.md` § 1.4 / 1.5

### Kategori (bu da PENDING — review sırasında DOKUNMA)
- Mevcut: GAMES + ENTERTAINMENT
- Öneri: GAMES / Primary Sub **GAMES_PUZZLE**, Secondary Sub **GAMES_CASUAL** (NOT: GAMES_ARCADE Apple'da yok)

## Ne zaman uygulanır
1. Review durumu kesinleşir (approve/reject).
2. **Reject olursa:** metin düzeltmeleri uygulanıp 1.0.1 re-submit.
3. **Approve olursa:** 1.0 canlıya çıkar; kategori + ASC metin düzeltmeleri bir sonraki sürümle (1.1 veya aynı 1.0 Edit Metadata) uygulanır.
