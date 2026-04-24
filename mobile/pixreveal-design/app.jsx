// App — DesignCanvas içinde:
//  - Section 1: Tıklanabilir prototip (Phone frame)
//  - Section 2: Tüm 10 ekran artboard olarak (statik mockup + hotspot'lar görünür)
// Tweaks: "Hotspot Haritası" görünür/gizli, "Start Screen"

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "showHotspots": false,
  "startScreen": "menu"
}/*EDITMODE-END*/;
// NOT: showHotspots default false. Hotspot haritası sadece Tweaks panelinden açılır.

function TweaksPanel({ open, tweaks, setTweaks }) {
  if (!open) return null;
  const screens = window.SCREEN_ORDER;
  return (
    <div style={{
      position: 'fixed',
      right: 20, bottom: 20,
      zIndex: 1000,
      background: 'rgba(10,14,39,.94)',
      backdropFilter: 'blur(20px)',
      border: '1px solid rgba(0,212,255,.3)',
      borderRadius: 14,
      padding: 18,
      width: 260,
      color: '#fff',
      fontFamily: '-apple-system, system-ui, sans-serif',
      fontSize: 13,
      boxShadow: '0 20px 60px rgba(0,0,0,.6), 0 0 40px rgba(0,212,255,.15)',
    }}>
      <div style={{
        fontSize: 10,
        fontWeight: 800,
        letterSpacing: 2,
        color: '#00d4ff',
        marginBottom: 14,
        textTransform: 'uppercase',
      }}>Tweaks</div>

      <label style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14, cursor: 'pointer' }}>
        <span>Hotspot haritası</span>
        <input
          type="checkbox"
          checked={tweaks.showHotspots}
          onChange={(e) => setTweaks({ ...tweaks, showHotspots: e.target.checked })}
          style={{ accentColor: '#00d4ff', width: 16, height: 16 }}
        />
      </label>

      <div style={{ marginBottom: 6, opacity: .8, fontSize: 11 }}>Başlangıç ekranı</div>
      <select
        value={tweaks.startScreen}
        onChange={(e) => setTweaks({ ...tweaks, startScreen: e.target.value })}
        style={{
          width: '100%',
          padding: '8px 10px',
          background: 'rgba(255,255,255,.08)',
          border: '1px solid rgba(0,212,255,.3)',
          borderRadius: 8,
          color: '#fff',
          fontSize: 12,
          fontFamily: 'inherit',
          cursor: 'pointer',
        }}
      >
        {screens.map((s) => (
          <option key={s} value={s} style={{ background: '#0a0e27' }}>
            {window.SCREEN_TITLES[s]}
          </option>
        ))}
      </select>

      <div style={{
        marginTop: 14,
        padding: '10px 12px',
        background: 'rgba(0,212,255,.08)',
        border: '1px solid rgba(0,212,255,.2)',
        borderRadius: 8,
        fontSize: 11,
        lineHeight: 1.5,
        color: 'rgba(255,255,255,.75)',
      }}>
        Sol üstte <b style={{ color: '#00d4ff' }}>RESET</b> ile akışı başa sarabilirsin.
        Hotspot haritası açıkken tıklanabilir alanlar etiketleriyle görünür.
      </div>
    </div>
  );
}

