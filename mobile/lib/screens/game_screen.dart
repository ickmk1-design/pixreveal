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
import '../widgets/joystick_overlay.dart';

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
  late final String _imageFile;

  _GameOutcome _outcome = _GameOutcome.none;

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
      ..onWin = (captured, stars, score, combo, elapsed) {
        if (_outcome != _GameOutcome.none) return;
        _outcome = _GameOutcome.won;
        AudioService.play('level_complete');
        final tokenReward = 10 + combo * 2 + stars * 5;
        TokenService.instance.addTokens(tokenReward);
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
        LevelProgress.markCompleted(widget.levelId);
      }
      ..onLose = () {
        if (_outcome != _GameOutcome.none) return;
        _outcome = _GameOutcome.lost;
        _goToGameover();
      };
  }

  @override
  void dispose() {
    TokenService.instance.notifier.removeListener(_onTokenChanged);
    _revealCtrl.dispose();
    super.dispose();
  }

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

  /// Joystick analog vektörünü 4-yön MoveDirection'a çevirir.
  void _onJoystickMove(Offset dir) {
    if (dir == Offset.zero) {
      _game.handleDirection(MoveDirection.none);
      return;
    }
    final ax = dir.dx.abs();
    final ay = dir.dy.abs();
    if (ax >= ay) {
      _game.handleDirection(dir.dx > 0 ? MoveDirection.right : MoveDirection.left);
    } else {
      _game.handleDirection(dir.dy > 0 ? MoveDirection.down : MoveDirection.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Game layer ──────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1024 / 1536,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final rect = Rect.fromLTWH(
                      0, 0, constraints.maxWidth, constraints.maxHeight,
                    );
                    return Stack(
                      children: [
                        // Oyun alanı — Flame GameWidget (joystick kontrolü)
                        Positioned.fill(
                          child: GameWidget<PixRevealGame>(game: _game),
                        ),
                        // Sol-alt sabit joystick
                        if (!_showReveal)
                          JoystickOverlay(
                            imgRect: rect,
                            onMove: _onJoystickMove,
                          ),
                        // Sağ üst: ev + pause butonları
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
                    );
                  },
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
