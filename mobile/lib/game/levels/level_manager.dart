import 'level_config.dart';

class LevelManager {
  static final List<LevelConfig> levels = [
    // World 1: Neon City (Levels 1-11)
    const LevelConfig(
      id: 1,
      worldId: 1,
      name: 'First Steps',
      enemyCount: 1,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.7,
    ),
    const LevelConfig(
      id: 2,
      worldId: 1,
      name: 'Getting Warmer',
      enemyCount: 1,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.8,
    ),
    const LevelConfig(
      id: 3,
      worldId: 1,
      name: 'Speed Up',
      enemyCount: 1,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.9,
    ),
    const LevelConfig(
      id: 4,
      worldId: 1,
      name: 'Double Trouble',
      enemyCount: 2,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.8,
    ),
    const LevelConfig(
      id: 5,
      worldId: 1,
      name: 'Web Walker',
      enemyCount: 2,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.9,
    ),
    const LevelConfig(
      id: 6,
      worldId: 1,
      name: 'Tangled',
      enemyCount: 2,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.0,
    ),
    const LevelConfig(
      id: 7,
      worldId: 1,
      name: 'Arachnophobia',
      enemyCount: 3,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 0.9,
    ),
    const LevelConfig(
      id: 8,
      worldId: 1,
      name: 'Crawl Space',
      enemyCount: 3,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.0,
    ),
    const LevelConfig(
      id: 9,
      worldId: 1,
      name: 'Silk Road',
      enemyCount: 3,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.1,
    ),
    const LevelConfig(
      id: 10,
      worldId: 1,
      name: 'SPIDER QUEEN',
      enemyCount: 4,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.0,
      isBoss: true,
    ),
    const LevelConfig(
      id: 11,
      worldId: 1,
      name: 'Aftermath',
      enemyCount: 3,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.2,
    ),
    const LevelConfig(
      id: 12,
      worldId: 1,
      name: 'Nightmare',
      enemyCount: 4,
      enemyTypes: ['spider'],
      enemySpeedMultiplier: 1.3,
      isBoss: true,
    ),
  ];

  static LevelConfig getLevel(int id) {
    return levels.firstWhere(
      (l) => l.id == id,
      orElse: () => levels.first,
    );
  }

  static int get totalLevels => levels.length;

  static List<LevelConfig> getWorldLevels(int worldId) {
    return levels.where((l) => l.worldId == worldId).toList();
  }

  static bool isLastLevel(int id) => id >= levels.length;
}
