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

/// Category definitions — all categories free (free-to-play model).
/// VIP entitlement = reklamsız + sınırsız can + tüm power-up açık (kategori kilidi YOK).
enum GameCategory {
  cars,      // SÜPER ARABALAR
  space,     // DERİN UZAY
  animals,   // VAHŞİ HAYVANLAR
  beach,     // SAHİL
  fitness,   // FITNESS
  ownImage,  // KENDİ FOTOĞRAFIN
  fantasy,   // FANTASTİK
}

extension GameCategoryX on GameCategory {
  // isPremium artık kategori kilidi için kullanılmıyor.
  // VIP perks (reklamsız/can/power-up) EntitlementService.isPremium ile kontrol edilir.
  bool get isPremium => false;

  String get displayName {
    switch (this) {
      case GameCategory.cars:     return 'SÜPER ARABALAR';
      case GameCategory.space:    return 'DERİN UZAY';
      case GameCategory.animals:  return 'VAHŞİ HAYVANLAR';
      case GameCategory.beach:    return 'SAHİL';
      case GameCategory.fitness:  return 'FITNESS';
      case GameCategory.ownImage: return 'KENDİ FOTOĞRAFIN';
      case GameCategory.fantasy:  return 'FANTASTİK';
    }
  }

  /// Category key used to build level image asset paths: {assetKey}_{levelId}.jpg
  String get assetKey {
    switch (this) {
      case GameCategory.cars:     return 'cars';
      case GameCategory.space:    return 'space';
      case GameCategory.animals:  return 'animal';
      case GameCategory.beach:    return 'glamour'; // dosya adları glamour_N.jpg — değiştirilmedi
      case GameCategory.fitness:  return 'fitness';
      case GameCategory.ownImage: return 'custom';
      case GameCategory.fantasy:  return 'fantasy';
    }
  }
}

/// Currently selected category — held in memory during a play session.
class CurrentCategory {
  static GameCategory _current = GameCategory.cars;
  static GameCategory get current => _current;
  static void set(GameCategory c) => _current = c;
}
