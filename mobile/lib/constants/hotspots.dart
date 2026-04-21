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

const Map<String, List<Hotspot>> kHotspots = {
  'menu': [
    Hotspot(id: 'coins',    x: 70,   y: 1.5,  w: 28,  h: 4.8, target: 'shop',       label: 'Jeton HUD → Shop'),
    Hotspot(id: 'play',     x: 14,   y: 56.5, w: 72,  h: 6.2, target: 'categories', label: 'OYNA'),
    Hotspot(id: 'shop',     x: 26,   y: 66,   w: 48,  h: 4.3, target: 'shop',       label: 'MAĞAZA'),
    Hotspot(id: 'settings', x: 26,   y: 72.3, w: 48,  h: 4.3, target: 'settings',   label: 'AYARLAR'),
  ],
  'categories': [
    Hotspot(id: 'cat-cars',    x: 6,  y: 13.5, w: 88, h: 9,   target: 'levels',  label: 'SUPER CARS'),
    Hotspot(id: 'cat-space',   x: 6,  y: 23.8, w: 88, h: 9,   target: 'levels',  label: 'DEEP SPACE'),
    Hotspot(id: 'cat-animals', x: 6,  y: 34.1, w: 88, h: 9,   target: 'paywall', label: 'WILD ANIMALS'),
    Hotspot(id: 'cat-beach',   x: 6,  y: 44.4, w: 88, h: 9,   target: 'paywall', label: 'BEACH GLAMOUR'),
    Hotspot(id: 'cat-fitness', x: 6,  y: 54.7, w: 88, h: 9,   target: 'levels',  label: 'FITNESS'),
    Hotspot(id: 'cat-own',     x: 17, y: 89,   w: 66, h: 5.2, target: 'paywall', label: 'KENDİ FOTOĞRAFIN'),
  ],
  'hud': [
    Hotspot(id: 'pu-brush', x: 81, y: 29.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Brush'),
    Hotspot(id: 'pu-bolt',  x: 81, y: 42.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Bolt'),
    Hotspot(id: 'pu-bomb',  x: 81, y: 55.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Bomb'),
    Hotspot(id: 'sim-win',  x: 36, y: 8.5,  w: 28, h: 4,   target: 'victory',  label: '▲ Sim: kazan'),
    Hotspot(id: 'sim-lose', x: 2,  y: 65,   w: 5,  h: 30,  target: 'gameover', label: '◀ Sim: kaybet'),
  ],
  'gameover': [
    Hotspot(id: 'use-token', x: 14, y: 62.5, w: 72, h: 6.5, target: 'hud',  label: '1 JETON KULLAN'),
    Hotspot(id: 'watch-ad',  x: 14, y: 71.5, w: 72, h: 6.5, target: 'hud',  label: 'REKLAM İZLE'),
    Hotspot(id: 'quit',      x: 32, y: 81.5, w: 36, h: 5,   target: 'menu', label: 'ÇIK'),
  ],
  'victory': [
    Hotspot(id: 'next',  x: 14, y: 75,   w: 72, h: 6.5, target: 'levels', label: 'SONRAKİ LEVEL'),
    Hotspot(id: 'retry', x: 16, y: 84,   w: 32, h: 4.5, target: 'hud',    label: 'TEKRAR DENE'),
    Hotspot(id: 'menu',  x: 52, y: 84,   w: 32, h: 4.5, target: 'menu',   label: 'MENÜ'),
  ],
  'shop': [
    Hotspot(id: 'watch-ad',    x: 52, y: 7.5,  w: 38,  h: 6,  target: 'none',    label: 'REKLAM İZLE'),
    Hotspot(id: 'pack-20',     x: 6,  y: 23,   w: 28,  h: 14, target: 'none',    label: '20 jeton'),
    Hotspot(id: 'pack-50',     x: 36, y: 23,   w: 28,  h: 14, target: 'none',    label: '50 jeton'),
    Hotspot(id: 'pack-120',    x: 66, y: 23,   w: 28,  h: 14, target: 'none',    label: '120 jeton'),
    Hotspot(id: 'theme-cars',  x: 8,  y: 45,   w: 18,  h: 12, target: 'none',    label: 'Cars tema'),
    Hotspot(id: 'theme-space', x: 29, y: 45,   w: 18,  h: 12, target: 'none',    label: 'Space tema'),
    Hotspot(id: 'theme-anim',  x: 50, y: 45,   w: 18,  h: 12, target: 'none',    label: 'Animals tema'),
    Hotspot(id: 'theme-beach', x: 8,  y: 60,   w: 18,  h: 12, target: 'none',    label: 'Beach tema'),
    Hotspot(id: 'theme-lock',  x: 29, y: 60,   w: 18,  h: 12, target: 'paywall', label: 'Kilitli tema'),
    Hotspot(id: 'back',        x: 0,  y: 92,   w: 100, h: 8,  target: 'menu',    label: 'Geri'),
  ],
  'paywall': [
    Hotspot(id: 'close',     x: 85, y: 2,   w: 12, h: 6,   target: 'menu', label: 'Kapat'),
    Hotspot(id: 'monthly',   x: 8,  y: 29,  w: 38, h: 10,  target: 'none', label: 'AYLIK'),
    Hotspot(id: 'yearly',    x: 50, y: 29,  w: 42, h: 10,  target: 'none', label: 'YILLIK'),
    Hotspot(id: 'restore',   x: 30, y: 42,  w: 40, h: 3.5, target: 'none', label: 'Satın Almaları Geri Yükle'),
    Hotspot(id: 'subscribe', x: 14, y: 47,  w: 72, h: 6,   target: 'menu', label: 'ABONE OL'),
  ],
  'settings': [
    Hotspot(id: 'sfx',     x: 78, y: 14,   w: 17, h: 5,   target: 'toggle-sfx',       label: 'Ses Efektleri'),
    Hotspot(id: 'music',   x: 78, y: 20.5, w: 17, h: 5,   target: 'toggle-music',     label: 'Müzik'),
    Hotspot(id: 'vibe',    x: 78, y: 27,   w: 17, h: 5,   target: 'toggle-vibration', label: 'Titreşim'),
    Hotspot(id: 'link',    x: 20, y: 44,   w: 60, h: 6,   target: 'none',             label: 'HESAP BAĞLA'),
    Hotspot(id: 'restore', x: 14, y: 61,   w: 72, h: 6,   target: 'none',             label: 'SATIN ALMALARI GERİ YÜKLE'),
    Hotspot(id: 'privacy', x: 6,  y: 74,   w: 88, h: 4.5, target: 'none',             label: 'Gizlilik Politikası'),
    Hotspot(id: 'terms',   x: 6,  y: 80,   w: 88, h: 4.5, target: 'none',             label: 'Kullanım Şartları'),
    Hotspot(id: 'back',    x: 0,  y: 92,   w: 100, h: 8,  target: 'menu',             label: 'Geri'),
  ],
  'countdown': [
    Hotspot(id: 'go', x: 0, y: 0, w: 100, h: 100, target: 'hud', label: 'Geri Sayım → HUD'),
  ],
};
