import 'dart:math' show sqrt;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game/pixreveal_game.dart';
import '../game/levels/level_manager.dart';
import '../game/components/player.dart';
import '../game/utils/game_constants.dart';
import '../services/level_progress.dart';
import '../services/audio_service.dart';
import '../services/token_service.dart';

/// Dokunmatik kontrol ayarları — tek yerden değiştir.
class TouchControlConfig {
  /// Minimum hareket — altındakiler yok sayılır (jitter filtresi).
  static const double deadZone = 4.0;
  /// Eksen değiştirmek için yeni eksenin mevcut ekseni geçmesi gereken oran.
  /// Yüksek → daha yapışkan/kararlı, düşük → daha çevik.
  static const double turnDominanceRatio = 1.4;
  /// Eksen değiştirmek için yeni eksende minimum hareket (px, anchor'dan).
  static const double turnMinDelta = 12.0;
}

/// Kazanınca tam resim gösterme süresi (saniye).
class RevealConfig {
  static const int holdSeconds = 4;
}

class HudScreen extends StatefulWidget {
  final int levelId;
  const HudScreen({super.key, this.levelId = 1});

  @override
  State<HudScreen> createState() => _HudScreenState();
}

enum _GameOutcome { none, won, lost }

class _HudScreenState extends State<HudScreen> with TickerProviderStateMixin {
  late final PixRevealGame _game;
  late final String _imageFile; // field so closure captures stable reference

  // Outcome guard — once set, the other path is ignored entirely.
  _GameOutcome _outcome = _GameOutcome.none;

  // Touch hysteresis state — anchor resets on cross-axis direction change.
  Offset? _panAnchor;
  MoveDirection _currentDir = MoveDirection.none;

  // Reveal overlay state — only ever true on win path
  bool _showReveal = false;
  String _revealRoute = '';
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealScale;

  void _onTokenChanged() {
    _game.hud.tokens = TokenService.instance.balance;
  }

