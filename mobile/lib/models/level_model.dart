class LevelModel {
  final int id;
  final int worldId;
  final String name;
  final String imageAsset;
  final int enemyCount;
  final List<String> enemyTypes;
  final double enemySpeedMultiplier;
  final bool isBoss;
  final bool isUnlocked;
  final int bestStars;
  final double bestCapture;

  const LevelModel({
    required this.id,
    required this.worldId,
    required this.name,
    required this.imageAsset,
    required this.enemyCount,
    required this.enemyTypes,
    this.enemySpeedMultiplier = 1.0,
    this.isBoss = false,
    this.isUnlocked = false,
    this.bestStars = 0,
    this.bestCapture = 0,
  });

  LevelModel copyWith({
    bool? isUnlocked,
    int? bestStars,
    double? bestCapture,
  }) {
    return LevelModel(
      id: id,
      worldId: worldId,
      name: name,
      imageAsset: imageAsset,
      enemyCount: enemyCount,
      enemyTypes: enemyTypes,
      enemySpeedMultiplier: enemySpeedMultiplier,
      isBoss: isBoss,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      bestStars: bestStars ?? this.bestStars,
      bestCapture: bestCapture ?? this.bestCapture,
    );
  }
}
