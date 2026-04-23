import 'package:shared_preferences/shared_preferences.dart';

/// Tracks level progression and category unlocks using SharedPreferences.
/// - highest_unlocked_level: int (default 1). Player completed this many levels.
/// - category_X_unlocked: bool (by premium purchase or promo)
class LevelProgress {
  static const _kHighestLevel = 'highest_unlocked_level';
  static const _kLastCompleted = 'last_completed_level';

  static Future<int> highestUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kHighestLevel) ?? 1;
  }

  static Future<int> lastCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLastCompleted) ?? 0;
  }

  /// Call when a level is successfully completed.
  /// Unlocks the next level if not already.
  static Future<void> markCompleted(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastCompleted, levelId);
    final current = prefs.getInt(_kHighestLevel) ?? 1;
    final nextLevel = levelId + 1;
    if (nextLevel > current) {
      await prefs.setInt(_kHighestLevel, nextLevel);
    }
  }

  /// Next level to play (from victory screen NEXT button)
  static Future<int> nextPlayableLevel() async {
    final last = await lastCompleted();
    return last + 1;
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHighestLevel);
    await prefs.remove(_kLastCompleted);
  }
}

/// Category definitions — matches what's in categories.png visually.
/// Free: cars, space, animals (first 3)
/// Premium: beach, fitness (last 2)
/// Custom: own image (premium)
enum GameCategory {
  cars,      // SÜPER ARABALAR — free
  space,     // DERİN UZAY — free
  animals,   // VAHŞİ HAYVANLAR — free
  beach,     // PLAJ GLAMOUR — premium
  fitness,   // FITNESS — premium
  ownImage,  // KENDİ FOTOĞRAFIN — premium
}

extension GameCategoryX on GameCategory {
  bool get isPremium {
    switch (this) {
      case GameCategory.cars:
      case GameCategory.space:
      case GameCategory.animals:
        return false;
      case GameCategory.beach:
      case GameCategory.fitness:
      case GameCategory.ownImage:
        return true;
    }
  }

  String get displayName {
    switch (this) {
      case GameCategory.cars: return 'SÜPER ARABALAR';
      case GameCategory.space: return 'DERİN UZAY';
      case GameCategory.animals: return 'VAHŞİ HAYVANLAR';
      case GameCategory.beach: return 'PLAJ GLAMOUR';
      case GameCategory.fitness: return 'FITNESS';
      case GameCategory.ownImage: return 'KENDİ FOTOĞRAFIN';
    }
  }

  /// Category key used to build level image asset paths
  String get assetKey {
    switch (this) {
      case GameCategory.cars: return 'cars';
      case GameCategory.space: return 'space';
      case GameCategory.animals: return 'animal';
      case GameCategory.beach: return 'glamour';
      case GameCategory.fitness: return 'fitness';
      case GameCategory.ownImage: return 'custom';
    }
  }
}

/// Currently selected category — held in memory during a play session.
class CurrentCategory {
  static GameCategory _current = GameCategory.cars;
  static GameCategory get current => _current;
  static void set(GameCategory c) => _current = c;
}
