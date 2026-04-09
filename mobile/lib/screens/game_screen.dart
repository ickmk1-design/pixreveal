import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/pixreveal_game.dart';
import '../game/components/player.dart';
import '../game/levels/level_manager.dart';
import '../providers/token_provider.dart';
import '../screens/level_select_screen.dart';
import '../utils/constants.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  final String imageFile;
  const GameScreen({super.key, required this.levelId, this.imageFile = 'level_1.jpg'});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  PixRevealGame? _game;
  bool _showPauseOverlay = false;
  bool _showGameOver = false;
  bool _showTokenInsert = true; // Start with token animation
  late AnimationController _tokenAnimCtrl;

  @override
  void initState() {
    super.initState();
    _tokenAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Use Future.microtask to avoid modifying provider during build
    Future.microtask(() {
      if (!mounted) return;
      final tokenState = ref.read(tokenProvider);
      if (tokenState.tokens <= 0) {
        context.go('/levels');
        return;
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
    _tokenAnimCtrl.dispose();
    super.dispose();
  }

  void _initGame() {
    final config = LevelManager.getLevel(widget.levelId);

    final tokens = ref.read(tokenProvider).tokens;
    _game = PixRevealGame(
      levelConfig: config,
      lives: GameConfig.livesPerToken,
      tokens: tokens,
      imageFile: widget.imageFile,
    );

    _game!.onWin = (captured, stars) {
      if (stars >= 3) ref.read(tokenProvider.notifier).awardThreeStarBonus();
      // Unlock next level
      _unlockNextLevel(widget.levelId);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go('/result', extra: {
            'levelId': widget.levelId,
            'captured': captured,
            'stars': stars,
            'timeSeconds': _game!.elapsedSeconds,
          });
        }
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
              bottom: 10, right: 10,
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
        ],
      ),
    );
  }

  // ---- TOKEN INSERT ANIMATION ----
  Widget _buildTokenInsert() {
    return GestureDetector(
      onTap: () {
        // Skip animation
        _tokenAnimCtrl.stop();
        setState(() {
          _showTokenInsert = false;
          if (_game == null) _initGame();
        });
      },
      child: Container(
        color: AppColors.darkBg,
        child: Center(
          child: AnimatedBuilder(
            animation: _tokenAnimCtrl,
            builder: (context, _) {
              final progress = _tokenAnimCtrl.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coin slot
                  Container(
                    width: 80, height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.neonYellow, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonYellow.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Falling coin
                  Transform.translate(
                    offset: Offset(0, -80 + progress * 80),
                    child: Opacity(
                      opacity: progress < 0.8 ? 1.0 : (1.0 - (progress - 0.8) * 5).clamp(0.0, 1.0),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonYellow,
                          border: Border.all(color: const Color(0xFFFFAA00), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonYellow.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('J', style: TextStyle(
                            fontFamily: 'PressStart2P', fontSize: 16,
                            color: Color(0xFF885500),
                          )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // INSERT COIN text
                  Text('INSERT COIN', style: TextStyle(
                    fontFamily: 'PressStart2P', fontSize: 14,
                    color: AppColors.neonYellow.withValues(alpha: progress > 0.3 ? 1.0 : 0.0),
                    shadows: const [Shadow(color: AppColors.neonYellow, blurRadius: 8)],
                  )),
                  const SizedBox(height: 20),
                  // Hearts appearing
                  if (progress > 0.6) Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final heartProgress = ((progress - 0.6 - i * 0.1) * 5).clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Opacity(
                          opacity: heartProgress,
                          child: Transform.scale(
                            scale: 0.5 + heartProgress * 0.5,
                            child: const Icon(Icons.favorite,
                              color: AppColors.neonPink, size: 32),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  Text('TAP TO SKIP', style: TextStyle(
                    fontFamily: 'PressStart2P', fontSize: 7,
                    color: Colors.white.withValues(alpha: 0.3),
                  )),
                ],
              );
            },
          ),
        ),
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

  // ---- D-PAD ----
  Widget _buildDPad() {
    const s = 36.0; // button size
    const g = 2.0;  // gap
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        width: s * 3 + g * 2, height: s * 3 + g * 2,
        child: Stack(
          children: [
            Positioned(top: 0, left: s + g,
              child: _dpadBtn(Icons.keyboard_arrow_up, MoveDirection.up, s)),
            Positioned(bottom: 0, left: s + g,
              child: _dpadBtn(Icons.keyboard_arrow_down, MoveDirection.down, s)),
            Positioned(top: s + g, left: 0,
              child: _dpadBtn(Icons.keyboard_arrow_left, MoveDirection.left, s)),
            Positioned(top: s + g, right: 0,
              child: _dpadBtn(Icons.keyboard_arrow_right, MoveDirection.right, s)),
          ],
        ),
      ),
    );
  }

  Widget _dpadBtn(IconData icon, MoveDirection dir, double s) {
    return GestureDetector(
      onTapDown: (_) => _game?.handleDirection(dir),
      child: Container(
        width: s, height: s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: s * 0.7),
      ),
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

  Future<void> _unlockNextLevel(int currentLevel) async {
    final nextLevel = currentLevel + 1;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('unlocked_level') ?? 1;
    if (nextLevel > current) {
      await prefs.setInt('unlocked_level', nextLevel);
      if (mounted) {
        ref.read(unlockedLevelProvider.notifier).state = nextLevel;
      }
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