function App() {
  const [tweaks, setTweaks] = React.useState(TWEAK_DEFAULTS);
  const [editMode, setEditMode] = React.useState(false);

  // Tweaks protocol
  React.useEffect(() => {
    const onMsg = (e) => {
      if (!e.data || typeof e.data !== 'object') return;
      if (e.data.type === '__activate_edit_mode') setEditMode(true);
      if (e.data.type === '__deactivate_edit_mode') setEditMode(false);
    };
    window.addEventListener('message', onMsg);
    window.parent.postMessage({ type: '__edit_mode_available' }, '*');
    return () => window.removeEventListener('message', onMsg);
  }, []);

  const updateTweaks = (next) => {
    setTweaks(next);
    window.parent.postMessage({ type: '__edit_mode_set_keys', edits: next }, '*');
  };

  // Prototype key — startScreen değiştiğinde state'i resetle
  const [protoKey, setProtoKey] = React.useState(0);
  React.useEffect(() => { setProtoKey((k) => k + 1); }, [tweaks.startScreen]);

  return (
    <>
      <DesignCanvas>
        <DCSection
          id="prototype"
          title="Tıklanabilir Prototip"
          subtitle="Mockup üzerine hotspot katmanı — gerçek akış, gerçek mockup kalitesi"
        >
          <DCArtboard id="phone" label="iPhone · Live flow" width={414} height={896}>
            <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0a0c15' }}>
              <PhoneFrame width={390} height={844}>
                <Prototype
                  key={protoKey}
                  showHotspots={tweaks.showHotspots}
                  startScreen={tweaks.startScreen}
                />
              </PhoneFrame>
            </div>
          </DCArtboard>

          <DCArtboard id="nav-map" label="Akış haritası" width={520} height={896}>
            <FlowMap />
          </DCArtboard>

          <DCPostIt top={-20} left={900} rotate={2} width={220}>
            <b>Referans PNG'ler</b> <br />
            Tüm ekran görselleri gerçek render (MJ/SD çıktısı). HTML/CSS sadece layout + interaksiyon katmanı. Flutter'a geçerken asset'leri olduğu gibi kullan.
          </DCPostIt>
        </DCSection>

        <DCSection
          id="screens"
          title="10 Ekran — Artboard"
          subtitle="Her ekran kendi mockup'ı + hotspot haritası. Tweaks'ten hotspot'ları toggle edebilirsin."
        >
          {window.SCREEN_ORDER.map((s) => (
            <DCArtboard key={s} id={s} label={`${window.SCREEN_TITLES[s]} · ${s}`} width={340} height={510}>
              <ScreenCard screen={s} showHotspots={tweaks.showHotspots} />
            </DCArtboard>
          ))}
        </DCSection>

        <DCSection
          id="handoff"
          title="Flutter Handoff Notları"
          subtitle="Geliştiriciye ne vermeli, nelere dikkat etmeli"
        >
          <DCArtboard id="assets-list" label="Asset envanteri" width={420} height={620}>
            <HandoffAssets />
          </DCArtboard>
          <DCArtboard id="responsive" label="Responsive & i18n" width={420} height={620}>
            <HandoffResponsive />
          </DCArtboard>
          <DCArtboard id="animations" label="Animasyon süreleri" width={420} height={620}>
            <HandoffAnimations />
          </DCArtboard>
        </DCSection>
      </DesignCanvas>

      {editMode && <TweaksPanel open={editMode} tweaks={tweaks} setTweaks={updateTweaks} />}
    </>
  );
}

// Tek ekran kart — statik, prototip akışı içinde değil
function ScreenCard({ screen, showHotspots }) {
  let customRender = null;
  let overlay = null;
  if (screen === 'levels') customRender = <LevelSelectScreen />;
  if (screen === 'hud') overlay = <GameplayOverlay />;
  if (screen === 'countdown') overlay = <GameplayOverlay />;

  return (
    <div style={{ width: '100%', height: '100%', background: '#000', position: 'relative' }}>
      <MockupScreen
        screen={screen}
        showHotspots={showHotspots}
        interactive={true}
        onNavigate={() => {}}
        customRender={customRender}
        overlay={overlay}
      />
    </div>
  );
}

