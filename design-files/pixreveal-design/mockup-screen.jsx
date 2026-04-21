// MockupScreen — tek ekran, mockup PNG + hotspot overlay + opsiyonel çalışan UI elementleri
// Props:
//   screen: 'menu' | 'categories' | ... (HOTSPOTS key)
//   onNavigate(target): hotspot tıklandığında çağrılır
//   showHotspots: boolean — highlight overlay göster/gizle
//   overlay: react node — mockup üzerine ek DOM (countdown, joystick drag, toggle state, vs.)
//   interactive: boolean — hotspot click aktif mi

function MockupScreen({ screen, onNavigate, showHotspots = false, overlay = null, interactive = true, style = {}, customRender = null }) {
  const spots = window.HOTSPOTS[screen] || [];
  const asset = window.SCREEN_ASSETS[screen];

  return (
    <div style={{
      position: 'relative',
      width: '100%',
      height: '100%',
      background: '#000',
      overflow: 'hidden',
      ...style,
    }}>
      {customRender ? customRender : (
        <img
          src={asset}
          alt={window.SCREEN_TITLES[screen]}
          draggable={false}
          style={{
            position: 'absolute',
            inset: 0,
            width: '100%',
            height: '100%',
            objectFit: 'contain',
            objectPosition: 'center',
            userSelect: 'none',
            pointerEvents: 'none',
          }}
        />
      )}
      {/* Hotspots */}
      {interactive && spots.map((s) => (
        <button
          key={s.id}
          onClick={(e) => {
            e.stopPropagation();
            onNavigate && onNavigate(s.target, s);
          }}
          title={s.label}
          style={{
            position: 'absolute',
            left: s.x + '%',
            top: s.y + '%',
            width: s.w + '%',
            height: s.h + '%',
            border: showHotspots ? '2px dashed rgba(0, 212, 255, 0.9)' : 'none',
            background: showHotspots ? 'rgba(0, 212, 255, 0.14)' : 'transparent',
            cursor: s.target === 'none' ? 'default' : 'pointer',
            padding: 0,
            borderRadius: 8,
            zIndex: 2,
            transition: 'background 0.15s',
            fontFamily: 'inherit',
            color: '#00d4ff',
            fontSize: 10,
            fontWeight: 700,
            letterSpacing: 0.4,
            textShadow: '0 1px 2px rgba(0,0,0,.8)',
            display: showHotspots ? 'flex' : 'block',
            alignItems: 'flex-start',
            justifyContent: 'flex-start',
            textAlign: 'left',
          }}
          onMouseEnter={(e) => {
            if (!showHotspots) e.currentTarget.style.background = 'rgba(255, 255, 255, 0.08)';
          }}
          onMouseLeave={(e) => {
            if (!showHotspots) e.currentTarget.style.background = 'transparent';
          }}
        >
          {showHotspots && <span style={{ padding: '2px 4px', background: 'rgba(10,14,39,.85)', borderRadius: 3 }}>{s.label}</span>}
        </button>
      ))}
      {/* Live overlay (countdown, joystick state, toggles…) */}
      {overlay && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 3, pointerEvents: 'none' }}>
          {overlay}
        </div>
      )}
    </div>
  );
}

// ── Overlays for "live" feeling on top of static mockups ─────────────

// Geri sayım: mockup'ın üstüne tam ekran 3-2-1-BAŞLA overlay.
function CountdownOverlay({ onDone }) {
  const [n, setN] = React.useState(3);
  React.useEffect(() => {
    if (n < 0) { onDone && onDone(); return; }
    const t = setTimeout(() => setN(n - 1), 800);
    return () => clearTimeout(t);
  }, [n]);

  const display = n > 0 ? String(n) : (n === 0 ? 'GO!' : '');
  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'radial-gradient(ellipse at center, rgba(10,14,39,.3) 0%, rgba(0,0,0,.82) 70%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      pointerEvents: 'auto',
    }}>
      <div
        key={n}
        style={{
          fontFamily: '"Orbitron", "Arial Black", sans-serif',
          fontSize: n === 0 ? 80 : 180,
          fontWeight: 900,
          color: n === 0 ? '#ffd700' : '#00d4ff',
          textShadow: n === 0
            ? '0 0 20px #ffd700, 0 0 40px #ff9500, 0 0 80px #ff006e'
            : '0 0 20px #00d4ff, 0 0 40px #00d4ff, 0 0 80px #0088ff',
          animation: 'countPop 0.8s ease-out',
          letterSpacing: n === 0 ? 4 : 0,
        }}
      >{display}</div>
      <style>{`
        @keyframes countPop {
          0%   { transform: scale(2.4); opacity: 0; }
          30%  { transform: scale(1);   opacity: 1; }
          80%  { transform: scale(1);   opacity: 1; }
          100% { transform: scale(0.6); opacity: 0; }
        }
      `}</style>
    </div>
  );
}

