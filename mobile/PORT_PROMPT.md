# PixReveal — Claude Design React Prototipini Flutter'a Port Etme

## CONTEXT

PixReveal, Qix/Gals Panic tarzı arcade puzzle oyunu. Flutter + Flame ile geliştiriliyor. Proje klasörü: `\~/projects/pixreveal/app/` (S1: 13.50.239.130).

Claude Design ile detaylı bir React HTML prototipi hazırladım. Bu prototipi Flutter'a **birebir** port edeceksin. Tüm asset'ler (PNG'ler) ve React component'leri hazır — ben sana yükleyeceğim.

## YÜKLENECEK DOSYALAR

Sana atacağım zip içinde:

```
pixreveal-design/
├── pixreveal/assets/              (11 adet PNG, 1024×1536)
│   ├── menu.png                   (ana menü — tarantula + PIXREVEAL logo + PLAY/SHOP/SETTINGS)
│   ├── categories.png             (kategori listesi — süper arabalar, derin uzay, vahşi hayvanlar, plaj, fitness, own image)
│   ├── levels.png                 (KULLANILMAYACAK — level seçim ekranı kod-tabanlı, aşağıda detay)
│   ├── hud.png                    (oyun içi HUD — kalpler, level, süre, skor, kapla%, joystick, power-up'lar, KAP butonu)
│   ├── hud-accent.png             (HUD ekstra element asset'i)
│   ├── gameover.png               (oyun bitti — tarantula + "OYUN BİTTİ" + USE TOKEN/WATCH AD/QUIT)
│   ├── victory.png                (zafer — 3 altın yıldız + skor + kombo + NEXT LEVEL/RETRY/MENU)
│   ├── shop.png                   (mağaza — bedava jeton, jeton paketleri, tema paketleri)
│   ├── paywall.png                (premium abone — PIXREVEAL+ kron, özellikler, AYLIK/YILLIK, ABONE OL)
│   ├── settings.png               (ayarlar — ses/müzik/titreşim toggle'lar, hesap bağla, satın almalar, yasal)
│   └── tarantula.png              (tarantula 3D render — oyun içinde ve gameover ekranında reuse edilecek)
│
├── app.jsx                        (ana React app — referans)
├── prototype.jsx                  (state machine + navigation — referans)
├── hotspots.jsx                   (tıklanabilir alan koordinatları — % bazlı, KRİTİK, aşağıda detay)
├── custom-screens.jsx             (Level Select + Gameplay Overlay — kod-tabanlı sahneler)
├── mockup-screen.jsx              (ekran render + overlay'ler — CountdownOverlay, JoystickOverlay, ToggleStateOverlay, PaywallPlanOverlay)
├── design-canvas.jsx              (artboard görünümü — referans)
└── index.html                     (prototip giriş — referans)
```

## NE YAPACAKSIN

Bu React prototipini **birebir** Flutter'a çevir. Korunacak şeyler:

1. **Asset'ler aynen kullanılacak** — `assets/images/` altına PNG'ler kopyalanacak, arka plan olarak.
2. **Hotspot koordinatları aynen kullanılacak** — `hotspots.jsx` dosyasındaki %-bazlı koordinatlar Flutter'da `Positioned` widget'ına çevrilecek.
3. **Level Select kod-tabanlı** — PNG değil, `custom-screens.jsx`'teki `LevelSelectScreen` ve `LevelCard` component'leri Flutter widget'ına çevrilecek (Star, LockIcon, PlayArrow custom painter).
4. **Gameplay Overlay kod-tabanlı** — HUD ve Countdown ekranlarında `GameplayOverlay` (captured territory polygon, trail, cursor, tarantula idle animation) CustomPainter ile çizilecek.
5. **Overlay'ler korunacak**:

   * `CountdownOverlay` — 3-2-1-GO! animasyonu (her biri 800ms, scale pop)
   * `JoystickOverlay` — HUD'da sol altta drag edilebilir joystick (koordinat: left 8%, bottom 9%, width 20%)
   * `ToggleStateOverlay` — Settings'te 3 toggle state yönetimi
   * `PaywallPlanOverlay` — Monthly vs Yearly highlight
6. **Dil desteği TR + EN** — i18next yerine Flutter `intl` kullan, default TR.

## KLASÖR YAPISI

```
\~/projects/pixreveal/app/lib/
├── main.dart
├── app.dart                              # MaterialApp + routing
├── routes.dart                           # go\_router config (prototype.jsx state machine'e denk)
├── theme/
│   ├── colors.dart                       # #0a0e27 bg, #00d4ff cyan, #ff006e pink, #ffd700 gold (MOR YOK!)
│   ├── typography.dart                   # Orbitron (başlıklar) + Inter (body)
│   └── dimensions.dart
├── screens/
│   ├── menu\_screen.dart                  # menu.png + hotspot'lar
│   ├── categories\_screen.dart            # categories.png + hotspot'lar
│   ├── levels\_screen.dart                # KOD-TABANLI (Star, LockIcon, PlayArrow, LevelCard)
│   ├── countdown\_screen.dart             # hud.png + GameplayOverlay + CountdownOverlay (3-2-1-GO)
│   ├── game\_screen.dart                  # hud.png + GameplayOverlay + JoystickOverlay (oyun içi HUD)
│   ├── victory\_screen.dart               # victory.png + hotspot'lar
│   ├── gameover\_screen.dart              # gameover.png + hotspot'lar
│   ├── shop\_screen.dart                  # shop.png + hotspot'lar (scroll'lu!)
│   ├── paywall\_screen.dart               # paywall.png + hotspot'lar + PaywallPlanOverlay
│   └── settings\_screen.dart              # settings.png + hotspot'lar + ToggleStateOverlay (scroll'lu!)
├── widgets/
│   ├── mockup\_screen.dart                # Ortak wrapper: arka plan PNG + hotspot Positioned'ları
│   ├── hotspot\_button.dart               # %-bazlı Positioned + InkWell
│   ├── phone\_frame.dart                  # (opsiyonel — sadece debug canvas için)
│   ├── level\_card.dart                   # Level Select kartı (done/next/locked state)
│   ├── star\_icon.dart                    # CustomPainter (gradient star)
│   ├── lock\_icon.dart                    # CustomPainter (altın lock)
│   ├── play\_arrow\_icon.dart              # CustomPainter (pembe play button)
│   ├── gameplay\_overlay.dart             # CustomPainter (captured territory + trail + cursor)
│   ├── joystick\_overlay.dart             # Drag edilebilir joystick
│   └── countdown\_overlay.dart            # 3-2-1-GO animasyonu
├── state/
│   ├── game\_state.dart                   # Riverpod: score, level, tokens, lives
│   ├── settings\_state.dart               # sfx/music/vibration toggle'ları
│   └── paywall\_state.dart                # monthly/yearly plan seçimi
├── l10n/
│   ├── app\_tr.arb                        # Türkçe metinler (default)
│   └── app\_en.arb                        # İngilizce metinler
└── constants/
    └── hotspots.dart                     # hotspots.jsx'ten birebir çevrilmiş Map
```

## HOTSPOT KOORDİNATLARI (hotspots.jsx'ten birebir)

Her ekran için %-bazlı koordinat listesi. Flutter'da `LayoutBuilder` + `Stack` + `Positioned` kullan:

```dart
// Örnek: menu ekranı
Positioned(
  left: MediaQuery.of(context).size.width \* 0.14,
  top: MediaQuery.of(context).size.height \* 0.565,
  width: MediaQuery.of(context).size.width \* 0.72,
  height: MediaQuery.of(context).size.height \* 0.062,
  child: GestureDetector(
    onTap: () => context.go('/categories'),
    child: Container(color: Colors.transparent),
  ),
)
```

**TÜM HOTSPOT HARITASI** (hotspots.jsx'ten aynen):

### menu

* coins: x=70, y=1.5, w=28, h=4.8 → shop
* play: x=14, y=56.5, w=72, h=6.2 → categories
* shop: x=26, y=66, w=48, h=4.3 → shop
* settings: x=26, y=72.3, w=48, h=4.3 → settings

### categories

* cat-cars: x=6, y=13.5, w=88, h=9 → levels (Super Cars)
* cat-space: x=6, y=23.8, w=88, h=9 → levels (Deep Space)
* cat-animals: x=6, y=34.1, w=88, h=9 → paywall (premium)
* cat-beach: x=6, y=44.4, w=88, h=9 → paywall (premium)
* cat-fitness: x=6, y=54.7, w=88, h=9 → levels
* cat-own: x=17, y=89, w=66, h=5.2 → paywall (Your Own Image)

### levels (KOD-TABANLI, hotspot yok — her LevelCard tıklanabilir)

* 12 level, 3 sütunlu grid
* Level 1-3: done (yıldız sayısı: 3, 2, 3) → tap → countdown
* Level 4: next (SIRA SENDE badge, pembe) → tap → countdown
* Level 5-12: locked → tap → paywall

### hud (oyun içi — simülasyon için)

* pu-brush: x=81, y=29.5, w=14, h=7.5 (power-up, no-nav)
* pu-bolt: x=81, y=42.5, w=14, h=7.5 (power-up, no-nav)
* pu-bomb: x=81, y=55.5, w=14, h=7.5 (power-up, no-nav)
* sim-win: x=36, y=8.5, w=28, h=4 → victory (test)
* sim-lose: x=2, y=65, w=5, h=30 → gameover (test)

### gameover

* use-token: x=14, y=62.5, w=72, h=6.5 → hud
* watch-ad: x=14, y=71.5, w=72, h=6.5 → hud
* quit: x=32, y=81.5, w=36, h=5 → menu

### victory

* next: x=14, y=75, w=72, h=6.5 → levels
* retry: x=16, y=84, w=32, h=4.5 → hud
* menu: x=52, y=84, w=32, h=4.5 → menu

### shop (SCROLL'LU!)

* watch-ad: x=52, y=7.5, w=38, h=6 (no-nav)
* pack-20: x=6, y=23, w=28, h=14 (IAP)
* pack-50: x=36, y=23, w=28, h=14 (IAP)
* pack-120: x=66, y=23, w=28, h=14 (IAP)
* theme-cars: x=8, y=45, w=18, h=12 (no-nav)
* theme-space: x=29, y=45, w=18, h=12 (no-nav)
* theme-anim: x=50, y=45, w=18, h=12 (no-nav)
* theme-beach: x=8, y=60, w=18, h=12 (no-nav)
* theme-lock: x=29, y=60, w=18, h=12 → paywall
* back: x=0, y=92, w=100, h=8 → menu

### paywall

* close: x=85, y=2, w=12, h=6 → menu
* monthly: x=8, y=29, w=38, h=10 (plan toggle)
* yearly: x=50, y=29, w=42, h=10 (plan toggle)
* restore: x=30, y=42, w=40, h=3.5 (no-nav)
* subscribe: x=14, y=47, w=72, h=6 → menu (IAP sonrası)

### settings (SCROLL'LU!)

* sfx: x=78, y=14, w=17, h=5 (toggle)
* music: x=78, y=20.5, w=17, h=5 (toggle)
* vibe: x=78, y=27, w=17, h=5 (toggle)
* link: x=20, y=44, w=60, h=6 (auth)
* restore: x=14, y=61, w=72, h=6 (IAP restore)
* privacy: x=6, y=74, w=88, h=4.5 (URL launch)
* terms: x=6, y=80, w=88, h=4.5 (URL launch)
* back: x=0, y=92, w=100, h=8 → menu

### countdown

* full screen tap (veya otomatik 3-2-1-GO sonrası) → hud

## RENK PALETİ (KESIN, MOR YOK!)

```dart
const Color bgDark = Color(0xFF0A0E27);       // Ana arka plan
const Color bgDarker = Color(0xFF1A0F2E);     // Gradient alt
const Color neonCyan = Color(0xFF00D4FF);     // Primary accent
const Color neonPink = Color(0xFFFF006E);     // Secondary accent
const Color gold = Color(0xFFFFD700);         // Tertiary (jetonlar, yıldızlar)
const Color goldDeep = Color(0xFFB8860B);     // Gold gradient alt
// MOR/PURPLE KULLANILMAYACAK. Gradient'lerde bile cyan → pink direkt geçsin.
```

## TİPOGRAFİ

```dart
// Başlıklar (PIXREVEAL logo, LEVEL, ZAFER, OYUN BİTTİ):
'Orbitron' — weight 900, letterSpacing 1-3

// Body (buton metinleri, açıklamalar):
'Inter' — weight 400-700
```

Font'ları `pubspec.yaml`'a ekle, `assets/fonts/` altına koy.

## LEVEL SELECT KOD (custom-screens.jsx'ten Flutter'a)

**Header** (üstte ortada):

* "SUPER CARS" yazısı
* Orbitron 900, 28px, letterSpacing 3
* Cyan text + cyan border (2px) + cyan inner glow
* Border radius 12, padding 10px 28px

**Grid** (3 sütun, 12 level):

* GridView.count(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1/1.05)
* Padding: 40px top, 20px side, 30px bottom

**LevelCard state'leri**:

1. **Done** (level 1-3): cyan border (rgba(0,212,255,.7)), cyan glow, yıldız gösterimi (3'lük yıldız)
2. **Next** (level 4): pembe border (#ff006e), pembe glow, "SIRA SENDE" pembe badge ÜSTTE (top -10), PlayArrow ortada
3. **Locked** (level 5-12): gri border (rgba(100,120,180,.3)), LockIcon (altın)

**Star**: gradient altın (#ffe066 → #ff9500), stroke #ffc04d, dolu ise drop-shadow(0 0 3px rgba(255,200,0,.7))
**Lock**: gradient altın (#ffd700 → #b8860b), stroke #8b6508, keyhole detayı
**PlayArrow**: pembe daire (#ff4d9f → #ff006e), beyaz border, drop-shadow(0 0 6px rgba(255,0,110,.7))

## GAMEPLAY OVERLAY KOD (custom-screens.jsx'ten Flutter'a)

HUD ve Countdown ekranlarında PNG'nin ÜZERİNE overlay olarak çizilecek. Alan: left 2%, right 2%, top 7%, bottom 7%.

**Katmanlar** (alttan üste):

1. **Arka plan kategori resmi** — bulanık, karartılmış araba fotoğrafı (şimdilik placeholder: Container with gradient; gerçekte kategori asset'i olacak)
2. **Karartma katmanı** — radial gradient, merkez şeffaf, kenar koyu
3. **Captured territory polygon** — SVG polygon → Flutter CustomPainter Path

   * Koordinatlar (viewBox 100x100): `0,0 100,0 100,28 62,28 62,54 26,54 26,100 0,100`
   * Fill: linear gradient cyan (.28) → pink (.35)
   * Stroke: cyan (#00d4ff), width 0.4 (ölçekle)
   * Drop shadow cyan
4. **Trail (polyline L-şekli)** — koordinatlar: `84,92 → 84,72 → 54,72`

   * Stroke: linear gradient pink → cyan
   * Glow: drop-shadow(0 0 4px pink) drop-shadow(0 0 8px cyan)
5. **Trail ucu animasyonu** — dashed line, stroke-dashoffset animation (600ms loop)
6. **%45.2 progress rakamı** — sol üst (left 10%, top 10%), Orbitron 11px, cyan, text-shadow glow
7. **Tarantula** — `Image.asset('assets/images/tarantula.png')`, left 32%, top 30%, width 30%, drop-shadow kırmızı + siyah, idle animation (4s ease-in-out: translateY 0↔-4, rotate -1°↔1°)
8. **Oyuncu cursor** — 14×14 square, 45° rotated (elmas), gradient cyan glow, pulse animation (800ms: box-shadow 12px↔18px)

## COUNTDOWN OVERLAY

* Tam ekran radial gradient karartma
* 3 → 2 → 1 → GO! (her biri 800ms)
* 3/2/1: cyan #00d4ff, 180px, Orbitron 900

  * text-shadow: 0 0 20px cyan, 0 0 40px cyan, 0 0 80px blue
* GO!: gold #ffd700, 80px, letterSpacing 4

  * text-shadow: 0 0 20px gold, 0 0 40px orange, 0 0 80px pink
* Animation: scale(2.4) opacity(0) → scale(1) opacity(1) → scale(0.6) opacity(0)

## JOYSTICK OVERLAY

* Position: left 8%, bottom 9%, width 20%, aspectRatio 1
* Drag edilebilir çember (max 55% hareket)
* Active iken cyan glow halkası (0 0 30px rgba(0,212,255,.6))
* Merkez topak: radial gradient (beyaz → mavi-gri → koyu lacivert), inner shadow
* Pointer events: touch + drag, ups bırakınca merkeze dönüş (cubic-bezier(.2,.8,.4,1), 200ms)

## TÜRKÇE METINLER (default dil TR)

```arb
// app\_tr.arb
{
  "play": "OYNA",
  "shop": "MAĞAZA",
  "settings": "AYARLAR",
  "premium": "PREMİUM",
  "categorySelect": "KATEGORİ SEÇ",
  "superCars": "SÜPER ARABALAR",
  "deepSpace": "DERİN UZAY",
  "wildAnimals": "VAHŞİ HAYVANLAR",
  "beachGlamour": "PLAJ GLAMOUR",
  "fitness": "FITNESS",
  "yourOwnImage": "KENDİ FOTOĞRAFIN",
  "victory": "ZAFER!",
  "gameOver": "OYUN BİTTİ",
  "continueQ": "Devam Edelim mi?",
  "useToken": "1 JETON KULLAN",
  "watchAd": "REKLAM İZLE",
  "quit": "ÇIK",
  "nextLevel": "SONRAKİ LEVEL",
  "retry": "TEKRAR DENE",
  "menu": "MENÜ",
  "score": "SKOR",
  "level": "LEVEL",
  "time": "SÜRE",
  "fill": "KAPLA",
  "comboBonus": "KOMBO BONUS",
  "goPremium": "PREMIUM OL",
  "subscribe": "ABONE OL",
  "monthly": "AYLIK",
  "yearly": "YILLIK",
  "restorePurchases": "SATIN ALMALARI GERİ YÜKLE",
  "soundEffects": "Ses Efektleri",
  "music": "Müzik",
  "vibration": "Titreşim",
  "linkAccount": "HESAP BAĞLA",
  "privacyPolicy": "Gizlilik Politikası",
  "termsOfService": "Kullanım Şartları",
  "support": "Destek",
  "notifications": "Bildirimler",
  "language": "Dil",
  "yourTurn": "SIRA SENDE",
  "go": "BAŞLA",
  "freeTokens": "BEDAVA JETON",
  "tokenPacks": "JETON PAKETLERİ",
  "themePacks": "PREMIUM TEMALAR"
}
```

## SCROLL KRİTİK

`shop\_screen.dart` ve `settings\_screen.dart` mutlaka `SingleChildScrollView` ile sarılacak. PNG yüksekliği ekran yüksekliğinden uzun, kırpılmamalı. Hotspot'lar da scroll içinde kalacak.

## TEKNİK GEREKSİNİMLER

```yaml
# pubspec.yaml eklemeleri
dependencies:
  flutter:
    sdk: flutter
  flutter\_localizations:
    sdk: flutter
  flame: ^1.18.0
  flame\_audio: ^2.10.0
  flutter\_riverpod: ^2.5.0
  google\_mobile\_ads: ^5.1.0
  purchases\_flutter: ^7.0.0
  firebase\_core: ^3.0.0
  firebase\_auth: ^5.0.0
  firebase\_analytics: ^11.0.0
  firebase\_messaging: ^15.0.0
  go\_router: ^14.0.0
  flutter\_animate: ^4.5.0
  intl: any
  shared\_preferences: ^2.3.0
  google\_fonts: ^6.2.1

flutter:
  uses-material-app: true
  generate: true
  assets:
    - assets/images/
  fonts:
    - family: Orbitron
      fonts:
        - asset: assets/fonts/Orbitron-Regular.ttf
        - asset: assets/fonts/Orbitron-Bold.ttf
          weight: 700
        - asset: assets/fonts/Orbitron-Black.ttf
          weight: 900
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

Font'ları google\_fonts ile indirmek yerine direkt asset olarak kullan (offline çalışsın).

## NAVIGATION GRAPH (prototype.jsx'ten)

```
menu → categories, shop, settings
categories → levels (free), paywall (premium)
levels → countdown (oynanabilir), paywall (locked)
countdown → hud (otomatik, 3-2-1-GO sonrası)
hud → victory (win), gameover (lose)
victory → levels (next), hud (retry), menu (menu)
gameover → hud (use token / watch ad), menu (quit)
shop → paywall (locked theme), menu (back)
paywall → menu (close, subscribe)
settings → menu (back)
```

go\_router ile implement et.

## SIRAYLA NE YAPACAKSIN

1. S1'e SSH: `ssh ubuntu@13.50.239.130`
2. `cd \~/projects/pixreveal/app/` (proje zaten kurulu, değilse `flutter create --org com.cytbilisim --project-name pixreveal .`)
3. `pubspec.yaml`'ı yukarıdaki gereksinimlere göre güncelle
4. `assets/images/` klasörüne yukarıdaki 11 PNG'yi kopyala (sana verdiğim zip'ten)
5. `assets/fonts/` klasörüne Orbitron + Inter font'larını indir (Google Fonts)
6. `lib/` altında yukarıdaki klasör yapısını kur
7. Her ekranı sırayla implement et:

   * menu\_screen (en kolay, referans)
   * categories\_screen
   * levels\_screen (kod-tabanlı, LevelCard + Star/Lock/PlayArrow CustomPainter)
   * countdown\_screen (CountdownOverlay)
   * game\_screen (GameplayOverlay + JoystickOverlay — bu en zor)
   * victory\_screen
   * gameover\_screen
   * shop\_screen (scroll!)
   * paywall\_screen (PaywallPlanOverlay)
   * settings\_screen (scroll! + ToggleStateOverlay + Riverpod state)
8. l10n kurulumu: TR default + EN
9. go\_router navigation graph
10. `flutter analyze` 0 error
11. `flutter run` ile test et (emulator veya telefonda)



FONT KURULUMU:



google\_fonts paketini kullan (pubspec.yaml'a zaten ekli olacak: google\_fonts: ^6.2.1). 

Local'de .ttf dosyası İNDİRME, GoogleFonts.orbitron() ve GoogleFonts.inter() kullan.



Örnek:

import 'package:google\_fonts/google\_fonts.dart';



Text(

&#x20; 'PIXREVEAL',

&#x20; style: GoogleFonts.orbitron(

&#x20;   fontSize: 48,

&#x20;   fontWeight: FontWeight.w900,

&#x20;   letterSpacing: 3,

&#x20;   color: Color(0xFF00D4FF),

&#x20; ),

)



lib/theme/typography.dart'ta şu şekilde tanımla:



import 'package:flutter/material.dart';

import 'package:google\_fonts/google\_fonts.dart';



class AppTypography {

&#x20; static TextStyle heading({double size = 24, Color? color, double letterSpacing = 2}) =>

&#x20;     GoogleFonts.orbitron(

&#x20;       fontSize: size,

&#x20;       fontWeight: FontWeight.w900,

&#x20;       letterSpacing: letterSpacing,

&#x20;       color: color ?? Colors.white,

&#x20;     );

&#x20; 

&#x20; static TextStyle body({double size = 14, Color? color, FontWeight weight = FontWeight.w400}) =>

&#x20;     GoogleFonts.inter(

&#x20;       fontSize: size,

&#x20;       fontWeight: weight,

&#x20;       color: color ?? Colors.white,

&#x20;     );

&#x20; 

&#x20; static TextStyle button({double size = 16, Color? color}) =>

&#x20;     GoogleFonts.inter(

&#x20;       fontSize: size,

&#x20;       fontWeight: FontWeight.w700,

&#x20;       letterSpacing: 1.2,

&#x20;       color: color ?? Colors.white,

&#x20;     );

}



pubspec.yaml'dan fonts: bloğunu KALDIR, sadece google\_fonts: ^6.2.1 kalsın dependencies'de.



İlk çalıştırmada internet gerekir (font cache'e iner), sonra offline çalışır. Offline-first şart değil PixReveal için.



Kaynak dosyalar C:\\Users\\ickmk\\Desktop\\pixreveal\\design-files\\ altında.



\- PNG asset'leri oradan ./assets/images/ altına kopyala

\- JSX dosyalarını SADECE REFERANS olarak oku — Flutter koduna çevir, JSX'leri projeye dahil etme

\- Mevcut lib/ klasöründeki eski PixReveal kodunu temizle (Git commit'ini al önce), yeniden bu prompt'a göre kur

\- flutter pub get → flutter analyze → 0 error olana kadar çalış

\- Her ekranı bitirdiğinde "✅ menu\_screen bitti" gibi progress ver

\- En sonda flutter run ile emulator'da çalıştır, her ekranı gez, ekran görüntüsü al



SSH'a GEREK YOK — her şey local'de yapılacak. S1'e push işini sonra git ile hallederiz.



Başla.



## ÖNEMLİ

* **MOR/PURPLE KESİNLİKLE YOK** — gradient'lerde bile cyan→pink direkt geçsin
* Tüm hotspot koordinatları `MediaQuery` ile %-bazlı olacak
* Asset'ler `BoxFit.cover` değil `BoxFit.contain` (aspect ratio 2:3 korunacak, phone frame zaten aynı ratio)
* Animasyonlar `flutter\_animate` paketiyle, süreler ve curve'ler yukarıdaki tabloya birebir uysun
* `flutter analyze` 0 error, 0 warning olana kadar bitti sayma

Bitince bana ekran görüntüsü at, her ekranı ayrı ayrı göster. Sorun varsa çözüm için gel.





