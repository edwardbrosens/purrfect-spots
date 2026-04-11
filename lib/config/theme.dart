import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cat Café pastel color palette and theme.
class CatCafeTheme {
  CatCafeTheme._();

  // Primary palette
  static const Color primary = Color(0xFFE8A87C); // warm peach
  static const Color secondary = Color(0xFF85CDCA); // soft teal
  static const Color accent = Color(0xFFD4A5A5); // dusty rose
  static const Color background = Color(0xFFF5EDE3); // warm cream
  static const Color surface = Color(0xFFFFF1E6); // lighter cream
  static const Color darkText = Color(0xFF4A3728); // coffee brown
  static const Color lightText = Color(0xFFF5E6D3); // latte
  static const Color star = Color(0xFFFFD700); // gold
  static const Color starEmpty = Color(0xFFD4C5B2); // faded gold

  // Game-specific colors
  static const Color wall = Color(0xFF8B7355); // wood brown
  static const Color wallDark = Color(0xFF6B5340); // darker wood
  static const Color wallLight = Color(0xFFA0896E); // highlight wood
  static const Color floor = Color(0xFFF5E6D3); // light wood
  static const Color floorDark = Color(0xFFE8D5BE); // floor shadow
  static const Color floorAccent = Color(0xFFFDF3E7); // floor highlight
  static const Color cushion = Color(0xFFE8A87C); // peach (target)
  static const Color cushionDeep = Color(0xFFD4926A); // cushion shadow
  static const Color cushionLight = Color(0xFFF5C9A8); // cushion highlight
  static const Color cushionOccupied = Color(0xFF85CDCA); // teal (done)
  static const Color player = Color(0xFF4A90D9); // blue apron
  static const Color playerDark = Color(0xFF3A72B0); // apron shadow
  static const Color playerLight = Color(0xFF6BABEE); // apron highlight
  static const Color cat = Color(0xFFFF9F68); // orange tabby

  // Ambient / effects
  static const Color warmGlow = Color(0xFFFFF4E0);
  static const Color shadowColor = Color(0x30000000);
  static const Color deepShadow = Color(0x50000000);

  /// Display/title font (Chewy from Google Fonts).
  static TextStyle display({double fontSize = 32, Color? color}) =>
      GoogleFonts.chewy(
        fontSize: fontSize,
        color: color ?? darkText,
        letterSpacing: 0.5,
      );

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
        textTheme: TextTheme(
          displayLarge: GoogleFonts.chewy(color: darkText),
          displayMedium: GoogleFonts.chewy(color: darkText),
          displaySmall: GoogleFonts.chewy(color: darkText),
          headlineLarge: GoogleFonts.chewy(color: darkText),
          headlineMedium: GoogleFonts.chewy(color: darkText),
          headlineSmall: GoogleFonts.chewy(color: darkText),
          titleLarge: GoogleFonts.chewy(color: darkText),
          titleMedium: GoogleFonts.chewy(color: darkText),
          titleSmall: GoogleFonts.chewy(color: darkText),
          bodyLarge: GoogleFonts.nunito(color: darkText),
          bodyMedium: GoogleFonts.nunito(color: darkText),
          bodySmall: GoogleFonts.nunito(color: darkText),
          labelLarge: GoogleFonts.chewy(color: darkText),
          labelMedium: GoogleFonts.chewy(color: darkText),
          labelSmall: GoogleFonts.chewy(color: darkText),
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
