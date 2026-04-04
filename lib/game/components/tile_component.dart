import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/level_data.dart';

/// Visual representation of a single grid tile.
class TileComponent extends PositionComponent {
  final CellType cellType;
  final bool isTarget;

  TileComponent({
    required this.cellType,
    required Vector2 position,
    this.isTarget = false,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
        );

  @override
  void render(Canvas canvas) {
    final s = size.x; // tile is always square
    final paint = Paint();
    const gap = 1.5;

    switch (cellType) {
      case CellType.wall:
        // Mortar / gap color
        paint.color = const Color(0xFF5A4436);
        canvas.drawRect(Rect.fromLTWH(0, 0, s, s), paint);
        // Brick face
        paint.color = CatCafeTheme.wall;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(gap, gap, s - gap * 2, s - gap * 2),
            const Radius.circular(2),
          ),
          paint,
        );
        // Horizontal mortar
        paint.color = const Color(0xFF5A4436);
        canvas.drawRect(Rect.fromLTWH(0, s / 2 - 0.75, s, 1.5), paint);
        // Vertical mortar (staggered brick pattern)
        canvas.drawRect(
            Rect.fromLTWH(s / 2 - 0.75, 0, 1.5, s / 2), paint);
        canvas.drawRect(
            Rect.fromLTWH(s * 0.25 - 0.75, s / 2, 1.5, s / 2), paint);
        canvas.drawRect(
            Rect.fromLTWH(s * 0.75 - 0.75, s / 2, 1.5, s / 2), paint);

      case CellType.floor:
        // Grid gap color
        paint.color = const Color(0xFFDDD0C0);
        canvas.drawRect(Rect.fromLTWH(0, 0, s, s), paint);
        // Square floor tile
        paint.color = const Color(0xFFF8EDDF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(gap, gap, s - gap * 2, s - gap * 2),
            const Radius.circular(2),
          ),
          paint,
        );

      case CellType.target:
        // Grid gap color
        paint.color = const Color(0xFFDDD0C0);
        canvas.drawRect(Rect.fromLTWH(0, 0, s, s), paint);
        // Square floor tile
        paint.color = const Color(0xFFF8EDDF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(gap, gap, s - gap * 2, s - gap * 2),
            const Radius.circular(2),
          ),
          paint,
        );
        // Cushion fill
        paint.color = CatCafeTheme.cushion.withValues(alpha: 0.3);
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.33, paint);
        // Cushion ring
        paint.style = PaintingStyle.stroke;
        paint.color = CatCafeTheme.cushion.withValues(alpha: 0.7);
        paint.strokeWidth = 2.5;
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.33, paint);
        // Center dot
        paint.style = PaintingStyle.fill;
        paint.color = CatCafeTheme.cushion.withValues(alpha: 0.5);
        canvas.drawCircle(Offset(s / 2, s / 2), 3, paint);
    }
  }
}
