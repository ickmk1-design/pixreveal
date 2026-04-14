import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/pixreveal_game.dart';
import '../game/components/player.dart';
import '../game/levels/level_manager.dart';
import '../main.dart' show adServiceProvider;
import '../providers/token_provider.dart';
import '../screens/level_select_screen.dart';
import '../utils/constants.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  final String imageFile;
  final String categoryName;
  final List<String> categoryImages;
  const GameScreen({
    super.key,
    required this.levelId,
    this.imageFile = 'level_1.jpg',
    this.categoryName = 'SUPER CARS',
    this.categoryImages = const ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'],
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  PixRevealGame? _game;
  bool _showPauseOverlay = false;
  bool _showGameOver = false;
  bool _showTokenInsert = true; // Start with token animation
  bool _showReveal = false;
  late AnimationController _tokenAnimCtrl;

  @override
  void initState() {
    super.initState();
    // Switch to landscape for gameplay
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _tokenAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Use Future.microtask to avoid modifying provider during build
    Future.microtask(() {
      if (!mounted) return;
      final tokenState = ref.read(tokenProvider);
      if (tokenState.tokens <= 0) {
        // Auto-refill for testing (remove before production)
        ref.read(tokenProvider.notifier).addTokens(10);
      }

      // Spend 1 token, get 3 lives
      ref.read(tokenProvider.notifier).useToken();

      // Play token insert animation
      _tokenAnimCtrl.forward().then((_) {
        if (mounted) {
          setState(() {
            _showTokenInsert = false;
            _initGame();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    // Return to portrait when leaving game
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _tokenAnimCtrl.dispose();
    super.dispose();
  }

  void _initGame() {
    final config = LevelManager.getLevel(widget.levelId);
    // ignore: avoid_print
    print('=== GAME START: Level ${widget.levelId}, Image: ${widget.imageFile} ===');

    final tokens = ref.read(tokenProvider).tokens;
    _game = PixRevealGame(
      levelConfig: config,
      lives: GameConfig.livesPerToken,
      tokens: tokens,
      imageFile: widget.imageFile,
    );

    _game!.onWin = (captured, stars) async {
      if (stars >= 3) ref.read(tokenProvider.notifier).awardThreeStarBonus();
      _unlockNextLevel(widget.levelId);

      // Show reveal overlay
      if (mounted) setState(() => _showReveal = true);
      await Future.delayed(const Duration(seconds: 3));

      // Close reveal BEFORE navigating
      if (mounted) setState(() => _showReveal = false);

      // Ad
      try {
        final adService = ref.read(adServiceProvider);
        await adService.notifyLevelComplete();
      } catch (_) {}

      if (!mounted) return;
      context.go('/result', extra: {
        'levelId': widget.levelId,
        'captured': captured,
        'stars': stars,
        'timeSeconds': _game!.elapsedSeconds,
        'imageAsset': 'assets/images/${widget.imageFile}',
        'imageFile': widget.imageFile,
        'categoryName': widget.categoryName,
        'categoryImages': widget.categoryImages,
      });
    };

    _game!.onLose = () {
      // All 3 lives lost — show game over
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showGameOver = true);
      });
    };

    _game!.onLifeLost = (lives) {
      // Don't use tokenProvider.loseLife here — game manages its own lives
    };

    setState(() {});
  }

  void _continueWithToken() {
    final tokenState = ref.read(tokenProvider);
    if (tokenState.tokens <= 0) return;
    ref.read(tokenProvider.notifier).useToken();
    setState(() {
      _showGameOver = false;
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Flame Game
          if (_game != null && !_showTokenInsert)
            GameWidget(game: _game!, autofocus: true),

          // D-Pad — small, bottom-right corner
          if (!_showTokenInsert && !_showGameOver && !_showPauseOverlay)
            Positioned(
              bottom: 20, left: 20,
              child: _buildDPad(),
            ),

          // Pause button
          if (!_showTokenInsert && !_showGameOver)
            Positioned(
              top: 8, right: 8,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.neonBlue, width: 1),
                    ),
                    child: Icon(
                      _showPauseOverlay ? Icons.play_arrow : Icons.pause,
                      color: AppColors.neonBlue, size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Token insert animation
          if (_showTokenInsert) _buildTokenInsert(),

          // Pause overlay
          if (_showPauseOverlay) _buildPauseOverlay(),

          // Game Over overlay
          if (_showGameOver) _buildGameOver(),

          // Reveal overlay — fullscreen image for 3 seconds after win
          if (_showReveal) _buildRevealOverlay(),
        ],
      ),
    );
  }

  // ---- TOKEN INSERT ANIMATION ----
  Widget _buildTokenInsert() {
    return GestureDetector(
      onTap: () {
        _tokenAnimCtrl.stop();
        setState(() {
          _showTokenInsert = false;
          if (_game == null) _initGame();
        });
      },
      child: AnimatedBuilder(
        animation: _tokenAnimCtrl,
        builder: (context, _) {
          final progress = _tokenAnimCtrl.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Reference image background
              Image.asset('assets/images/ui/token_insert_bg.png', fit: BoxFit.cover),
              // Subtle fade-out near end
              Container(
                color: Colors.black.withValues(
                  alpha: progress > 0.9 ? (progress - 0.9) * 10 : 0,
                ),
              ),
              // Tap to skip hint
              Positioned(
                bottom: 30, left: 0, right: 0,
                child: Center(
                  child: Text(
                    'TAP TO SKIP',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- GAME OVER ----
  Widget _buildGameOver() {
    final tokens = ref.watch(tokenProvider).tokens;
    return Container(
      color: AppColors.darkBg.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GAME OVER', style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 22, color: AppColors.red,
              shadows: [Shadow(color: AppColors.red, blurRadius: 12)],
            )),
            const SizedBox(height: 12),
            Text(
              '${(_game?.capturedPercent ?? 0) * 100 ~/ 1}% CAPTURED',
              style: const TextStyle(
                fontFamily: 'PressStart2P', fontSize: 10, color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            if (tokens > 0) ...[
              _pauseBtn('CONTINUE (1 JETON)', AppColors.neonGreen, _continueWithToken),
              const SizedBox(height: 8),
              Text('$tokens jeton kaldi', style: const TextStyle(
                fontFamily: 'PressStart2P', fontSize: 7, color: AppColors.neonYellow,
              )),
              const SizedBox(height: 16),
            ] else ...[
              const Text('JETON YOK!', style: TextStyle(
                fontFamily: 'PressStart2P', fontSize: 10, color: AppColors.neonYellow,
              )),
              const SizedBox(height: 16),
            ],
            _pauseBtn('ANA MENU', AppColors.neonBlue, () => context.go('/menu')),
          ],
        ),
      ),
    );
  }

  // ---- VIRTUAL JOYSTICK ----
  Widget _buildDPad() {
    return _VirtualJoystick(
      onDirection: (dir) => _game?.handleDirection(dir),
    );
  }

  // ---- PAUSE ----
  Widget _buildPauseOverlay() {
    return Container(
      color: AppColors.darkBg.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PAUSED', style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 24, color: AppColors.neonPink,
              shadows: [Shadow(color: AppColors.neonPink, blurRadius: 12)],
            )),
            const SizedBox(height: 40),
            _pauseBtn('RESUME', AppColors.neonGreen, _togglePause),
            const SizedBox(height: 16),
            _pauseBtn('QUIT', AppColors.red, () => context.go('/levels')),
          ],
        ),
      ),
    );
  }

  Widget _pauseBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220, padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard, borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
        ),
        child: Center(child: Text(text, style: TextStyle(
          fontFamily: 'PressStart2P', fontSize: 10, color: color,
        ))),
      ),
    );
  }

  Widget _buildRevealOverlay() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.asset(
              'assets/images/${widget.imageFile}',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(color: AppColors.darkBg),
            ),
          ),
          // Bottom gradient + complete text
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 80, bottom: 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LEVEL COMPLETE',
                      style: TextStyle(
                        fontFamily: 'PressStart2P', fontSize: 18,
                        color: AppColors.neonGreen,
                        shadows: [Shadow(color: AppColors.neonGreen, blurRadius: 16)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('IMAGE REVEALED',
                      style: TextStyle(
                        fontFamily: 'PressStart2P', fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockNextLevel(int currentLevel) async {
    final nextLevel = currentLevel + 1;
    final prefs = await SharedPreferences.getInstance();
    // Per-category unlock key
    final key = 'unlocked_${widget.categoryName}';
    final current = prefs.getInt(key) ?? 1;
    if (nextLevel > current) {
      await prefs.setInt(key, nextLevel);
    }
  }

  void _togglePause() {
    setState(() {
      _showPauseOverlay = !_showPauseOverlay;
      if (_showPauseOverlay) _game?.pauseGame();
      else _game?.resumeGame();
    });
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({super.key, required Animation<double> animation,
    required this.builder}) : super(listenable: animation);
  @override
  Widget build(BuildContext context) => builder(context, null);
}

/// Virtual joystick — large translucent circle with thumb + 4 direction arrows.
class _VirtualJoystick extends StatefulWidget {
  final void Function(MoveDirection) onDirection;
  const _VirtualJoystick({required this.onDirection});

  @override
  State<_VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<_VirtualJoystick> {
  static const double _size = 100; // compact, less intrusive
  Offset _thumbOffset = Offset.zero;
  MoveDirection _lastDir = MoveDirection.none;

  void _handleDrag(Offset localPosition) {
    final center = const Offset(_size / 2, _size / 2);
    final delta = localPosition - center;
    final dist = delta.distance;
    const maxRadius = _size / 2 - 18;

    // Clamp thumb to circle
    Offset thumb;
    if (dist > maxRadius) {
      thumb = Offset(delta.dx / dist * maxRadius, delta.dy / dist * maxRadius);
    } else {
      thumb = delta;
    }

    // Dead zone
    if (dist < 15) {
      setState(() { _thumbOffset = thumb; });
      return;
    }

    // Determine 4-way direction (pick dominant axis)
    MoveDirection dir;
    if (delta.dx.abs() > delta.dy.abs()) {
      dir = delta.dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      dir = delta.dy > 0 ? MoveDirection.down : MoveDirection.up;
    }

    setState(() { _thumbOffset = thumb; });
    if (dir != _lastDir) {
      _lastDir = dir;
      widget.onDirection(dir);
    }
  }

  void _reset() {
    setState(() {
      _thumbOffset = Offset.zero;
      _lastDir = MoveDirection.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        final box = context.findRenderObject() as RenderBox;
        _handleDrag(box.globalToLocal(e.position));
      },
      onPointerMove: (e) {
        final box = context.findRenderObject() as RenderBox;
        _handleDrag(box.globalToLocal(e.position));
      },
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Container(
              width: _size, height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.25),
                border: Border.all(
                  color: const Color(0xFF4466DD).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4466DD).withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            // Direction arrows
            const Positioned(top: 8, child: Icon(Icons.arrow_drop_up,
              color: Color(0x66FFFFFF), size: 20)),
            const Positioned(bottom: 8, child: Icon(Icons.arrow_drop_down,
              color: Color(0x66FFFFFF), size: 20)),
            const Positioned(left: 8, child: Icon(Icons.arrow_left,
              color: Color(0x66FFFFFF), size: 20)),
            const Positioned(right: 8, child: Icon(Icons.arrow_right,
              color: Color(0x66FFFFFF), size: 20)),
            // Thumb
            Transform.translate(
              offset: _thumbOffset,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF334499), Color(0xFF0D0D2A)],
                    stops: [0.2, 1.0],
                  ),
                  border: Border.all(color: const Color(0xFF88AAFF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4466DD).withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
