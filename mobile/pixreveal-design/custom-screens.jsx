// Custom screens — PNG'nin yetmediği yerlerde koddan çizilen sahneler.
// LevelSelectScreen: fiyat yok, yıldız/kilit/NEXT sistemi
// GameplayScreen: Qix-tarzı oyun içi sahne — kategori resmi arka plan,
//                 kapatılmış territory, trail, cursor, tarantula

// ── Level Select (fiyatsız) ─────────────────────────────────────────

function LevelSelectScreen() {
  // 12 level: level 1 tamamlanmış (3 yıldız), level 2-3 tamamlanmış (2-3 yıldız),
  // level 4 sıradaki (NEXT badge), 5-12 kilitli.
  const levels = [
    { n: 1,  stars: 3, state: 'done' },
    { n: 2,  stars: 2, state: 'done' },
    { n: 3,  stars: 3, state: 'done' },
    { n: 4,  stars: 0, state: 'next' },
    { n: 5,  stars: 0, state: 'locked' },
    { n: 6,  stars: 0, state: 'locked' },
    { n: 7,  stars: 0, state: 'locked' },
    { n: 8,  stars: 0, state: 'locked' },
    { n: 9,  stars: 0, state: 'locked' },
    { n: 10, stars: 0, state: 'locked' },
    { n: 11, stars: 0, state: 'locked' },
    { n: 12, stars: 0, state: 'locked' },
  ];

  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: `
        radial-gradient(ellipse 80% 50% at 50% 0%, rgba(255,215,0,.08) 0%, transparent 60%),
        radial-gradient(ellipse 70% 60% at 50% 100%, rgba(255,0,110,.12) 0%, transparent 60%),
        radial-gradient(circle at 20% 30%, rgba(0,212,255,.1) 0%, transparent 40%),
        linear-gradient(180deg, #0a0e27 0%, #1a0f2e 100%)
      `,
      color: '#fff',
      fontFamily: "'Inter', system-ui, sans-serif",
      overflowY: 'auto',
      overflowX: 'hidden',
      boxSizing: 'border-box',
      padding: '40px 20px 30px',
    }}>
      {/* Starfield */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', opacity: .55 }}>
        {Array.from({length: 50}).map((_, i) => {
          const seed = (i * 9301 + 49297) % 233280;
          const x = (seed % 100);
          const y = ((seed * 7) % 100);
          const s = ((seed % 3) + 1) * 0.7;
          return (
            <div key={i} style={{
              position: 'absolute', left: x + '%', top: y + '%',
              width: s, height: s, borderRadius: '50%',
              background: '#fff', opacity: ((seed % 10) + 3) / 15,
              boxShadow: '0 0 4px #fff',
            }} />
          );
        })}
      </div>

      {/* Header */}
      <div style={{ position: 'relative', textAlign: 'center', marginBottom: 24 }}>
        <div style={{
          fontFamily: "'Orbitron', sans-serif",
          fontSize: 28,
          fontWeight: 900,
          letterSpacing: 3,
          color: '#00d4ff',
          textShadow: '0 0 20px rgba(0,212,255,.6), 0 2px 0 rgba(0,80,120,.8)',
          display: 'inline-block',
          padding: '10px 28px',
          border: '2px solid rgba(0,212,255,.5)',
          borderRadius: 12,
          background: 'rgba(0,212,255,.05)',
          boxShadow: 'inset 0 0 20px rgba(0,212,255,.15), 0 0 30px rgba(0,212,255,.2)',
        }}>SUPER CARS</div>
      </div>

      {/* Grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(3, 1fr)',
        gap: 12,
        position: 'relative',
      }}>
        {levels.map((lv) => <LevelCard key={lv.n} {...lv} />)}
      </div>

      {/* bottom glow */}
      <div style={{ height: 40 }} />
    </div>
  );
}

