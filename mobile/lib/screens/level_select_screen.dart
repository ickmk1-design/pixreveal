import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../widgets/star_rating.dart';
import '../widgets/token_display.dart';
import '../widgets/retro_card.dart';
import '../game/levels/level_manager.dart';
import '../providers/token_provider.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);
    final levels = LevelManager.getWorldLevels(1);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonBlue),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text(
          'NEON CITY',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: AppColors.neonPink,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: TokenDisplay(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            // First level always unlocked, rest need previous completed
            final isUnlocked = index == 0 || index <= 10;

            return GestureDetector(
              onTap: isUnlocked
                  ? () => _startLevel(context, ref, level.id, tokenState.lives)
                  : null,
              child: RetroCard(
                borderColor: level.isBoss
                    ? AppColors.red
                    : isUnlocked
                        ? AppColors.neonBlue
                        : AppColors.gridLine,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Level number
                    Text(
                      level.isBoss ? 'BOSS' : '${level.id}',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: level.isBoss ? 10 : 18,
                        color: isUnlocked
                            ? (level.isBoss
                                ? AppColors.red
                                : AppColors.neonPink)
                            : AppColors.gridLine,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Level name
                    Text(
                      level.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 6,
                        color: isUnlocked ? AppColors.white : AppColors.gridLine,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Stars (placeholder: 0)
                    StarRating(stars: 0, size: 16),
                    if (!isUnlocked)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.lock,
                          color: AppColors.gridLine,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startLevel(
      BuildContext context, WidgetRef ref, int levelId, int currentLives) {
    final tokenNotifier = ref.read(tokenProvider.notifier);

    // If no lives, need to insert token
    if (currentLives <= 0) {
      final success = tokenNotifier.useToken();
      if (!success) {
        // No tokens - show shop dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: const Text(
              'NO TOKENS!',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: AppColors.red,
              ),
            ),
            content: const Text(
              'Insert a token to continue.\nVisit the shop to get more!',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: AppColors.white,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/shop');
                },
                child: const Text(
                  'SHOP',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: AppColors.gold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: AppColors.neonBlue,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }
    }

    context.go('/game/$levelId');
  }
}
