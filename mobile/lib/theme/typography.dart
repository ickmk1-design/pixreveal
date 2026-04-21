import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle heading({
    double size = 24,
    Color? color,
    double letterSpacing = 2,
  }) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
      );

  static TextStyle body({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? Colors.white,
      );

  static TextStyle button({double size = 16, Color? color}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? Colors.white,
      );
}
