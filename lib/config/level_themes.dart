import 'package:flutter/material.dart';

/// Per-theme tile palette used by the tile renderer.
class TilePalette {
  final Color wallLight;
  final Color wallBase;
  final Color wallDark;
  final Color wallSeam;
  final Color floorLight;
  final Color floorBase;
  final Color floorDark;
  final Color grain;
  final Color decor;
  const TilePalette({
    required this.wallLight,
    required this.wallBase,
    required this.wallDark,
    required this.wallSeam,
    required this.floorLight,
    required this.floorBase,
    required this.floorDark,
    required this.grain,
    required this.decor,
  });
}

/// Café-themed level categories. Every 10 floors share a theme.
class LevelTheme {
  final String name;
  final IconData icon;
  final Color color;
  final TilePalette palette;
  const LevelTheme(this.name, this.icon, this.color, this.palette);
}

const List<LevelTheme> kLevelThemes = [
  // 1. Cozy Kitchen — warm wood walls, cream tile floor
  LevelTheme('Cozy Kitchen', Icons.kitchen_rounded, Color(0xFFE8A87C),
      TilePalette(
        wallLight: Color(0xFFC9885C), wallBase: Color(0xFF8B5A36), wallDark: Color(0xFF5C3A20), wallSeam: Color(0xFF3E2415),
        floorLight: Color(0xFFFFF1DC), floorBase: Color(0xFFF8DFB6), floorDark: Color(0xFFE6C49B),
        grain: Color(0xFFB88B5C), decor: Color(0xFFB07040),
      )),
  // 2. Sunny Garden — pale stone walls, mossy grass floor
  LevelTheme('Sunny Garden', Icons.local_florist_rounded, Color(0xFFF6C667),
      TilePalette(
        wallLight: Color(0xFFE8DCC0), wallBase: Color(0xFFC9B98C), wallDark: Color(0xFF8B7B52), wallSeam: Color(0xFF5C4F2C),
        floorLight: Color(0xFFC8E2A0), floorBase: Color(0xFFA8CE7C), floorDark: Color(0xFF7BA854),
        grain: Color(0xFF5C8A3C), decor: Color(0xFFE6A040),
      )),
  // 3. Library Nook — dark mahogany walls, parquet floor
  LevelTheme('Library Nook', Icons.menu_book_rounded, Color(0xFFB08968),
      TilePalette(
        wallLight: Color(0xFF7A4A28), wallBase: Color(0xFF4D2A14), wallDark: Color(0xFF2B1808), wallSeam: Color(0xFF1A0E04),
        floorLight: Color(0xFFE6C28C), floorBase: Color(0xFFC9A06A), floorDark: Color(0xFF8E6638),
        grain: Color(0xFF5C3818), decor: Color(0xFF8B5A28),
      )),
  // 4. Bakery Corner — terracotta brick walls, checkered floor
  LevelTheme('Bakery Corner', Icons.bakery_dining_rounded, Color(0xFFD9886C),
      TilePalette(
        wallLight: Color(0xFFE89878), wallBase: Color(0xFFC4664A), wallDark: Color(0xFF8A3E22), wallSeam: Color(0xFF5C2810),
        floorLight: Color(0xFFFFE6C4), floorBase: Color(0xFFF6CFA0), floorDark: Color(0xFFD9A878),
        grain: Color(0xFFA86844), decor: Color(0xFFC25A30),
      )),
  // 5. Tea Room — lilac wallpaper walls, soft lavender floor
  LevelTheme('Tea Room', Icons.emoji_food_beverage_rounded, Color(0xFFC9A0DC),
      TilePalette(
        wallLight: Color(0xFFE8D2F0), wallBase: Color(0xFFB890CC), wallDark: Color(0xFF7C5A8E), wallSeam: Color(0xFF4E3460),
        floorLight: Color(0xFFF2E6F4), floorBase: Color(0xFFDCCAE6), floorDark: Color(0xFFB89CCC),
        grain: Color(0xFF8C6BA8), decor: Color(0xFF9968B8),
      )),
  // 6. Greenhouse — mossy stone walls, leafy emerald floor
  LevelTheme('Greenhouse', Icons.eco_rounded, Color(0xFF8BBE7A),
      TilePalette(
        wallLight: Color(0xFFB8C2A8), wallBase: Color(0xFF7D8E68), wallDark: Color(0xFF4A5A38), wallSeam: Color(0xFF2A3818),
        floorLight: Color(0xFFB8E090), floorBase: Color(0xFF82B85C), floorDark: Color(0xFF52853A),
        grain: Color(0xFF306020), decor: Color(0xFFE2A848),
      )),
  // 7. Toy Shop — bright pink panels, candy floor
  LevelTheme('Toy Shop', Icons.toys_rounded, Color(0xFFEC7B9F),
      TilePalette(
        wallLight: Color(0xFFFFC4D6), wallBase: Color(0xFFF28BAB), wallDark: Color(0xFFB04668), wallSeam: Color(0xFF782840),
        floorLight: Color(0xFFFFEAF0), floorBase: Color(0xFFFCD2DE), floorDark: Color(0xFFE8AAC0),
        grain: Color(0xFFC06888), decor: Color(0xFFD04878),
      )),
  // 8. Reading Loft — slate gray walls, dusty blue rug floor
  LevelTheme('Reading Loft', Icons.chair_rounded, Color(0xFF9BB8CD),
      TilePalette(
        wallLight: Color(0xFFB0BCC6), wallBase: Color(0xFF7C8C98), wallDark: Color(0xFF4A5660), wallSeam: Color(0xFF2A323A),
        floorLight: Color(0xFFD8E2EC), floorBase: Color(0xFFB4C6D4), floorDark: Color(0xFF8298AC),
        grain: Color(0xFF566876), decor: Color(0xFF6884A0),
      )),
  // 9. Fish Market — sea-blue tile walls, wet stone floor
  LevelTheme('Fish Market', Icons.set_meal_rounded, Color(0xFF6FB6C8),
      TilePalette(
        wallLight: Color(0xFFA8D8E4), wallBase: Color(0xFF5C9CB0), wallDark: Color(0xFF2E5C6E), wallSeam: Color(0xFF18343E),
        floorLight: Color(0xFFD2E2E8), floorBase: Color(0xFFA8C0CC), floorDark: Color(0xFF7898A8),
        grain: Color(0xFF466878), decor: Color(0xFF3A7088),
      )),
  // 10. Rooftop Terrace — sunset brick walls, warm tile floor
  LevelTheme('Rooftop Terrace', Icons.deck_rounded, Color(0xFFCC6F70),
      TilePalette(
        wallLight: Color(0xFFE89878), wallBase: Color(0xFFB45848), wallDark: Color(0xFF6E2820), wallSeam: Color(0xFF3C140C),
        floorLight: Color(0xFFFFD8B0), floorBase: Color(0xFFF0AE7C), floorDark: Color(0xFFC07848),
        grain: Color(0xFF8C4420), decor: Color(0xFFB04020),
      )),
];

/// Returns the theme for a given floor (1-based).
LevelTheme themeForFloor(int floor) {
  final idx = ((floor - 1) ~/ 10).clamp(0, kLevelThemes.length - 1);
  return kLevelThemes[idx];
}
