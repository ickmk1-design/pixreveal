import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game/pixreveal_game.dart';
import '../game/levels/level_manager.dart';
import '../game/components/player.dart';
import '../game/utils/game_constants.dart';
import '../services/level_progress.dart';
import '../services/audio_service.dart';

class HudScreen extends StatefulWidget {
  final int levelId;
  const HudScreen({super.key, this.levelId = 1});

  @override
  State<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends State<HudScreen> {
  late final PixRevealGame _game;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final cfg = LevelManager.levels.firstWhere(
      (l) => l.id == widget.levelId,
      orElse: () => LevelManager.levels.first,
    );
    final imageFile = '${CurrentCategory.current.assetKey}_${cfg.id}.jpg';
    // ignore: avoid_print
    print('GAME loading: cat=${CurrentCategory.current.name} file=$imageFile');

    _game = PixRevealGame(
      levelConfig: cfg,
      lives: 3,
      tokens: 1250,
      imageFile: imageFile,
    )
      ..onWin = (captured, stars, score, combo, elapsed) async {
        AudioService.play('level_complete');
        await LevelProgress.markCompleted(widget.levelId);
        _goOnce('/victory?level=${widget.levelId}&score=$score&combo=$combo&time=$elapsed');
      }
      ..onLose = () {
        AudioService.play('die');
        _goOnce('/gameover?level=${widget.levelId}');
      };
  }

  void _goOnce(String route) {
    if (_navigated) return;
    _navigated = true;
    Future.microtask(() {
      if (!mounted) return;
      context.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    // On tablets/web we clamp the playable area to the phone 2:3 aspect
    // so the game field doesn't stretch awkwardly. Stack overlay buttons
    // sit BELOW the in-game HUD bar (which Flame renders inside the game).
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1024 / 1536,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GameWidget<PixRevealGame>(game: _game),
                ),
                // Top-right control buttons — positioned BELOW the Flame
                // HUD bar (HUD bar is ~hudHeight pixels from top).
                // GameConstants.hudHeight is usually 60-70px.
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
                          _goOnce('/menu');
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
                // D-pad (bottom-left)
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: _DPad(onDirection: _game.handleDirection),
                ),
              ],
            ),
          ),
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

// ─── 4-direction D-pad for touch control ─────────────────────
class _DPad extends StatelessWidget {
  final void Function(MoveDirection) onDirection;
  const _DPad({required this.onDirection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.45),
                width: 2,
              ),
            ),
          ),
          Positioned(top: 8, child: _arrow(MoveDirection.up, Icons.keyboard_arrow_up)),
          Positioned(bottom: 8, child: _arrow(MoveDirection.down, Icons.keyboard_arrow_down)),
          Positioned(left: 8, child: _arrow(MoveDirection.left, Icons.keyboard_arrow_left)),
          Positioned(right: 8, child: _arrow(MoveDirection.right, Icons.keyboard_arrow_right)),
        ],
      ),
    );
  }

  Widget _arrow(MoveDirection dir, IconData icon) {
    return Listener(
      onPointerDown: (_) => onDirection(dir),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
          border: Border.all(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: const Color(0xFF00D4FF), size: 28),
      ),
    );
  }
}
