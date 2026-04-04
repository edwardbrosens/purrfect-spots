import 'package:flutter/material.dart';

/// Cat Café pastel color palette and theme.
class CatCafeTheme {
  CatCafeTheme._();

  // Primary palette
  static const Color primary = Color(0xFFE8A87C); // warm peach
  static const Color secondary = Color(0xFF85CDCA); // soft teal
  static const Color accent = Color(0xFFD4A5A5); // dusty rose
  static const Color background = Color(0xFFFFF8F0); // cream
  static const Color surface = Color(0xFFFFF1E6); // lighter cream
  static const Color darkText = Color(0xFF4A3728); // coffee brown
  static const Color lightText = Color(0xFFF5E6D3); // latte
  static const Color star = Color(0xFFFFD700); // gold
  static const Color starEmpty = Color(0xFFD4C5B2); // faded gold

  // Game-specific colors
  static const Color wall = Color(0xFF8B7355); // wood brown
  static const Color floor = Color(0xFFF5E6D3); // light wood
  static const Color cushion = Color(0xFFE8A87C); // peach (target)
  static const Color cushionOccupied = Color(0xFF85CDCA); // teal (done)
  static const Color player = Color(0xFF4A90D9); // blue apron
  static const Color cat = Color(0xFFFF9F68); // orange tabby

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: darkText,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: darkText,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}
