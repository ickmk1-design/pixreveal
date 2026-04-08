import 'dart:ui';

class GameConstants {
  static const double playerSpeed = 200.0;
  static const double playerSize = 14.0;
  static const double trailWidth = 3.0;
  static const double borderWidth = 4.0;

  static const Color borderColor = Color(0xFF00FFFF);
  static const Color trailColor = Color(0xFFFF00FF);
  static const Color playerColor = Color(0xFFFFFF00);
  static const Color capturedColor = Color(0x00000000); // transparent reveal
  static const Color uncapturedColor = Color(0xFF1A1A2E);
  static const Color enemyColor = Color(0xFFFF0044);

  static const double winThreshold = 0.80;
}
