import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkArcade => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        primaryColor: AppColors.neonPink,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonPink,
          secondary: AppColors.neonBlue,
          surface: AppColors.darkCard,
          error: AppColors.red,
        ),
        fontFamily: 'PressStart2P',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.neonBlue,
          ),
          bodyLarge: TextStyle(
            fontSize: 12,
            color: AppColors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 10,
            color: AppColors.white,
          ),
          labelLarge: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.arcadePurple,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.neonPink, width: 2),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      );
}