  @override
  void initState() {
    super.initState();
    TokenService.instance.notifier.addListener(_onTokenChanged);

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: RevealConfig.holdSeconds),
    );
    _revealScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _revealCtrl, curve: const Interval(0, 1)),
    );

    final cfg = LevelManager.levels.firstWhere(
      (l) => l.id == widget.levelId,
      orElse: () => LevelManager.levels.first,
    );
    _imageFile = '${CurrentCategory.current.assetKey}_${cfg.id}.jpg';
    // ignore: avoid_print
    print('GAME loading: cat=${CurrentCategory.current.name} file=$_imageFile');

    _game = PixRevealGame(
      levelConfig: cfg,
      lives: 3,
      tokens: TokenService.instance.balance,
      imageFile: _imageFile,
    )
      // ── WIN PATH: reveal overlay → victory ──────────────────────
      // Synchronous callback — setState fires in the same frame as win
      // detection, guaranteed visible before any navigation.
      ..onWin = (captured, stars, score, combo, elapsed) {
        if (_outcome != _GameOutcome.none) return; // already ended — ignore
        _outcome = _GameOutcome.won;
        AudioService.play('level_complete');
        // Token ödülü: temel 10 + combo×2 + yıldız×5
        final tokenReward = 10 + combo * 2 + stars * 5;
        TokenService.instance.addTokens(tokenReward); // fire-and-forget
        if (!mounted) return;
        final route =
            '/victory?level=${widget.levelId}&score=$score&combo=$combo&time=$elapsed&tokens=$tokenReward';
        setState(() {
          _revealRoute = route;
          _showReveal = true;
        });
        _revealCtrl.forward();
        Future.delayed(
          const Duration(seconds: RevealConfig.holdSeconds),
          _dismissReveal,
        );
        LevelProgress.markCompleted(widget.levelId); // fire-and-forget
      }
      // ── LOSE PATH: straight to gameover — NO reveal, NO victory ─
      ..onLose = () {
        if (_outcome != _GameOutcome.none) return; // already ended — ignore
        _outcome = _GameOutcome.lost;
        // 'die' audio is already played inside pixreveal_game._die(); no dup.
        _goToGameover();
      };
  }

  @override
  void dispose() {
    TokenService.instance.notifier.removeListener(_onTokenChanged);
    _revealCtrl.dispose();
    super.dispose();
  }

  // Called after 4s or on tap — only valid during win path.
  void _dismissReveal() {
    if (_outcome != _GameOutcome.won) return;
    if (!_showReveal) return;
    setState(() => _showReveal = false);
    _navigateTo(_revealRoute);
  }

  void _goToGameover() {
    _navigateTo('/gameover?level=${widget.levelId}');
  }

  void _navigateTo(String route) {
    Future.microtask(() {
      if (!mounted) return;
      context.go(route);
    });
  }

  void _onPanStart(DragStartDetails details) {
    _panAnchor = details.localPosition;
    _currentDir = MoveDirection.none;
    if (!_showReveal) _game.handleDirection(MoveDirection.none);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_showReveal || _panAnchor == null) return;
    final delta = details.localPosition - _panAnchor!;
    final newDir = _snapWithHysteresis(delta);
    if (newDir != null) {
      if (newDir != _currentDir) {
        // Reset anchor only on cross-axis turns to prevent accumulation bias.
        if (_isCrossAxis(_currentDir, newDir)) {
          _panAnchor = details.localPosition;
        }
        _currentDir = newDir;
      }
      _game.handleDirection(_currentDir);
    }
  }

  void _onPanEnd(DragEndDetails _) {
    _currentDir = MoveDirection.none;
    _panAnchor = null;
    if (!_showReveal) _game.handleDirection(MoveDirection.none);
  }

  void _onPanCancel() {
    _currentDir = MoveDirection.none;
    _panAnchor = null;
    if (!_showReveal) _game.handleDirection(MoveDirection.none);
  }

  /// Anchor'dan birikmiş vektöre hysteresis uygular.
  /// Null → dead-zone içinde, mevcut yönde devam.
  MoveDirection? _snapWithHysteresis(Offset delta) {
    final ax = delta.dx.abs();
    final ay = delta.dy.abs();
    final mag = sqrt(ax * ax + ay * ay);
    if (mag < TouchControlConfig.deadZone) return null;

    if (_currentDir == MoveDirection.none) {
      // İlk yön — dominant eksene snap.
      return ax > ay
          ? (delta.dx > 0 ? MoveDirection.right : MoveDirection.left)
          : (delta.dy > 0 ? MoveDirection.down : MoveDirection.up);
    }

    final curIsH = _currentDir == MoveDirection.left ||
        _currentDir == MoveDirection.right;

    if (curIsH) {
      // Yatay gidiyoruz — dikeye geçmek için ay yeterince baskın olmalı.
      if (ay >= ax * TouchControlConfig.turnDominanceRatio &&
          ay >= TouchControlConfig.turnMinDelta) {
        return delta.dy > 0 ? MoveDirection.down : MoveDirection.up;
      }
      // Aynı eksende kal; sol↔sağ geçişe izin ver.
      return delta.dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      // Dikey gidiyoruz — yataya geçmek için ax yeterince baskın olmalı.
      if (ax >= ay * TouchControlConfig.turnDominanceRatio &&
          ax >= TouchControlConfig.turnMinDelta) {
        return delta.dx > 0 ? MoveDirection.right : MoveDirection.left;
      }
      // Aynı eksende kal; yukarı↔aşağı geçişe izin ver.
      return delta.dy > 0 ? MoveDirection.down : MoveDirection.up;
    }
  }

  static bool _isCrossAxis(MoveDirection a, MoveDirection b) {
    if (a == MoveDirection.none || b == MoveDirection.none) return false;
    final aH = a == MoveDirection.left || a == MoveDirection.right;
    final bH = b == MoveDirection.left || b == MoveDirection.right;
    return aH != bH;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      // Outer Stack: lets the reveal overlay cover the full Scaffold body
      // (above SafeArea + AspectRatio constraints), guaranteeing z-order.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Game layer ──────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1024 / 1536,
                child: Stack(
                  children: [
                    // Oyun alanı — anchor-tabanlı hysteresis pan kontrolü
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart:  _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd:    _onPanEnd,
                        onPanCancel: _onPanCancel,
                        child: GameWidget<PixRevealGame>(game: _game),
                      ),
                    ),
                    // Sağ üst: ev + pause butonları (hidden during reveal)
                    if (!_showReveal)
                      Positioned(
                        top: GameConstants.hudHeight + 8,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _HudButton(
                              icon: Icons.home_outlined,
                              onTap: () {
                                AudioService.play('button_click');
                                _navigateTo('/menu');
                              },
                            ),
                            const SizedBox(height: 8),
                            _HudButton(
                              icon: Icons.pause,
                              onTap: () {
                                AudioService.play('button_click');
                                if (_game.gameState == PixGameState.playing) {
                                  _game.pauseGame();
                                } else {
                                  _game.resumeGame();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Reveal overlay — full-screen, above SafeArea + AspectRatio ──
          if (_showReveal)
            Positioned.fill(
              child: _RevealOverlay(
                imagePath: 'assets/images/$_imageFile',
                scaleAnimation: _revealScale,
                onTap: _dismissReveal,
              ),
            ),
        ],
      ),
    );
  }
}

class _RevealOverlay extends StatelessWidget {
  final String imagePath;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _RevealOverlay({
    required this.imagePath,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ken Burns: yavaş zoom
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (_, __) => Transform.scale(
                scale: scaleAnimation.value,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Colors.black),
                ),
              ),
            ),
            // Alt kısımda "dokun / devam et" ipucu
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'DEVAM ETMEK İÇİN DOKUN',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HudButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