function LevelCard({ n, stars, state }) {
  const isDone = state === 'done';
  const isNext = state === 'next';
  const isLocked = state === 'locked';

  const borderColor = isNext ? '#ff006e' : isDone ? 'rgba(0,212,255,.7)' : 'rgba(100,120,180,.3)';
  const glow = isNext
    ? '0 0 20px rgba(255,0,110,.5), inset 0 0 20px rgba(255,0,110,.15)'
    : isDone
    ? '0 0 16px rgba(0,212,255,.3), inset 0 0 16px rgba(0,212,255,.1)'
    : 'inset 0 0 12px rgba(0,0,0,.4)';

  return (
    <div style={{
      position: 'relative',
      aspectRatio: '1 / 1.05',
      borderRadius: 14,
      border: `2px solid ${borderColor}`,
      background: isLocked
        ? 'linear-gradient(180deg, rgba(20,20,40,.8), rgba(10,10,25,.9))'
        : 'linear-gradient(180deg, rgba(20,30,60,.8), rgba(10,15,40,.9))',
      boxShadow: glow,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 8,
      overflow: 'visible',
    }}>
      {/* NEXT badge */}
      {isNext && (
        <div style={{
          position: 'absolute',
          top: -10, left: '50%',
          transform: 'translateX(-50%)',
          background: 'linear-gradient(180deg, #ff4d9f, #ff006e)',
          color: '#fff',
          padding: '3px 10px',
          borderRadius: 999,
          fontSize: 8.5,
          fontWeight: 900,
          letterSpacing: 1.2,
          fontFamily: "'Orbitron', sans-serif",
          whiteSpace: 'nowrap',
          boxShadow: '0 2px 10px rgba(255,0,110,.6), inset 0 1px 0 rgba(255,255,255,.4)',
        }}>SIRA SENDE</div>
      )}

      {/* Level number */}
      <div style={{
        fontFamily: "'Orbitron', sans-serif",
        fontSize: 14,
        fontWeight: 900,
        letterSpacing: 1,
        color: isLocked ? 'rgba(255,255,255,.35)' : '#fff',
        textShadow: isLocked ? 'none' : '0 1px 3px rgba(0,0,0,.6)',
        marginBottom: 8,
        marginTop: isNext ? 4 : 0,
      }}>LEVEL {n}</div>

      {/* Stars or Lock */}
      {isLocked ? (
        <LockIcon />
      ) : isNext ? (
        <PlayArrow />
      ) : (
        <div style={{ display: 'flex', gap: 3 }}>
          {[1,2,3].map((i) => <Star key={i} filled={i <= stars} />)}
        </div>
      )}
    </div>
  );
}

