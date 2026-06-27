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

  // ─── GAME OVER (estimate — Ibo couldn't test live) ────────────
  'gameover': [
    Hotspot(id: 'use-token', x: 14, y: 54, w: 72, h: 9, target: 'retry', label: '1 JETON'),
    Hotspot(id: 'watch-ad',  x: 14, y: 65, w: 72, h: 9, target: 'retry', label: 'REKLAM'),
    Hotspot(id: 'quit',      x: 28, y: 77, w: 44, h: 6, target: 'menu',  label: 'ÇIK'),
  ],

  // ─── VICTORY (calibrated 2026-06-25) ─────────────────────────
  // next: center x=40.8, y=79.1 | retry: center x=32.8, y=88.0 | menu: center x=62.1, y=87.7
  'victory': [
    Hotspot(id: 'next',  x: 8,    y: 75.5, w: 66, h: 7.5, target: 'next-level', label: 'SONRAKİ'),
    Hotspot(id: 'retry', x: 18,   y: 84.5, w: 30, h: 7.0, target: 'retry',      label: 'TEKRAR'),
    Hotspot(id: 'menu',  x: 48,   y: 84.5, w: 30, h: 7.0, target: 'menu',       label: 'MENÜ'),
  ],

  // ─── SHOP ─────────────────────────────────────────────────────
  // watch-ad: x=43.6, y=16.2
  // pack-20: x=18.7, y=35 (average of top/bottom clicks)
  // pack-50: x=49, y=35
  // pack-120: x=75.6, y=35.5
  // theme-cars: x=14.6, y=58.5
  // theme-space: x=32.3, y=57.7
  // theme-animals: x=52.6, y=57.9
  // theme-beach: x=12.3, y=72.9
  // theme-lock: x=31.3, y=72.1
  'shop': [
    Hotspot(id: 'watch-ad',    x: 30, y: 13, w: 30, h: 7, target: 'none',    label: 'REKLAM'),
    Hotspot(id: 'pack-20',     x: 6,  y: 29, w: 22, h: 12, target: 'none',   label: '20'),
    Hotspot(id: 'pack-50',     x: 36, y: 29, w: 22, h: 12, target: 'none',   label: '50'),
    Hotspot(id: 'pack-120',    x: 64, y: 29, w: 22, h: 12, target: 'none',   label: '120'),
    Hotspot(id: 'theme-cars',  x: 4,  y: 52, w: 20, h: 12, target: 'none',   label: 'Cars'),
    Hotspot(id: 'theme-space', x: 22, y: 52, w: 20, h: 12, target: 'none',   label: 'Space'),
    Hotspot(id: 'theme-anim',  x: 42, y: 52, w: 20, h: 12, target: 'none',   label: 'Animals'),
    Hotspot(id: 'theme-beach', x: 2,  y: 66, w: 20, h: 12, target: 'none',   label: 'Beach'),
    Hotspot(id: 'theme-lock',  x: 22, y: 66, w: 20, h: 12, target: 'paywall', label: 'Kilit'),
  ],

  // ─── PAYWALL (calibrated 2026-04-24) ──────────────────────────
  'paywall': [
    Hotspot(id: 'close',     x: 87, y: 3,    w: 11, h: 5.5, target: 'close',     label: 'X'),
    Hotspot(id: 'monthly',   x: 12, y: 49.5, w: 30, h: 10,  target: 'none',      label: 'AYLIK'),
    Hotspot(id: 'yearly',    x: 52, y: 49.5, w: 30, h: 10,  target: 'none',      label: 'YILLIK'),
    Hotspot(id: 'restore',   x: 36, y: 62.5, w: 28, h: 3,   target: 'none',      label: 'Restore'),
    Hotspot(id: 'subscribe', x: 28, y: 69,   w: 44, h: 5.5, target: 'none',      label: 'ABONE'),
  ],

  // ─── SETTINGS ─────────────────────────────────────────────────
  // sfx: x=78.2, y=24.4
  // music: x=79, y=30.3
  // vibe: x=78.5, y=35.8
  // link account: y=52.9
  // restore: y=66.85
  // privacy: y=78.9
  // terms: y=84.25
  // ─── SETTINGS (calibrated 2026-06-27) ────────────────────────
  // sfx y=30.8, music y=38.4, vibe y=45.2, restore y=60.4, privacy y=76.3, terms y=83.4
  'settings': [
    Hotspot(id: 'sfx',     x: 65, y: 27.3, w: 28, h: 7, target: 'toggle-sfx',       label: 'SFX'),
    Hotspot(id: 'music',   x: 65, y: 34.9, w: 28, h: 7, target: 'toggle-music',     label: 'Music'),
    Hotspot(id: 'vibe',    x: 62, y: 41.7, w: 28, h: 7, target: 'toggle-vibration', label: 'Vibe'),
    Hotspot(id: 'restore', x: 10, y: 56.4, w: 72, h: 8, target: 'none',             label: 'Restore'),
    Hotspot(id: 'privacy', x: 4,  y: 72.3, w: 92, h: 8, target: 'none',             label: 'Privacy'),
    Hotspot(id: 'terms',   x: 4,  y: 79.4, w: 92, h: 8, target: 'none',             label: 'Terms'),
  ],

  'countdown': [],
};
