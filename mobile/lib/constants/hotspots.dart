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
  // ─── MENU ─────────────────────────────────────────────────────
  // play center y=54.5, shop y=67.5, settings y=76.3, coin y=2.5
  'menu': [
    Hotspot(id: 'coins',    x: 64, y: 0,   w: 36, h: 6,  target: 'shop',       label: 'Jeton'),
    Hotspot(id: 'play',     x: 18, y: 49,  w: 64, h: 11, target: 'categories', label: 'OYNA'),
    Hotspot(id: 'shop',     x: 22, y: 64,  w: 56, h: 8,  target: 'shop',       label: 'MAĞAZA'),
    Hotspot(id: 'settings', x: 22, y: 73,  w: 56, h: 8,  target: 'settings',   label: 'AYARLAR'),
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

  // ─── GAME OVER TR (orange buton y=62-72, blue y=73-83, çıkış y=85-91)
  'gameover_tr': [
    Hotspot(id: 'use-token', x: 8,  y: 62, w: 84, h: 10, target: 'retry', label: '5 TOKEN'),
    Hotspot(id: 'watch-ad',  x: 8,  y: 73, w: 84, h: 10, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 25, y: 85, w: 50, h:  6, target: 'menu',  label: 'ÇIK'),
  ],

  // ─── VICTORY (calibrated 2026-06-25) ─────────────────────────
  // next: center x=40.8, y=79.1 | retry: center x=32.8, y=88.0 | menu: center x=62.1, y=87.7
  'victory': [
    Hotspot(id: 'next',  x: 8,    y: 75.5, w: 66, h: 7.5, target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 18,   y: 84.5, w: 30, h: 7.0, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 48,   y: 84.5, w: 30, h: 7.0, target: 'menu',       label: 'MENÜ'),
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

  // ─── PAYWALL (new design — no X in PNG, Flutter button added) ─
  'paywall': [
    Hotspot(id: 'monthly',   x: 4,  y: 41, w: 43, h: 14, target: 'none', label: 'AYLIK'),
    Hotspot(id: 'yearly',    x: 51, y: 41, w: 44, h: 14, target: 'none', label: 'YILLIK'),
    Hotspot(id: 'restore',   x: 22, y: 57, w: 56, h: 4,  target: 'none', label: 'Restore'),
    Hotspot(id: 'subscribe', x: 14, y: 63, w: 72, h: 9,  target: 'none', label: 'ABONE'),
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
