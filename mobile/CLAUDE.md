# PixReveal — Proje Durumu

## Mimari
- Flutter + Flame engine (pixreveal_game.dart ÇALIŞIR, Player/Spider/Trail/Territory hazır)
- PNG'ler arka plan (menu/categories/shop/settings/paywall/victory/gameover.png 1024x1536)
- Üstüne şeffaf hotspot GestureDetector'lar + dinamik overlay'ler
- MockupScreen widget: BoxFit.cover topCenter, AspectRatio YOK
- calibrateMode: true → tıklama noktalarını console'a yazar (debug için)

## Kalibre edilmiş hotspot'lar (hotspots.dart)
- MENU: coins(64,0,36,6) play(18,49,64,11) shop(22,64,56,8) settings(22,73,56,8)
- CATEGORIES: cars y=24.7, space y=38.5, animals y=51.3, beach y=65.8, fitness y=79.6, own y=91.9
- SHOP: watch-ad y=13, packs y=29, themes y=52 ve y=66
- SETTINGS sağ taraf x=78, y'ler: sfx 24.4, music 30.3, vibe 35.8, link 52.9, restore 66.85, privacy 78.9, terms 84.25
- VICTORY/PAYWALL: KALİBRE EDİLDİ ✓

## Kategori kilit durumu
- Açık: cars, space, animals
- Premium: beach, fitness, ownImage
- GameCategory enum assetKey: animals→'animal', beach→'glamour' (asset dosya adı için)

## Asset klasörü
- assets/images/: cars_1.jpg...cars_26.jpg, space_1-11, animal_1-11, glamour_1-11, fitness_1-11
- assets/audio/: button_click/capture/die/level_complete/token_insert/trail_draw.wav
- pixreveal-design/ klasörü REFERANS (JSX), build'e dahil DEĞİL

## Flow
- Menu→Categories→(Super Cars/Space/Animals tıkla → /levels)
- Levels (SharedPreferences highest_unlocked_level, ilk 3 açık)
- Level tıkla → /countdown?level=N → 3-2-1-GO → /hud?level=N (Flame game)
- Game: onWin→markCompleted→/victory?level=N, onLose→/gameover?level=N
- Victory NEXT→level+1, RETRY→same level, MENU→/menu

## TAMAMLANAN İŞLER
- Settings toggle overlay: siyah mask sistemi kuruldu ✓
- Victory hotspot kalibrasyonu: tamamlandı ✓
- SnackBar: floating + margin + cyan border + dark bg ✓
- Victory kategori resmi overlay ✓

## KALAN İŞLER
1. Menü coin badge: PNG'deki static badge zemini silindi, Flutter dinamik badge bekleniyor (FIX IN PROGRESS)
2. Game Over "USE 1 TOKEN": PNG yazısı tam silinmedi, Flutter overlay çakışıyor (FIX IN PROGRESS)
3. Paywall offerings: Play Console'a APK yüklenince test edilecek

## Önemli
- MOR YOK (cyan #00D4FF + pembe #ff006e + altın #ffd700 + lacivert)
- AspectRatio kullanılmıyor MockupScreen'de (tam ekran kullanıyoruz)
- Tool dışı klasörler silindi (pixreveal-fix/, pixreveal-v2/, pixreveal-master/, pixreveal-nomore/, pixreveal-coords/, hotspots-calibrated/ vb.)
- Level ilerlemesi SharedPreferences'da kalıcı