// Akış haritası — hangi screen hangi screen'e gider, görsel şema
function FlowMap() {
  const flows = [
    { from: 'menu',       to: ['categories', 'shop', 'settings'] },
    { from: 'categories', to: ['levels', 'paywall'] },
    { from: 'levels',     to: ['countdown', 'paywall'] },
    { from: 'countdown',  to: ['hud'] },
    { from: 'hud',        to: ['victory', 'gameover'] },
    { from: 'victory',    to: ['levels', 'menu'] },
    { from: 'gameover',   to: ['hud', 'menu'] },
    { from: 'shop',       to: ['paywall', 'menu'] },
    { from: 'paywall',    to: ['menu'] },
    { from: 'settings',   to: ['menu'] },
  ];
  return (
    <div style={{
      width: '100%', height: '100%',
      background: 'linear-gradient(180deg, #0a0e27 0%, #1a0f2e 100%)',
      color: '#fff',
      fontFamily: '-apple-system, system-ui, sans-serif',
      padding: 24,
      overflowY: 'auto',
      boxSizing: 'border-box',
    }}>
      <div style={{ fontSize: 11, letterSpacing: 2, color: '#00d4ff', fontWeight: 800, marginBottom: 14 }}>NAVIGATION GRAPH</div>
      {flows.map((f) => (
        <div key={f.from} style={{
          marginBottom: 14,
          padding: 12,
          borderRadius: 10,
          background: 'rgba(0,212,255,.06)',
          border: '1px solid rgba(0,212,255,.18)',
        }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: '#ffd700', marginBottom: 8, letterSpacing: 0.3 }}>
            {window.SCREEN_TITLES[f.from].toUpperCase()}
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {f.to.map((t) => (
              <div key={t} style={{
                padding: '4px 10px',
                fontSize: 11,
                background: 'rgba(255,255,255,.08)',
                border: '1px solid rgba(255,255,255,.15)',
                borderRadius: 999,
                color: 'rgba(255,255,255,.9)',
              }}>→ {window.SCREEN_TITLES[t]}</div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

function HandoffAssets() {
  const items = [
    ['menu.png',       '1024×1536', 'Ana menü arkaplan + tarantula composite'],
    ['tarantula.png',  '1024×1024', 'Transparent · Game Over ve alt scene\'lerde reuse'],
    ['categories.png', '1024×1536', '5 kategori + premium rozet overlay\'leri'],
    ['levels.png',     '1024×1536', '12 level grid mockup'],
    ['hud.png',        '1024×1536', 'Oyun içi — joystick, powerup, HUD bar'],
    ['hud-accent.png', '1024×1536', 'Kalpler + jeton slot — HUD öğesi reuse'],
    ['gameover.png',   '1024×1536', 'Game Over ekranı'],
    ['victory.png',    '1024×1536', 'Zafer ekranı — level gereği dynamic image slot'],
    ['shop.png',       '1024×1536', 'Mağaza — token + theme packs'],
    ['paywall.png',    '1024×1536', 'Premium abonelik'],
    ['settings.png',   '1024×1536', 'Ayarlar'],
  ];
  return (
    <div style={{
      background: '#0a0e27', color: '#fff', height: '100%',
      fontFamily: '-apple-system, system-ui, sans-serif', padding: 24,
      overflowY: 'auto', boxSizing: 'border-box', fontSize: 12,
    }}>
      <div style={{ fontSize: 11, letterSpacing: 2, color: '#00d4ff', fontWeight: 800, marginBottom: 14 }}>ASSETS (/assets/)</div>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ borderBottom: '1px solid rgba(255,255,255,.15)' }}>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>DOSYA</th>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>BOYUT</th>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>NOT</th>
          </tr>
        </thead>
        <tbody>
          {items.map(([f, d, n]) => (
            <tr key={f} style={{ borderBottom: '1px solid rgba(255,255,255,.06)' }}>
              <td style={{ padding: '8px 4px', fontFamily: 'monospace', color: '#00d4ff' }}>{f}</td>
              <td style={{ padding: '8px 4px', color: 'rgba(255,255,255,.7)' }}>{d}</td>
              <td style={{ padding: '8px 4px', color: 'rgba(255,255,255,.85)' }}>{n}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div style={{
        marginTop: 16, padding: 12,
        background: 'rgba(255,215,0,.08)',
        border: '1px solid rgba(255,215,0,.25)',
        borderRadius: 8, lineHeight: 1.5,
      }}>
        <b style={{ color: '#ffd700' }}>Uyarı:</b> Asset'ler AI render (MJ/SD). Ekran içindeki metinler pixel'dir — <b>dinamik metin slot'ları için Flutter tarafında font kullanın</b> (başlıklar, skor, level numarası, toggle label'ları). Arka plan illustration'ı + karakter = asset; HUD text + butonlar = kod.
      </div>
    </div>
  );
}

function HandoffResponsive() {
  return (
    <div style={{
      background: '#0a0e27', color: '#fff', height: '100%',
      fontFamily: '-apple-system, system-ui, sans-serif', padding: 24,
      overflowY: 'auto', boxSizing: 'border-box', fontSize: 12, lineHeight: 1.6,
    }}>
      <div style={{ fontSize: 11, letterSpacing: 2, color: '#00d4ff', fontWeight: 800, marginBottom: 14 }}>RESPONSIVE + I18N</div>

      <Section title="Ölçüm bazı">
        Tüm ekranlar <b>2:3 (1024×1536) portrait</b>. Flutter'da <code>LayoutBuilder</code> + <code>MediaQuery</code> ile responsive. Asset'ler <code>BoxFit.cover</code> — her ölçekte doğal görünür.
      </Section>

      <Section title="Safe area">
        HUD bar üstte — <code>SafeArea</code> içinde. Jeton chip sağ üst notch'un altında kalmalı.
      </Section>

      <Section title="Hit targets">
        Tüm buton ve hotspot min <b>44×44 dp</b>. Mockup'taki yumuşak çerçeveler görünürden büyük hit area ile.
      </Section>

      <Section title="Dil desteği">
        TR + EN. i18n key'ler:<br/>
        <code style={{ fontSize: 10, color: '#00d4ff' }}>menu.play, menu.shop, menu.settings,<br/>
        cats.cars, cats.space, cats.animals, cats.beach, cats.fitness, cats.own,<br/>
        gameOver.title, gameOver.useToken, gameOver.watchAd, gameOver.quit,<br/>
        victory.title, victory.score, victory.combo, victory.time,<br/>
        victory.next, victory.retry, victory.menu,<br/>
        paywall.title, paywall.monthly, paywall.yearly, paywall.subscribe,<br/>
        settings.sfx, settings.music, settings.vibration, settings.link,<br/>
        shop.freeTokens, shop.watchAd, shop.tokenPacks, shop.themePacks</code>
      </Section>

      <Section title="Overflow">
        Tüm metin slot'larında <code>maxLines + ellipsis</code>. Dinamik metin <b>TR: max 18 karakter</b>, <b>EN: max 22 karakter</b> (tek satır butonlar için).
      </Section>

      <Section title="Font">
        Başlıklar: <b>Orbitron / Russo One</b> (retro-futurist). Body: <b>Inter / SF Pro</b>. Sayılar için tabular-nums.
      </Section>
    </div>
  );
}

function HandoffAnimations() {
  const anims = [
    ['Countdown (3-2-1-GO)', '800ms/rakam', 'scale 2.4→1 easeOut, fade out 0.6× scale'],
    ['Screen transition',    '150ms',       'cross-fade opacity'],
    ['Button press',          '100ms',       'scale 0.96, haptic light'],
    ['Hotspot hover (web)',   '150ms',       'background rgba white 8%'],
    ['Joystick snap back',    '200ms',       'cubic-bezier(.2,.8,.4,1)'],
    ['Toggle switch',         '180ms',       'easeInOut + glow pulse'],
    ['Paywall plan select',   '180ms',       'border + shadow lerp'],
    ['Victory confetti',      '2000ms loop', 'Lottie önerisi veya particle system'],
    ['Coin HUD pulse',        '1200ms loop', 'scale 1→1.04, opacity 0.85→1'],
    ['Heart lose',            '300ms',       'scale 1→1.3→0, fade, crack overlay'],
    ['Powerup cooldown ring', 'real-time',   'CircularProgressIndicator ters yönde'],
  ];
  return (
    <div style={{
      background: '#0a0e27', color: '#fff', height: '100%',
      fontFamily: '-apple-system, system-ui, sans-serif', padding: 24,
      overflowY: 'auto', boxSizing: 'border-box', fontSize: 12,
    }}>
      <div style={{ fontSize: 11, letterSpacing: 2, color: '#00d4ff', fontWeight: 800, marginBottom: 14 }}>MOTION SPECS</div>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 11 }}>
        <thead>
          <tr style={{ borderBottom: '1px solid rgba(255,255,255,.15)' }}>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>EVENT</th>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>SÜRE</th>
            <th style={{ textAlign: 'left', padding: '8px 4px', color: '#ffd700', fontSize: 10, letterSpacing: 1 }}>CURVE / NOT</th>
          </tr>
        </thead>
        <tbody>
          {anims.map(([e, d, n]) => (
            <tr key={e} style={{ borderBottom: '1px solid rgba(255,255,255,.06)' }}>
              <td style={{ padding: '8px 4px', color: '#00d4ff', fontWeight: 600 }}>{e}</td>
              <td style={{ padding: '8px 4px', color: '#ffd700', fontFamily: 'monospace' }}>{d}</td>
              <td style={{ padding: '8px 4px', color: 'rgba(255,255,255,.85)', lineHeight: 1.5 }}>{n}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div style={{
        marginTop: 16, padding: 12,
        background: 'rgba(0,212,255,.08)',
        border: '1px solid rgba(0,212,255,.2)',
        borderRadius: 8, lineHeight: 1.5, fontSize: 11,
      }}>
        <b style={{ color: '#00d4ff' }}>Flutter:</b> Tüm easing için <code>Curves.easeOutCubic</code>, press için <code>Curves.easeOut</code>. Haptic: <code>HapticFeedback.lightImpact()</code> butonlar, <code>heavyImpact()</code> game over'da.
      </div>
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: '#ffd700', marginBottom: 6, letterSpacing: 0.3 }}>{title}</div>
      <div style={{ color: 'rgba(255,255,255,.85)' }}>{children}</div>
    </div>
  );
}

// Mount
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