function Star({ filled }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24">
      <defs>
        <linearGradient id={`star-g-${filled}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"  stopColor={filled ? '#ffe066' : '#3a3a4a'} />
          <stop offset="100%" stopColor={filled ? '#ff9500' : '#1a1a28'} />
        </linearGradient>
      </defs>
      <path
        d="M12 2l3 7 7 .5-5.5 4.5 2 7L12 17l-6.5 4 2-7L2 9.5 9 9z"
        fill={`url(#star-g-${filled})`}
        stroke={filled ? '#ffc04d' : '#444'}
        strokeWidth="1"
        style={filled ? { filter: 'drop-shadow(0 0 3px rgba(255,200,0,.7))' } : {}}
      />
    </svg>
  );
}

function LockIcon() {
  return (
    <svg width="24" height="28" viewBox="0 0 24 28">
      <defs>
        <linearGradient id="lock-g" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#ffd700" />
          <stop offset="100%" stopColor="#b8860b" />
        </linearGradient>
      </defs>
      <path d="M7 12V8a5 5 0 0110 0v4" fill="none" stroke="url(#lock-g)" strokeWidth="2.2" strokeLinecap="round" />
      <rect x="4" y="12" width="16" height="13" rx="2.5" fill="url(#lock-g)" stroke="#8b6508" strokeWidth="1" />
      <circle cx="12" cy="18" r="1.8" fill="#5a4208" />
      <path d="M12 19v3" stroke="#5a4208" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  );
}

function PlayArrow() {
  return (
    <svg width="26" height="26" viewBox="0 0 26 26" style={{ filter: 'drop-shadow(0 0 6px rgba(255,0,110,.7))' }}>
      <defs>
        <linearGradient id="play-g" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#ff4d9f" />
          <stop offset="100%" stopColor="#ff006e" />
        </linearGradient>
      </defs>
      <circle cx="13" cy="13" r="12" fill="url(#play-g)" stroke="#fff" strokeWidth="1.5" />
      <path d="M10 8l8 5-8 5z" fill="#fff" />
    </svg>
  );
}

// ── Gameplay overlay (Qix / Gals Panic tarzı) ───────────────────────
// HUD mockup'taki boş uzayın üstüne oyun sahnesi enjekte eder:
// - Arka planda bulanık araba fotoğrafı (kategori = Super Cars)
// - Kapatılmış territory (polygon fill, cyan/pink glow)
// - Trail (cursor'un arkasındaki çizgi)
// - Oyuncu cursor (elmas, cyan)
// - Tarantula (ortada, düşman)

function GameplayOverlay() {
  // Sahne: ekran alanı yaklaşık y=7%..77% arası (HUD bar üstte, joystick altta).
  // Polygon: sol alt + üst köşeyi kaplamış % ~45 territory.
  // Trail: sağ alttan merkeze doğru ilerliyor.
  // Cursor: trail'in ucunda.
  // Tarantula: ortada, küçük boyut.

  return (
    <div style={{
      position: 'absolute',
      left: '2%', right: '2%',
      top: '7%', bottom: '7%',
      pointerEvents: 'none',
      overflow: 'hidden',
      borderRadius: 4,
    }}>
      {/* Arka plan kategori resmi — bulanık, karartılmış */}
      <div style={{
        position: 'absolute', inset: 0,
        backgroundImage: 'url(https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=800&auto=format)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        filter: 'blur(2px) brightness(0.35) saturate(1.2)',
        transform: 'scale(1.05)',
      }} />

      {/* Karartma katmanı üstte */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(ellipse at center, transparent 0%, rgba(0,0,0,.4) 100%)',
      }} />

      {/* Kapatılmış territory — SVG polygon, scene'in ~45%'ini kaplar */}
      <svg
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
        style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}
      >
        <defs>
          <linearGradient id="captured-g" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%"  stopColor="rgba(0,212,255,.28)" />
            <stop offset="100%" stopColor="rgba(255,0,110,.35)" />
          </linearGradient>
          <linearGradient id="trail-g" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%"  stopColor="#ff006e" stopOpacity=".9" />
            <stop offset="100%" stopColor="#00d4ff" stopOpacity="1" />
          </linearGradient>
          <filter id="neon-glow">
            <feGaussianBlur stdDeviation="0.5" result="b" />
            <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
        </defs>

        {/* Captured region — araba fotoğrafının üstü + sol şerit */}
        <polygon
          points="0,0 100,0 100,28 62,28 62,54 26,54 26,100 0,100"
          fill="url(#captured-g)"
          stroke="#00d4ff"
          strokeWidth="0.4"
          opacity="0.85"
          style={{ filter: 'drop-shadow(0 0 3px rgba(0,212,255,.7))' }}
        />

        {/* Trail — sağ alttan tarantula yakınına çiziliyor (L-şekli) */}
        <polyline
          points="84,92 84,72 54,72"
          fill="none"
          stroke="url(#trail-g)"
          strokeWidth="1"
          strokeLinecap="round"
          strokeLinejoin="round"
          filter="url(#neon-glow)"
          style={{ filter: 'drop-shadow(0 0 4px #ff006e) drop-shadow(0 0 8px #00d4ff)' }}
        />

        {/* Trail ucundaki parıltı çizgisi (animasyonlu dash) */}
        <polyline
          points="54,72 48,72"
          fill="none"
          stroke="#00d4ff"
          strokeWidth="1.2"
          strokeDasharray="2 1.5"
          opacity=".9"
        >
          <animate attributeName="stroke-dashoffset" from="0" to="-7" dur="0.6s" repeatCount="indefinite" />
        </polyline>
      </svg>

      {/* Progress bölgesindeki % gösterge — kapatılmış bölgenin ortasında */}
      <div style={{
        position: 'absolute',
        left: '10%', top: '10%',
        color: '#00d4ff',
        fontFamily: "'Orbitron', monospace",
        fontSize: 11,
        fontWeight: 900,
        letterSpacing: 1,
        textShadow: '0 0 8px #00d4ff, 0 1px 2px rgba(0,0,0,.8)',
        opacity: .85,
      }}>45.2%</div>

      {/* Tarantula — ortada, düşman */}
      <img
        src="assets/tarantula.png"
        alt=""
        style={{
          position: 'absolute',
          left: '32%', top: '30%',
          width: '30%',
          height: 'auto',
          filter: 'drop-shadow(0 0 12px rgba(255,0,50,.6)) drop-shadow(0 6px 14px rgba(0,0,0,.7))',
          animation: 'tarantulaIdle 4s ease-in-out infinite',
        }}
      />

      {/* Oyuncu cursor — trail'in ucunda, elmas şekli, cyan glow */}
      <div style={{
        position: 'absolute',
        left: '48%', top: '72%',
        transform: 'translate(-50%, -50%) rotate(45deg)',
        width: 14, height: 14,
        background: 'linear-gradient(135deg, #fff, #00d4ff 50%, #0088ff)',
        boxShadow: '0 0 12px #00d4ff, 0 0 24px #00d4ff, inset 0 0 4px #fff',
        animation: 'cursorPulse 0.8s ease-in-out infinite',
      }} />

      <style>{`
        @keyframes cursorPulse {
          0%, 100% { box-shadow: 0 0 12px #00d4ff, 0 0 24px #00d4ff, inset 0 0 4px #fff; }
          50%      { box-shadow: 0 0 18px #00d4ff, 0 0 36px #00d4ff, inset 0 0 4px #fff; }
        }
        @keyframes tarantulaIdle {
          0%, 100% { transform: translateY(0) rotate(-1deg); }
          50%      { transform: translateY(-4px) rotate(1deg); }
        }
      `}</style>
    </div>
  );
}

Object.assign(window, { LevelSelectScreen, GameplayOverlay });
