import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';
import '../widgets/star_rating.dart';
import '../game/levels/level_manager.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int levelId;
  final double captured;
  final int stars;
  final int timeSeconds;

  const ResultScreen({
    super.key,
    required this.levelId,
    required this.captured,
    required this.stars,
    required this.timeSeconds,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Show interstitial ad between levels (not during gameplay)
    final userState = ref.read(userProvider);
    if (!userState.isAdFree) {
      ref.read(adServiceProvider).showInterstitialIfReady();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.stars > 0;
    final level = LevelManager.getLevel(widget.levelId);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result title
                Text(
                  isWin ? 'LEVEL CLEAR!' : 'GAME OVER',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 22,
                    color: isWin ? AppColors.neonGreen : AppColors.red,
                    shadows: [
                      Shadow(
                        color: isWin ? AppColors.neonGreen : AppColors.red,
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  level.name,
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: AppColors.neonBlue,
                  ),
                ),

                const SizedBox(height: 32),

                // Stars
                if (isWin) ...[
                  StarRating(stars: widget.stars, size: 40),
                  const SizedBox(height: 24),
                ],

                // Stats
                _statRow('CAPTURED', '${(widget.captured * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                _statRow('TIME', _formatTime(widget.timeSeconds)),
                const SizedBox(height: 8),
                if (isWin && widget.stars >= 3)
                  _statRow('BONUS', '+1 TOKEN', valueColor: AppColors.gold),

                const SizedBox(height: 48),

                // Buttons
                if (isWin && !LevelManager.isLastLevel(widget.levelId))
                  NeonButton(
                    text: 'NEXT LEVEL',
                    onPressed: () => context.go('/game/${widget.levelId + 1}'),
                    color: AppColors.neonGreen,
                  ),
                const SizedBox(height: 12),
                NeonButton(
                  text: 'RETRY',
                  onPressed: () => context.go('/game/${widget.levelId}'),
                  color: AppColors.neonYellow,
                ),
                const SizedBox(height: 12),
                NeonButton(
                  text: 'LEVELS',
                  onPressed: () => context.go('/levels'),
                  color: AppColors.neonBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: AppColors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: valueColor ?? AppColors.neonGreen,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
