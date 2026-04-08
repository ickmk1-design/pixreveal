class LevelConfig {
  final int id;
  final int worldId;
  final String name;
  final int enemyCount;
  final List<String> enemyTypes;
  final double enemySpeedMultiplier;
  final bool isBoss;

  const LevelConfig({
    required this.id,
    required this.worldId,
    required this.name,
    required this.enemyCount,
    required this.enemyTypes,
    this.enemySpeedMultiplier = 1.0,
    this.isBoss = false,
  });
}