// Joystick drag overlay — mockup'taki joystick'in üzerine koyulur, gerçek drag hissi verir.
function JoystickOverlay() {
  const [pos, setPos] = React.useState({ x: 0, y: 0 });
  const [active, setActive] = React.useState(false);
  const ref = React.useRef(null);

  const onDown = (e) => {
    e.preventDefault();
    setActive(true);
    const r = ref.current.getBoundingClientRect();
    const cx = r.left + r.width / 2;
    const cy = r.top + r.height / 2;
    update(e.clientX, e.clientY, cx, cy, r.width / 2);
    const move = (ev) => update(ev.clientX, ev.clientY, cx, cy, r.width / 2);
    const up = () => {
      setActive(false);
      setPos({ x: 0, y: 0 });
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
  };

  const update = (x, y, cx, cy, max) => {
    let dx = x - cx, dy = y - cy;
    const d = Math.hypot(dx, dy);
    const cap = max * 0.55;
    if (d > cap) { dx = (dx / d) * cap; dy = (dy / d) * cap; }
    setPos({ x: dx, y: dy });
  };

  // HUD mockup'taki joystick yaklaşık: sol 9%, alt 22%, size ~18%
  return (
    <div
      ref={ref}
      onPointerDown={onDown}
      style={{
        position: 'absolute',
        left: '8%', bottom: '9%',
        width: '20%', aspectRatio: '1',
        borderRadius: '50%',
        cursor: 'grab',
        pointerEvents: 'auto',
        touchAction: 'none',
      }}
    >
      {/* hafif glow ring active iken */}
      {active && (
        <div style={{
          position: 'absolute', inset: -6,
          borderRadius: '50%',
          boxShadow: '0 0 30px rgba(0,212,255,.6), inset 0 0 20px rgba(0,212,255,.3)',
          pointerEvents: 'none',
        }} />
      )}
      {/* merkez topak — drag edilen kısım */}
      <div style={{
        position: 'absolute',
        left: '50%', top: '50%',
        width: '42%', height: '42%',
        borderRadius: '50%',
        transform: `translate(calc(-50% + ${pos.x}px), calc(-50% + ${pos.y}px))`,
        background: 'radial-gradient(circle at 35% 30%, rgba(255,255,255,.3), rgba(100,120,180,.5) 40%, rgba(30,40,80,.8) 80%)',
        boxShadow: active
          ? '0 0 20px rgba(0,212,255,.8), inset 0 -4px 8px rgba(0,0,0,.5), inset 0 2px 4px rgba(255,255,255,.3)'
          : 'inset 0 -4px 8px rgba(0,0,0,.5), inset 0 2px 4px rgba(255,255,255,.2)',
        transition: active ? 'none' : 'transform 0.2s cubic-bezier(.2,.8,.4,1)',
        pointerEvents: 'none',
      }} />
    </div>
  );
}

// Toggle state overlay — Settings ekranındaki 3 toggle için görsel feedback.
// Mockup'taki green toggle'ları kırmızı/gri ile maskele kapalıysa.
function ToggleStateOverlay({ states }) {
  // states: { sfx: bool, music: bool, vibe: bool }
  const rows = [
    { k: 'sfx',   y: 14.8 },
    { k: 'music', y: 21.4 },
    { k: 'vibe',  y: 27.9 },
  ];
  return (
    <>
      {rows.map((r) => !states[r.k] && (
        <div
          key={r.k}
          style={{
            position: 'absolute',
            left: '78%', top: r.y + '%',
            width: '17%', height: '5%',
            background: 'linear-gradient(90deg, rgba(60,30,50,.92), rgba(80,40,70,.92))',
            borderRadius: 999,
            boxShadow: 'inset 0 2px 4px rgba(0,0,0,.5), 0 0 8px rgba(255,0,110,.4)',
            display: 'flex', alignItems: 'center',
            padding: 4,
          }}
        >
          <div style={{
            width: '38%', height: '85%',
            borderRadius: '50%',
            background: 'radial-gradient(circle at 35% 30%, #fff, #ccc 60%, #888)',
            boxShadow: '0 2px 4px rgba(0,0,0,.4)',
          }} />
        </div>
      ))}
    </>
  );
}

// Paywall plan seçim overlay (Monthly vs Yearly highlight)
function PaywallPlanOverlay({ plan }) {
  // plan: 'monthly' | 'yearly'
  if (plan === 'yearly') return null; // default mockup zaten yearly seçili gösteriyor
  return (
    <div style={{
      position: 'absolute',
      left: '8%', top: '29%',
      width: '38%', height: '10%',
      borderRadius: 12,
      boxShadow: '0 0 0 3px #00d4ff, 0 0 24px rgba(0,212,255,.6)',
      pointerEvents: 'none',
    }} />
  );
}

Object.assign(window, {
  MockupScreen,
  CountdownOverlay,
  JoystickOverlay,
  ToggleStateOverlay,
  PaywallPlanOverlay,
});
