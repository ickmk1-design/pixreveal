import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../game/pixreveal_game.dart';
import '../game/levels/level_manager.dart';
import '../providers/token_provider.dart';
import '../utils/constants.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late PixRevealGame _game;
  bool _showPauseOverlay = false;

  @override
  void initState() {
    super.initState();
    final config = LevelManager.getLevel(widget.levelId);
    final tokenState = ref.read(tokenProvider);

    _game = PixRevealGame(
      levelConfig: config,
      lives: tokenState.lives > 0 ? tokenState.lives : GameConfig.livesPerToken,
    );

    _game.onWin = (captured, stars) {
      if (stars >= 3) {
        ref.read(tokenProvider.notifier).awardThreeStarBonus();
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go('/result', extra: {
            'levelId': widget.levelId,
            'captured': captured,
            'stars': stars,
            'timeSeconds': _game.elapsedSeconds,
          });
        }
      });
    };

    _game.onLose = () {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go('/result', extra: {
            'levelId': widget.levelId,
            'captured': _game.territory.capturedPercent,
            'stars': 0,
            'timeSeconds': _game.elapsedSeconds,
          });
        }
      });
    };

    _game.onLifeLost = (lives) {
      ref.read(tokenProvider.notifier).loseLife();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Flame Game
          GameWidget(game: _game),

          // Pause button
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.neonBlue, width: 1),
                  ),
                  child: Icon(
                    _showPauseOverlay ? Icons.play_arrow : Icons.pause,
                    color: AppColors.neonBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Pause overlay
          if (_showPauseOverlay) _buildPauseOverlay(),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: AppColors.darkBg.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 24,
                color: AppColors.neonPink,
                shadows: [
                  Shadow(color: AppColors.neonPink, blurRadius: 12),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _pauseButton('RESUME', AppColors.neonGreen, () {
              _togglePause();
            }),
            const SizedBox(height: 16),
            _pauseButton('RESTART', AppColors.neonYellow, () {
              setState(() => _showPauseOverlay = false);
              final config = LevelManager.getLevel(widget.levelId);
              final tokenState = ref.read(tokenProvider);
              _game = PixRevealGame(
                levelConfig: config,
                lives: tokenState.lives > 0
                    ? tokenState.lives
                    : GameConfig.livesPerToken,
              );
              setState(() {});
            }),
            const SizedBox(height: 16),
            _pauseButton('QUIT', AppColors.red, () {
              context.go('/levels');
            }),
          ],
        ),
      ),
    );
  }

  Widget _pauseButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _showPauseOverlay = !_showPauseOverlay;
      if (_showPauseOverlay) {
        _game.pauseGame();
      } else {
        _game.resumeGame();
      }
    });
  }
}
