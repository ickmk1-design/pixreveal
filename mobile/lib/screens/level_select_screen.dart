import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/star_rating.dart';
import '../widgets/token_display.dart';
import '../widgets/retro_card.dart';
import '../game/levels/level_manager.dart';

/// Tracks highest unlocked level
final unlockedLevelProvider = StateProvider<int>((ref) => 1);

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  @override
  void initState() {
    super.initState();
    _loadUnlocked();
  }

  Future<void> _loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt('unlocked_level') ?? 1;
    ref.read(unlockedLevelProvider.notifier).state = unlocked;
  }

  @override
  Widget build(BuildContext context) {
    final levels = LevelManager.getWorldLevels(1);
    final unlockedLevel = ref.watch(unlockedLevelProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonBlue),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text('NEON CITY', style: TextStyle(
          fontFamily: 'PressStart2P', fontSize: 14, color: AppColors.neonPink,
        )),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: TokenDisplay()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final isUnlocked = level.id <= unlockedLevel;

            return GestureDetector(
              onTap: () {
                if (isUnlocked) {
                  context.go('/image-select/${level.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: AppColors.darkCard,
                    content: Text(
                      'Önce Level ${level.id - 1}\'i geç!',
                      style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 8,
                        color: AppColors.neonYellow),
                    ),
                  ));
                }
              },
              child: RetroCard(
                borderColor: !isUnlocked
                    ? AppColors.gridLine
                    : level.isBoss ? AppColors.red : AppColors.neonBlue,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isUnlocked)
                      const Icon(Icons.lock, color: AppColors.gridLine, size: 24)
                    else ...[
                      Text(
                        level.isBoss ? 'BOSS' : '${level.id}',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: level.isBoss ? 10 : 18,
                          color: level.isBoss ? AppColors.red : AppColors.neonPink,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(level.name, textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'PressStart2P', fontSize: 6,
                        color: isUnlocked ? AppColors.white : AppColors.gridLine),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    StarRating(stars: 0, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
