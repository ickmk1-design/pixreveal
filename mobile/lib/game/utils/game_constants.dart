import 'dart:ui';

class GameConstants {
  // Player
  static const double playerSpeed = 180.0;
  static const double playerSize = 10.0;
  static const double playerGlowRadius = 14.0;

  // Trail
  static const double trailWidth = 3.5;
  static const double trailGlowWidth = 10.0;

  // Border
  static const double borderWidth = 3.0;
  static const double borderGlowWidth = 8.0;
  static const double borderTolerance = 5.0;

  // Colors - Neon Arcade
  static const Color borderColor = Color(0xFF00FFFF);
  static const Color borderGlowColor = Color(0x6600FFFF);
  static const Color trailColor = Color(0xFF00DDFF);
  static const Color trailGlowColor = Color(0x6600DDFF);
  static const Color playerColor = Color(0xFF00FF88);
  static const Color playerGlowColor = Color(0x6600FF88);
  static const Color capturedFlashColor = Color(0xAAFFFFFF);
  static const Color uncapturedColor = Color(0xF50A0A1A);
  static const Color enemyColor = Color(0xFFFF0044);
  static const Color enemyGlowColor = Color(0x66FF0044);
  static const Color hudBgColor = Color(0xDD080818);
  static const Color heartColor = Color(0xFFFF3366);
  static const Color progressBarBg = Color(0xFF1A1A3A);
  static const Color progressBarFill = Color(0xFF00FF88);

  // Gameplay
  static const double winThreshold = 0.80;
  static const double hudHeight = 56.0;

  // Particles
  static const int maxParticles = 60;
  static const double particleLifetime = 0.8;
}
