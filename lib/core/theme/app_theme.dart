import 'package:flutter/material.dart';

enum AppThemeType { defaultTheme, pastel, premium }

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    Color primaryColor;

    // Hex codes pulled directly from your App Design Document
    switch (type) {
      case AppThemeType.pastel:
        primaryColor = const Color(0xFF7D87FF);
        break;
      case AppThemeType.premium:
        primaryColor = const Color(0xFF6A5CFF);
        break;
      case AppThemeType.defaultTheme:
      default:
        primaryColor = const Color(0xFF3772FF);
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      // Automatically tint floating buttons and elevated buttons globally
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}