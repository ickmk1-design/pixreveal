import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined cyberpunk theme — restrained palette, clear hierarchy.
class Cyber {
  // Backgrounds — neutral dark, NOT purple
  static const bgPrimary = Color(0xFF0A0A14);    // near-black with subtle blue tint
  static const bgSecondary = Color(0xFF12121F);  // slightly lighter for cards
  static const bgTertiary = Color(0xFF1A1A2E);   // hover/elevated state

  // Accents — only TWO main colors
  static const accentPink = Color(0xFFFF10F0);   // primary action
  static const accentCyan = Color(0xFF00F0FF);   // secondary / informational

  // Premium / warning
  static const gold = Color(0xFFFFD700);

  // Decoration colors (used sparingly)
  static const sunOrange = Color(0xFFFF6B35);
  static const sunPink = Color(0xFFFF006E);
  static const purple = Color(0xFF9D00FF);

  // Text — only 3 levels
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);  // 70% white
  static const textMuted = Color(0x66FFFFFF);      // 40% white

  // Borders / dividers
  static const borderSubtle = Color(0x1AFFFFFF);   // 10% white
  static const borderStrong = Color(0x33FFFFFF);   // 20% white

  // Decorative gradient — only for hero elements
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, purple, accentCyan],
  );

  // Sun gradient — only for synthwave hero
  static const sunGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sunOrange, sunPink, accentPink],
  );

  // === TYPOGRAPHY ===

  /// Display font — Orbitron, ONLY for large headings (logo, screen titles)
  static TextStyle display({
    double size = 42,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w900,
  }) => GoogleFonts.orbitron(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: 2,
        height: 1.0,
        shadows: [
          Shadow(color: color, blurRadius: 12),
          Shadow(color: color.withValues(alpha: 0.5), blurRadius: 24),
        ],
      );

  /// Title — for medium screen titles (e.g. section headers)
  static TextStyle title({
    double size = 18,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w700,
  }) => GoogleFonts.orbitron(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: 1.5,
      );

  /// Body — Rajdhani, for all readable text
  static TextStyle body({
    double size = 14,
    Color color = textSecondary,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.rajdhani(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: 0.3,
      );

  /// Label — for buttons, badges (Rajdhani bold uppercase)
  static TextStyle label({
    double size = 13,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w700,
  }) => GoogleFonts.rajdhani(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: 1.5,
      );

  /// Pixel — for arcade scores, level numbers ONLY
  static TextStyle pixel({
    double size = 12,
    Color color = textPrimary,
  }) => GoogleFonts.pressStart2p(
        fontSize: size,
        color: color,
      );
}
