import 'package:flutter/material.dart';

class PixTheme {
  // === COLORS ===
  static const Color bgDark = Color(0xFF050510);
  static const Color bgDeep = Color(0xFF0A0A1A);
  static const Color cardBg = Color(0x44111133);
  static const Color cardBorder = Color(0x664466AA);
  
  // Accent colors
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF2D95);
  static const Color neonPurple = Color(0xFFAA44FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFCC9900);
  static const Color goldLight = Color(0xFFFFE866);
  static const Color emerald = Color(0xFF00FF88);
  static const Color redHeart = Color(0xFFFF1744);
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xAAFFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);

  // === GRADIENTS ===
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A2E), Color(0xFF050510), Color(0xFF1A0A2E)],
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2D95), Color(0xFFAA22CC), Color(0xFFFF2D95)],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE866), Color(0xFFFFD700), Color(0xFFCC9900)],
  );

  static const LinearGradient blueButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2288FF), Color(0xFF1166DD), Color(0xFF0044AA)],
  );

  static const LinearGradient premiumBadgeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD700), Color(0xFFCC7700)],
  );

  // === TEXT STYLES ===
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 2,
    shadows: [
      Shadow(color: neonCyan, blurRadius: 20),
      Shadow(color: neonCyan, blurRadius: 40),
    ],
  );

  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // === DECORATIONS ===
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: cardBorder, width: 1),
    boxShadow: [
      BoxShadow(color: neonCyan.withOpacity(0.05), blurRadius: 10),
    ],
  );

  static BoxDecoration glowCardDecoration(Color glowColor) => BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: glowColor.withOpacity(0.5), width: 1.5),
    boxShadow: [
      BoxShadow(color: glowColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 1),
    ],
  );
}
