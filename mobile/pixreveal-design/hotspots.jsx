// Hotspot maps — koordinatlar % (0-100) cinsinden, 1024×1536 mockup bazlı.
// Her screen için { id, x, y, w, h, target, label } listesi.
// target: sonraki screen id veya özel aksiyon ("back", "none").

const HOTSPOTS = {
  menu: [
    { id: 'coins',    x: 70,   y: 1.5, w: 28, h: 4.8, target: 'shop',     label: 'Jeton HUD → Shop' },
    { id: 'play',     x: 14,   y: 56.5, w: 72, h: 6.2, target: 'categories', label: 'PLAY' },
    { id: 'shop',     x: 26,   y: 66,   w: 48, h: 4.3, target: 'shop',     label: 'SHOP' },
    { id: 'settings', x: 26,   y: 72.3, w: 48, h: 4.3, target: 'settings', label: 'SETTINGS' },
  ],
  categories: [
    { id: 'cat-cars',    x: 6,  y: 13.5, w: 88, h: 9, target: 'levels',   label: 'SUPER CARS' },
    { id: 'cat-space',   x: 6,  y: 23.8, w: 88, h: 9, target: 'levels',   label: 'DEEP SPACE' },
    { id: 'cat-animals', x: 6,  y: 34.1, w: 88, h: 9, target: 'paywall',  label: 'WILD ANIMALS (premium)' },
    { id: 'cat-beach',   x: 6,  y: 44.4, w: 88, h: 9, target: 'paywall',  label: 'BEACH GLAMOUR (premium)' },
    { id: 'cat-fitness', x: 6,  y: 54.7, w: 88, h: 9, target: 'levels',   label: 'FITNESS' },
    { id: 'cat-own',     x: 17, y: 89,   w: 66, h: 5.2, target: 'paywall', label: 'YOUR OWN IMAGE' },
  ],
  levels: [
    // Kod-tabanlı grid: padding 40px top, 20px side, 3 sütun, gap 12px, yıldız/kilit kartları.
    // Artık tek "başla" hotspot'u: level 4 (NEXT badge'li, sıradaki).
    // Level 1-3 tamamlanmış (yeniden oynanabilir), 5-12 kilitli.
    // Yaklaşık pozisyonlar (500×750 phone frame içinde):
    // Grid top ~12%, kart boy ~14%, gap 1.5%, 3 kart = 31%/sütun, side padding ~4%
    { id: 'lv1',  x: 4,   y: 13.5,  w: 30, h: 14.5, target: 'countdown', label: 'LEVEL 1 (replay)' },
    { id: 'lv2',  x: 35.5, y: 13.5, w: 30, h: 14.5, target: 'countdown', label: 'LEVEL 2 (replay)' },
    { id: 'lv3',  x: 66.5, y: 13.5, w: 30, h: 14.5, target: 'countdown', label: 'LEVEL 3 (replay)' },
    { id: 'lv4',  x: 4,   y: 29,    w: 30, h: 14.5, target: 'countdown', label: 'LEVEL 4 · SIRA SENDE' },
    { id: 'lv5',  x: 35.5, y: 29,   w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 5 (kilitli → paywall)' },
    { id: 'lv6',  x: 66.5, y: 29,   w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 6 (kilitli)' },
    { id: 'lv7',  x: 4,   y: 44.5,  w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 7 (kilitli)' },
    { id: 'lv8',  x: 35.5, y: 44.5, w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 8 (kilitli)' },
    { id: 'lv9',  x: 66.5, y: 44.5, w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 9 (kilitli)' },
    { id: 'lv10', x: 4,   y: 60,    w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 10 (kilitli)' },
    { id: 'lv11', x: 35.5, y: 60,   w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 11 (kilitli)' },
    { id: 'lv12', x: 66.5, y: 60,   w: 30, h: 14.5, target: 'paywall',   label: 'LEVEL 12 (kilitli)' },
  ],
  hud: [
    // Oyun içi: powerup ikonları (sağ kolon) + joystick (sol alt, JoystickOverlay drag area)
    // Simülasyon hotspot'ları: "tap to lose / tap to win" — gameplay overlay'e müdahale etmeyecek küçük köşelerde
    { id: 'pu-brush',  x: 81,  y: 29.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Brush' },
    { id: 'pu-bolt',   x: 81,  y: 42.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Bolt' },
    { id: 'pu-bomb',   x: 81,  y: 55.5, w: 14, h: 7.5, target: 'none',     label: 'Powerup: Bomb' },
    // Sim alanları — oyun alanının dışında, test amaçlı
    { id: 'sim-win',   x: 36,  y: 8.5,  w: 28, h: 4,   target: 'victory',  label: '▲ Sim: kazan' },
    { id: 'sim-lose',  x: 2,   y: 65,   w: 5,  h: 30,  target: 'gameover', label: '◀ Sim: kaybet' },
  ],
  gameover: [
    { id: 'use-token', x: 14, y: 62.5, w: 72, h: 6.5, target: 'hud',    label: 'USE 1 TOKEN → continue' },
    { id: 'watch-ad',  x: 14, y: 71.5, w: 72, h: 6.5, target: 'hud',    label: 'WATCH AD → continue' },
    { id: 'quit',      x: 32, y: 81.5, w: 36, h: 5,   target: 'menu',   label: 'QUIT' },
  ],
  victory: [
    { id: 'next',  x: 14, y: 75,   w: 72, h: 6.5, target: 'levels', label: 'NEXT LEVEL' },
    { id: 'retry', x: 16, y: 84,   w: 32, h: 4.5, target: 'hud',    label: 'RETRY' },
    { id: 'menu',  x: 52, y: 84,   w: 32, h: 4.5, target: 'menu',   label: 'MENU' },
  ],
  shop: [
    { id: 'watch-ad',    x: 52, y: 7.5,  w: 38, h: 6,   target: 'none', label: 'WATCH AD (free tokens)' },
    { id: 'pack-20',     x: 6,  y: 23,   w: 28, h: 14,  target: 'none', label: '20 tokens · $0.99' },
    { id: 'pack-50',     x: 36, y: 23,   w: 28, h: 14,  target: 'none', label: '50 tokens · $1.99' },
    { id: 'pack-120',    x: 66, y: 23,   w: 28, h: 14,  target: 'none', label: '120 tokens · $3.99' },
    { id: 'theme-cars',  x: 8,  y: 45,   w: 18, h: 12,  target: 'none', label: 'Cars theme' },
    { id: 'theme-space', x: 29, y: 45,   w: 18, h: 12,  target: 'none', label: 'Space theme' },
    { id: 'theme-anim',  x: 50, y: 45,   w: 18, h: 12,  target: 'none', label: 'Animals theme' },
    { id: 'theme-beach', x: 8,  y: 60,   w: 18, h: 12,  target: 'none', label: 'Beach theme' },
    { id: 'theme-lock',  x: 29, y: 60,   w: 18, h: 12,  target: 'paywall', label: 'Locked theme → paywall' },
    { id: 'back',        x: 0,  y: 92,   w: 100, h: 8,  target: 'menu', label: 'Back to menu' },
  ],
  paywall: [
    { id: 'close',    x: 85, y: 2,    w: 12, h: 6,   target: 'menu',     label: 'Close' },
    { id: 'monthly',  x: 8,  y: 29,   w: 38, h: 10,  target: 'none',     label: 'Toggle: Monthly' },
    { id: 'yearly',   x: 50, y: 29,   w: 42, h: 10,  target: 'none',     label: 'Toggle: Yearly' },
    { id: 'restore',  x: 30, y: 42,   w: 40, h: 3.5, target: 'none',     label: 'Restore Purchases' },
    { id: 'subscribe',x: 14, y: 47,   w: 72, h: 6,   target: 'menu',     label: 'SUBSCRIBE' },
  ],
  settings: [
    { id: 'sfx',      x: 78, y: 14,   w: 17, h: 5,   target: 'toggle-sfx',      label: 'Toggle: SFX' },
    { id: 'music',    x: 78, y: 20.5, w: 17, h: 5,   target: 'toggle-music',    label: 'Toggle: Music' },
    { id: 'vibe',     x: 78, y: 27,   w: 17, h: 5,   target: 'toggle-vibration',label: 'Toggle: Vibration' },
    { id: 'link',     x: 20, y: 44,   w: 60, h: 6,   target: 'none',            label: 'LINK ACCOUNT' },
    { id: 'restore',  x: 14, y: 61,   w: 72, h: 6,   target: 'none',            label: 'RESTORE PURCHASES' },
    { id: 'privacy',  x: 6,  y: 74,   w: 88, h: 4.5, target: 'none',            label: 'Privacy Policy' },
    { id: 'terms',    x: 6,  y: 80,   w: 88, h: 4.5, target: 'none',            label: 'Terms of Service' },
    { id: 'back',     x: 0,  y: 92,   w: 100, h: 8,  target: 'menu',            label: 'Back to menu' },
  ],
  countdown: [
    { id: 'go', x: 0, y: 0, w: 100, h: 100, target: 'hud', label: 'Countdown → HUD' },
  ],
};

window.HOTSPOTS = HOTSPOTS;

// Screen sırası (prototip akışı için referans)
window.SCREEN_ORDER = ['menu', 'categories', 'levels', 'countdown', 'hud', 'victory', 'gameover', 'shop', 'paywall', 'settings'];

// Her screen'in asset path'i
window.SCREEN_ASSETS = {
  menu:       'assets/menu.png',
  categories: 'assets/categories.png',
  levels:     'assets/levels.png',
  hud:        'assets/hud.png',
  gameover:   'assets/gameover.png',
  victory:    'assets/victory.png',
  shop:       'assets/shop.png',
  paywall:    'assets/paywall.png',
  settings:   'assets/settings.png',
  // countdown asset'i yok — HUD üzerine overlay
  countdown:  'assets/hud.png',
};

window.SCREEN_TITLES = {
  menu: 'Ana Menü',
  categories: 'Kategoriler',
  levels: 'Level Seçimi',
  countdown: 'Geri Sayım',
  hud: 'Oyun İçi HUD',
  gameover: 'Game Over',
  victory: 'Zafer',
  shop: 'Mağaza',
  paywall: 'Premium',
  settings: 'Ayarlar',
};
