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

  // ─── GAME OVER EN ─────────────────────────────────────────────
  'gameover': [
    Hotspot(id: 'use-token', x: 14, y: 54, w: 72, h: 9, target: 'retry', label: '1 JETON'),
    Hotspot(id: 'watch-ad',  x: 14, y: 65, w: 72, h: 9, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 28, y: 77, w: 44, h: 6, target: 'menu',  label: 'ÇIK'),
  ],

  // ─── GAME OVER TR (PIL ölçüm: orange 50-71, blue 70-80, quit 82-91)
  'gameover_tr': [
    Hotspot(id: 'use-token', x: 8,  y: 50, w: 84, h: 22, target: 'retry', label: '5 TOKEN'),
    Hotspot(id: 'watch-ad',  x: 8,  y: 70, w: 84, h: 11, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 20, y: 82, w: 60, h: 10, target: 'menu',  label: 'ÇIK'),
  ],

  // ─── VICTORY EN (PIL: SONRAKİ pink 76-82, TEKRAR/MENÜ white 87) ───
  'victory': [
    Hotspot(id: 'next',  x: 8,  y: 74,   w: 66, h: 10,  target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 18, y: 84,   w: 30, h: 8.0, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 48, y: 84,   w: 30, h: 8.0, target: 'menu',       label: 'MENÜ'),
  ],

  // ─── VICTORY TR (PIL: SONRAKİ pink 78-85, TEKRAR/MENÜ white 90-92) ─
  'victory_tr': [
    Hotspot(id: 'next',  x: 8,  y: 76,   w: 66, h: 12,  target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 18, y: 87,   w: 30, h: 8.0, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 48, y: 87,   w: 30, h: 8.0, target: 'menu',       label: 'MENÜ'),
  ],

  // ─── SHOP (new design: 5 token packs + 4 themes) ─────────────
  'shop': [
    Hotspot(id: 'watch-ad',    x: 50, y: 8,  w: 44, h: 9,  target: 'none',    label: 'REKLAM'),
    Hotspot(id: 'pack-20',     x: 2,  y: 23, w: 31, h: 18, target: 'none',    label: '20'),
    Hotspot(id: 'pack-50',     x: 35, y: 23, w: 30, h: 18, target: 'none',    label: '50'),
    Hotspot(id: 'pack-120',    x: 67, y: 23, w: 31, h: 18, target: 'none',    label: '120'),
    Hotspot(id: 'pack-300',    x: 2,  y: 43, w: 46, h: 18, target: 'none',    label: '300'),
    Hotspot(id: 'pack-750',    x: 51, y: 43, w: 47, h: 18, target: 'none',    label: '750'),
    Hotspot(id: 'theme-cars',  x: 1,  y: 67, w: 24, h: 18, target: 'none',    label: 'Cars'),
    Hotspot(id: 'theme-space', x: 26, y: 67, w: 23, h: 18, target: 'none',    label: 'Space'),
    Hotspot(id: 'theme-anim',  x: 50, y: 67, w: 24, h: 18, target: 'none',    label: 'Animals'),
    Hotspot(id: 'theme-beach', x: 75, y: 67, w: 24, h: 18, target: 'none',    label: 'Beach'),
  ],

  // ─── PAYWALL — Reveal Zone PNG: boxes y=57-72, restore y=74-79, subscribe y=79-89
  // monthly box x=2-46, yearly box x=50-97 (yearly has RECOMMENDED badge at y=53-57)
  'paywall': [
    Hotspot(id: 'monthly',   x: 2,  y: 57, w: 44, h: 15, target: 'none', label: 'AYLIK'),
    Hotspot(id: 'yearly',    x: 50, y: 53, w: 47, h: 19, target: 'none', label: 'YILLIK'),
    Hotspot(id: 'restore',   x: 15, y: 74, w: 70, h: 5,  target: 'none', label: 'Restore'),
    Hotspot(id: 'subscribe', x: 8,  y: 79, w: 84, h: 10, target: 'none', label: 'ABONE'),
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
