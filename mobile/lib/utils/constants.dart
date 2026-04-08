import 'package:flutter/material.dart';

class AppColors {
  static const neonPink = Color(0xFFFF00FF);
  static const neonBlue = Color(0xFF00FFFF);
  static const neonGreen = Color(0xFF00FF00);
  static const neonYellow = Color(0xFFFFFF00);
  static const neonOrange = Color(0xFFFF6600);
  static const arcadePurple = Color(0xFF6600CC);
  static const darkBg = Color(0xFF0A0A1A);
  static const darkCard = Color(0xFF1A1A2E);
  static const gridLine = Color(0xFF2A2A4A);
  static const white = Color(0xFFFFFFFF);
  static const red = Color(0xFFFF0044);
  static const gold = Color(0xFFFFD700);
}

class GameConfig {
  static const double playerSpeed = 200.0;
  static const double playerSize = 16.0;
  static const double trailWidth = 3.0;
  static const double enemyBaseSpeed = 80.0;

  static const int livesPerToken = 3;
  static const int dailyLoginTokens = 2;
  static const int adRewardTokens = 1;
  static const int maxAdRewardsPerDay = 10;
  static const int threeStarBonusTokens = 1;

  static const double oneStarThreshold = 0.80;
  static const double twoStarThreshold = 0.90;
  static const double threeStarThreshold = 0.95;
  static const double winThreshold = 0.80;

  static const int maxEnemiesOnScreen = 5;
  static const int bossEveryNLevels = 10;

  static const double gameWidth = 400;
  static const double gameHeight = 700;
}

class AssetPaths {
  static const String imagesDir = 'assets/images/';
  static const String audioDir = 'assets/audio/';
}

class AppConstants {
  static const String apiBaseUrl = 'https://api.pixreveal.app';
  static const String privacyUrl = 'https://api.pixreveal.app/privacy';
  static const String termsUrl = 'https://api.pixreveal.app/terms';
}
