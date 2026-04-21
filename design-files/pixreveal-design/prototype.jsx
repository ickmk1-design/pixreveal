// Prototype — tıklanabilir akış. Phone frame içinde MockupScreen'leri gösterir,
// hotspot tıklamalarıyla screen'ler arası geçer. Geri sayım, toggle state,
// paywall plan, HUD joystick gibi "canlı" davranışları overlay'ler olarak enjekte eder.

function Prototype({ showHotspots, startScreen = 'menu' }) {
  const [screen, setScreen] = React.useState(startScreen);
  const [history, setHistory] = React.useState([]);
  const [toggles, setToggles] = React.useState({ sfx: true, music: true, vibe: true });
  const [paywallPlan, setPaywallPlan] = React.useState('yearly');
  const [transitioning, setTransitioning] = React.useState(false);

  const navigate = (target, spot) => {
    if (!target || target === 'none') return;

    // Special non-nav actions
    if (target === 'toggle-sfx')       { setToggles((t) => ({ ...t, sfx: !t.sfx })); return; }
    if (target === 'toggle-music')     { setToggles((t) => ({ ...t, music: !t.music })); return; }
    if (target === 'toggle-vibration') { setToggles((t) => ({ ...t, vibe: !t.vibe })); return; }
    if (target === 'back') {
      const prev = history[history.length - 1];
      if (prev) {
        setHistory((h) => h.slice(0, -1));
        setScreen(prev);
      }
      return;
    }

    // Paywall plan seçimi — aynı screen'de kal
    if (screen === 'paywall' && (spot?.id === 'monthly' || spot?.id === 'yearly')) {
      setPaywallPlan(spot.id);
      return;
    }

    // Screen transition
    setTransitioning(true);
    setTimeout(() => {
      setHistory((h) => [...h, screen]);
      setScreen(target);
      setTransitioning(false);
    }, 150);
  };

  const reset = () => {
    setScreen('menu');
    setHistory([]);
    setToggles({ sfx: true, music: true, vibe: true });
    setPaywallPlan('yearly');
  };

  // Overlay belirleme
  let overlay = null;
  let customRender = null;

  if (screen === 'levels') {
    // Level Select'i kod-tabanlı çiz (PNG fiyatlı versiyonu yerine)
    customRender = <LevelSelectScreen />;
  } else if (screen === 'countdown') {
    // Countdown: HUD PNG arkada + gameplay overlay + countdown üstte
    overlay = (
      <>
        <GameplayOverlay />
        <CountdownOverlay onDone={() => { setHistory((h) => [...h, 'countdown']); setScreen('hud'); }} />
      </>
    );
  } else if (screen === 'hud') {
    overlay = <><GameplayOverlay /><JoystickOverlay /></>;
  } else if (screen === 'settings') {
    overlay = <ToggleStateOverlay states={toggles} />;
  } else if (screen === 'paywall') {
    overlay = <PaywallPlanOverlay plan={paywallPlan} />;
  }

  return (
    <div style={{
      position: 'relative',
      width: '100%',
      height: '100%',
      overflow: 'hidden',
      opacity: transitioning ? 0.55 : 1,
      transition: 'opacity 0.15s',
    }}>
      <MockupScreen
        screen={screen}
        onNavigate={navigate}
        showHotspots={showHotspots}
        overlay={overlay}
        customRender={customRender}
      />
      {/* Breadcrumb / reset — sadece dev amaçlı, küçük chip sol üst */}
      <div style={{
        position: 'absolute',
        top: 12, left: 12,
        display: 'flex', gap: 6,
        zIndex: 10,
        fontFamily: '-apple-system, system-ui, sans-serif',
        fontSize: 10,
        pointerEvents: 'auto',
      }}>
        <button
          onClick={reset}
          title="Akışı başa sar"
          style={{
            padding: '5px 9px',
            borderRadius: 999,
            border: '1px solid rgba(0,212,255,.4)',
            background: 'rgba(10,14,39,.7)',
            backdropFilter: 'blur(8px)',
            color: '#00d4ff',
            cursor: 'pointer',
            fontWeight: 700,
            letterSpacing: 0.4,
            fontSize: 9,
          }}
        >↺ RESET</button>
        <div style={{
          padding: '5px 9px',
          borderRadius: 999,
          background: 'rgba(10,14,39,.7)',
          backdropFilter: 'blur(8px)',
          color: 'rgba(255,255,255,.7)',
          fontWeight: 600,
          letterSpacing: 0.4,
          fontSize: 9,
          textTransform: 'uppercase',
        }}>{window.SCREEN_TITLES[screen]}</div>
      </div>
    </div>
  );
}

// Phone frame — PNG'lerin native 2:3 oranına uyumlu (1024×1536 → 560×840).
// Dynamic island yok çünkü mockup'lar zaten full-bleed, üstüne bindirirse mockup'taki üst HUD'u gizler.
function PhoneFrame({ children, width = 500, height = 750 }) {
  return (
    <div style={{
      width,
      height,
      padding: 10,
      background: 'linear-gradient(145deg, #1a1d26, #0a0c15)',
      borderRadius: 42,
      boxShadow:
        '0 0 0 2px rgba(255,255,255,.06), ' +
        '0 30px 80px rgba(0,0,0,.6), ' +
        '0 0 100px rgba(0,212,255,.08), ' +
        'inset 0 2px 4px rgba(255,255,255,.08)',
      position: 'relative',
    }}>
      <div style={{
        width: '100%', height: '100%',
        borderRadius: 32,
        overflow: 'hidden',
        position: 'relative',
        background: '#000',
      }}>
        {children}
      </div>
    </div>
  );
}

Object.assign(window, { Prototype, PhoneFrame });
