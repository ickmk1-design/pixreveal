class Hotspot {
  final String id;
  final double x, y, w, h;
  final String target;
  final String label;

  const Hotspot({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.target,
    required this.label,
  });
}

/// FULLY CALIBRATED from live user tap data. Each y/x value has been
/// derived from the actual tap coordinates Ibo provided after tapping
/// the exact center of each button.
const Map<String, List<Hotspot>> kHotspots = {
  // ─── MENU EN — gerçek cihaz kalibrasyonu (TR ile aynı PNG)
  'menu': [
    Hotspot(id: 'coins',    x: 64, y: 0,    w: 36, h: 6,  target: 'shop',       label: 'Jeton'),
    Hotspot(id: 'play',     x: 8,  y: 50.3, w: 84, h: 11, target: 'categories', label: 'PLAY'),
    Hotspot(id: 'shop',     x: 8,  y: 62.4, w: 84, h: 11, target: 'shop',       label: 'SHOP'),
    Hotspot(id: 'settings', x: 8,  y: 71.1, w: 84, h: 11, target: 'settings',   label: 'SETTINGS'),
  ],

  // ─── MENU TR — gerçek iPhone kalibrasyonu 2026-08-28
  // OYNA merkez y=55.3, MAĞAZA y=67.4, AYARLAR y=76.1
  'menu_tr': [
    Hotspot(id: 'coins',    x: 64, y: 0,    w: 36, h: 6,  target: 'shop',       label: 'Jeton'),
    Hotspot(id: 'play',     x: 8,  y: 50.3, w: 84, h: 11, target: 'categories', label: 'OYNA'),
    Hotspot(id: 'shop',     x: 8,  y: 62.4, w: 84, h: 11, target: 'shop',       label: 'MAĞAZA'),
    Hotspot(id: 'settings', x: 8,  y: 71.1, w: 84, h: 11, target: 'settings',   label: 'AYARLAR'),
  ],

  // categories: native ekrana geçildi — hotspot listesi kaldırıldı (kalibrasyon yok).

  // ─── HUD (power-ups, right column) ────────────────────────────
  'hud': [
    Hotspot(id: 'pu-freeze', x: 81, y: 29.5, w: 14, h: 7.5, target: 'none', label: 'Freeze'),
    Hotspot(id: 'pu-speed',  x: 81, y: 42.5, w: 14, h: 7.5, target: 'none', label: 'Speed'),
    Hotspot(id: 'pu-shield', x: 81, y: 55.5, w: 14, h: 7.5, target: 'none', label: 'Shield'),
  ],

  // ─── GAME OVER EN — gerçek iPhone kalibrasyonu 2026-08-28
  // turuncu kutu merkez y=62.5, reklam izle y=73.6
  'gameover': [
    Hotspot(id: 'use-token', x: 8, y: 57,   w: 84, h: 11, target: 'retry', label: '1 JETON'),
    Hotspot(id: 'watch-ad',  x: 8, y: 68.5, w: 84, h: 10, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 20, y: 80,  w: 60, h: 8,  target: 'menu',  label: 'ÇIK'),
  ],

  // ─── GAME OVER TR — gerçek iPhone ile aynı PNG, aynı koordinatlar
  'gameover_tr': [
    Hotspot(id: 'use-token', x: 8, y: 57,   w: 84, h: 11, target: 'retry', label: '5 TOKEN'),
    Hotspot(id: 'watch-ad',  x: 8, y: 68.5, w: 84, h: 10, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 20, y: 80,  w: 60, h: 8,  target: 'menu',  label: 'ÇIK'),
  ],

  // ─── VICTORY EN — gerçek iPhone kalibrasyonu 2026-08-28
  // next merkez y=78.7, retry y=86.6 x=32.4, menu y=87.5 x=63.3
  'victory': [
    Hotspot(id: 'next',  x: 8,  y: 73.7, w: 84, h: 10, target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 15, y: 82,   w: 35, h: 10, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 50, y: 82,   w: 35, h: 10, target: 'menu',       label: 'MENÜ'),
  ],

  // ─── VICTORY TR — aynı PNG, aynı koordinatlar
  'victory_tr': [
    Hotspot(id: 'next',  x: 8,  y: 73.7, w: 84, h: 10, target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 15, y: 82,   w: 35, h: 10, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 50, y: 82,   w: 35, h: 10, target: 'menu',       label: 'MENÜ'),
  ],

  // ─── SHOP (new design: 5 token packs + 4 themes) ─────────────
  'shop': [
    Hotspot(id: 'watch-ad',    x: 50, y: 8,  w: 44, h: 9,  target: 'none',    label: 'REKLAM'),
    Hotspot(id: 'pack-20',     x: 2,  y: 23, w: 31, h: 18, target: 'none',    label: '20'),
    Hotspot(id: 'pack-50',     x: 35, y: 23, w: 30, h: 18, target: 'none',    label: '50'),
    Hotspot(id: 'pack-120',    x: 67, y: 23, w: 31, h: 18, target: 'none',    label: '120'),
    Hotspot(id: 'pack-300',    x: 2,  y: 43, w: 46, h: 18, target: 'none',    label: '300'),
    Hotspot(id: 'pack-750',    x: 51, y: 43, w: 47, h: 18, target: 'none',    label: '750'),
    Hotspot(id: 'theme-cars',  x: 1,  y: 65, w: 24, h: 22, target: 'none',    label: 'Cars'),
    Hotspot(id: 'theme-space', x: 26, y: 65, w: 23, h: 22, target: 'none',    label: 'Space'),
    Hotspot(id: 'theme-anim',  x: 50, y: 65, w: 24, h: 22, target: 'none',    label: 'Animals'),
    Hotspot(id: 'theme-beach', x: 75, y: 65, w: 24, h: 22, target: 'none',    label: 'Beach'),
  ],

  // ─── PAYWALL — gerçek iPhone kalibrasyonu 2026-08-28
  // restore merkez y=74.9, subscribe merkez y=82.5
  'paywall': [
    Hotspot(id: 'monthly',   x: 2,  y: 57, w: 44, h: 15, target: 'none', label: 'AYLIK'),
    Hotspot(id: 'yearly',    x: 50, y: 53, w: 47, h: 19, target: 'none', label: 'YILLIK'),
    Hotspot(id: 'restore',   x: 8,  y: 72, w: 84, h: 6,  target: 'none', label: 'Restore'),
    Hotspot(id: 'subscribe', x: 8,  y: 78, w: 84, h: 10, target: 'none', label: 'ABONE'),
  ],

  // ─── SETTINGS (new design 2026-06-28) ────────────────────────
  'settings': [
    Hotspot(id: 'sfx',     x: 5, y: 26.3, w: 90, h: 8, target: 'toggle-sfx',       label: 'SFX'),
    Hotspot(id: 'music',   x: 5, y: 34.4, w: 90, h: 8, target: 'toggle-music',     label: 'Music'),
    Hotspot(id: 'vibe',    x: 5, y: 42.6, w: 90, h: 8, target: 'toggle-vibration', label: 'Vibe'),
    Hotspot(id: 'restore', x: 6,  y: 58, w: 88, h: 8, target: 'none',             label: 'Restore'),
    Hotspot(id: 'privacy', x: 4,  y: 73, w: 92, h: 7, target: 'none',             label: 'Privacy'),
    Hotspot(id: 'terms',   x: 4,  y: 81, w: 92, h: 8, target: 'none',             label: 'Terms'),
  ],

  'countdown': [],
};
