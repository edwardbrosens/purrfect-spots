import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/level_themes.dart';
import '../../config/theme.dart';
import '../../models/level_data.dart';

/// Visual representation of a single grid tile — warm cosy café style.
class TileComponent extends PositionComponent {
  final CellType cellType;
  final bool isTarget;
  final int row;
  final int col;
  final TilePalette palette;

  // Cushion idle animation
  double _time = 0;

  // Whether a cat is currently resting on this cushion (animates a dent).
  bool hasCat = false;
  double _dent = 0; // 0..1 eased

  // Per-tile randomness (deterministic)
  late final double _r1; // 0..1
  late final double _r2;
  late final double _r3;
  late final int _decoration; // 0=none, 1=paw, 2=heart, 3=fish, 4=star, 5=swirl
  late final int _knot; // 0=none, 1=knot somewhere
  late final double _planksOffset;

  TileComponent({
    required this.cellType,
    required Vector2 position,
    required this.palette,
    this.isTarget = false,
    this.row = 0,
    this.col = 0,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
        ) {
    final rng = Random(row * 9173 + col * 31 + 7);
    _r1 = rng.nextDouble();
    _r2 = rng.nextDouble();
    _r3 = rng.nextDouble();
    // ~12% chance of a decoration on a floor tile
    _decoration = rng.nextInt(100) < 12 ? rng.nextInt(5) + 1 : 0;
    _knot = rng.nextInt(100) < 18 ? 1 : 0;
    _planksOffset = rng.nextDouble() * 4;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isTarget) {
      _time += dt;
      final target = hasCat ? 1.0 : 0.0;
      _dent += (target - _dent) * (dt * 8).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    final s = size.x;

    switch (cellType) {
      case CellType.wall:
        _renderWall(canvas, s);
      case CellType.floor:
        _renderFloor(canvas, s);
      case CellType.target:
        _renderFloor(canvas, s);
        _renderCushion(canvas, s);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // WALL — warm wood paneling with vertical planks
  // ─────────────────────────────────────────────────────────────
  void _renderWall(Canvas canvas, double s) {
    final rect = Rect.fromLTWH(0, 0, s, s);

    // Base warm wood (themed)
    final baseColor = Color.lerp(palette.wallBase, palette.wallDark, _r1 * 0.4)!;

    // Vertical gradient — top lighter, bottom darker (light from above)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseColor, palette.wallLight, 0.55)!,
            baseColor,
            Color.lerp(baseColor, palette.wallSeam, 0.4)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // Vertical plank seams (2 planks per tile)
    final seamPaint = Paint()
      ..color = palette.wallSeam.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(s / 2, 0), Offset(s / 2, s), seamPaint);
    // Soft seam highlight
    canvas.drawLine(
      Offset(s / 2 + 1, 0),
      Offset(s / 2 + 1, s),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 0.6,
    );

    // Wood grain — long curving lines
    final grainPaint = Paint()
      ..color = palette.wallSeam.withValues(alpha: 0.22)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int p = 0; p < 2; p++) {
      final px = s * 0.25 + p * s * 0.5;
      for (int i = 0; i < 3; i++) {
        final xOff = (i - 1) * 4.0 + _planksOffset * (p == 0 ? 1 : -1);
        final path = Path();
        path.moveTo(px + xOff, -2);
        path.cubicTo(
          px + xOff + sin(_r1 * pi + i) * 2, s * 0.33,
          px + xOff - sin(_r2 * pi + i) * 2, s * 0.66,
          px + xOff + sin(_r3 * pi + i * 2) * 1.5, s + 2,
        );
        canvas.drawPath(path, grainPaint);
      }
    }

    // Knot in the wood
    if (_knot == 1) {
      final kx = s * (0.25 + _r1 * 0.5);
      final ky = s * (0.2 + _r2 * 0.6);
      final kr = 2.5 + _r3 * 1.5;
      canvas.drawCircle(
        Offset(kx, ky),
        kr,
        Paint()..color = palette.wallSeam.withValues(alpha: 0.55),
      );
      canvas.drawCircle(
        Offset(kx, ky),
        kr,
        Paint()
          ..color = palette.wallSeam.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      // Knot rings
      canvas.drawCircle(
        Offset(kx, ky),
        kr + 1.5,
        Paint()
          ..color = palette.wallSeam.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // Top edge highlight (warm light from above)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, 3),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, s, 3)),
    );

    // Bottom edge shadow
    canvas.drawRect(
      Rect.fromLTWH(0, s - 3, s, 3),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.25),
          ],
        ).createShader(Rect.fromLTWH(0, s - 3, s, 3)),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FLOOR — continuous warm wood planks (no visible grid)
  // ─────────────────────────────────────────────────────────────
  void _renderFloor(Canvas canvas, double s) {
    final rect = Rect.fromLTWH(0, 0, s, s);

    // Themed floor base
    final baseColor = Color.lerp(palette.floorLight, palette.floorBase, _r1 * 0.7 + 0.3)!;
    final darkerEdge = Color.lerp(baseColor, palette.floorDark, 0.7)!;

    // Soft radial light from upper-left for cosy feel
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 1.4,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.15)!,
            baseColor,
            darkerEdge,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // Long horizontal wood plank shading — every 2 rows is a "plank"
    // Use row parity to create a continuous plank look across tiles
    final isPlankSeam = row % 2 == 0;
    if (isPlankSeam) {
      // Subtle plank seam at top of tile
      canvas.drawRect(
        Rect.fromLTWH(0, 0, s, 1.5),
        Paint()..color = palette.grain.withValues(alpha: 0.35),
      );
      // Highlight just below
      canvas.drawRect(
        Rect.fromLTWH(0, 1.5, s, 0.8),
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }

    // Wood grain — flowing lines that don't reset per tile
    final grainPaint = Paint()
      ..color = palette.grain.withValues(alpha: 0.22)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    final grainCount = 4;
    for (int i = 0; i < grainCount; i++) {
      final yPos = (i * s / grainCount) + _planksOffset + 4;
      if (yPos > 0 && yPos < s) {
        final path = Path();
        path.moveTo(-2, yPos);
        path.cubicTo(
          s * 0.33, yPos + sin(_r1 * pi * 2 + i) * 1.5,
          s * 0.66, yPos + cos(_r2 * pi * 2 + i) * 1.5,
          s + 2, yPos + sin(_r3 * pi + i * 0.7) * 1.2,
        );
        canvas.drawPath(path, grainPaint);
      }
    }

    // Subtle warm specks (dust motes / texture)
    final speckPaint = Paint()..color = palette.grain.withValues(alpha: 0.3);
    for (int i = 0; i < 4; i++) {
      final sx = (_r1 * 7 + i * 13) % 1.0 * s;
      final sy = (_r2 * 11 + i * 17) % 1.0 * s;
      canvas.drawCircle(Offset(sx, sy), 0.7, speckPaint);
    }

    // Decoration (only on regular floor, not target)
    if (!isTarget && _decoration > 0) {
      _drawDecoration(canvas, s);
    }
  }

  void _drawDecoration(Canvas canvas, double s) {
    final dx = s * (0.2 + _r1 * 0.6);
    final dy = s * (0.2 + _r2 * 0.6);
    final color = palette.decor.withValues(alpha: 0.22);
    final paint = Paint()..color = color;

    switch (_decoration) {
      case 1: // Paw print
        // Main pad
        canvas.drawOval(
          Rect.fromCenter(center: Offset(dx, dy + 2), width: 5, height: 4),
          paint,
        );
        // Toes
        canvas.drawCircle(Offset(dx - 2.2, dy - 1.5), 1.0, paint);
        canvas.drawCircle(Offset(dx, dy - 2.5), 1.0, paint);
        canvas.drawCircle(Offset(dx + 2.2, dy - 1.5), 1.0, paint);
      case 2: // Heart
        canvas.drawCircle(Offset(dx - 1.5, dy - 0.5), 1.6, paint);
        canvas.drawCircle(Offset(dx + 1.5, dy - 0.5), 1.6, paint);
        final p = Path();
        p.moveTo(dx - 3, dy);
        p.lineTo(dx + 3, dy);
        p.lineTo(dx, dy + 3);
        p.close();
        canvas.drawPath(p, paint);
      case 3: // Fish bone
        canvas.drawCircle(Offset(dx - 3, dy), 1.2, paint);
        canvas.drawLine(
          Offset(dx - 2, dy),
          Offset(dx + 3, dy),
          Paint()
            ..color = color
            ..strokeWidth = 0.8
            ..strokeCap = StrokeCap.round,
        );
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(dx - 1 + i * 1.5, dy - 1.5),
            Offset(dx - 1 + i * 1.5, dy + 1.5),
            Paint()
              ..color = color
              ..strokeWidth = 0.6,
          );
        }
      case 4: // Star
        final starPaint = Paint()
          ..color = color
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(dx, dy - 3), Offset(dx, dy + 3), starPaint);
        canvas.drawLine(Offset(dx - 3, dy), Offset(dx + 3, dy), starPaint);
        canvas.drawLine(Offset(dx - 2, dy - 2), Offset(dx + 2, dy + 2), starPaint);
        canvas.drawLine(Offset(dx + 2, dy - 2), Offset(dx - 2, dy + 2), starPaint);
      case 5: // Swirl
        final swirlPath = Path();
        for (int i = 0; i < 20; i++) {
          final t = i / 20.0;
          final ang = t * pi * 2.5;
          final r = t * 3;
          final x = dx + cos(ang) * r;
          final y = dy + sin(ang) * r;
          if (i == 0) {
            swirlPath.moveTo(x, y);
          } else {
            swirlPath.lineTo(x, y);
          }
        }
        canvas.drawPath(
          swirlPath,
          Paint()
            ..color = color
            ..strokeWidth = 0.7
            ..style = PaintingStyle.stroke,
        );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CUSHION (target marker)
  // ─────────────────────────────────────────────────────────────
  void _renderCushion(Canvas canvas, double s) {
    final cx = s / 2;
    final cy = s / 2 + 1;
    final halfW = s * 0.40;           // pillow half-width
    final halfH = s * 0.30;           // pillow half-height (squarish-rect)
    final breathe = sin(_time * 2.0) * 0.4;

    // Soft outer glow
    canvas.drawCircle(
      Offset(cx, cy),
      halfW + 7 + breathe,
      Paint()
        ..color = const Color(0xFFFFE0B0).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Drop shadow under pillow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + 3),
          width: halfW * 2 + 3,
          height: halfH * 2 + 3,
        ),
        Radius.circular(halfH * 0.9),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    // ── Cartoon pillow: 4 puffy lobes, dark outline, stitching, tassels ──
    final w = halfW * 2 + breathe;
    final h = halfH * 2 + breathe;
    final left = cx - w / 2;
    final right = cx + w / 2;
    final top = cy - h / 2;
    final bot = cy + h / 2;

    // Outline color (deep navy-ish)
    final outlineColor = Color.lerp(CatCafeTheme.cushionDeep, Colors.black, 0.45)!;

    // Pillow silhouette: rounded corners with sides bulging slightly outward.
    // When a cat sits on it, the top sags inward and the sides bulge more.
    final cornerR = h * 0.22;
    final dent = _dent;
    final topSag = h * 0.22 * dent;          // how much the top dips down
    final bulge = h * (0.06 + 0.10 * dent);  // sides squish outward more
    final tlc = Offset(left + cornerR, top + cornerR);
    final trc = Offset(right - cornerR, top + cornerR);

    final pillow = Path()
      ..moveTo(tlc.dx, top)
      // top edge sags down between corners when dented
      ..quadraticBezierTo(cx, top + topSag, trc.dx, top)
      // top-right corner
      ..quadraticBezierTo(right, top, right, trc.dy)
      // right side bulging out
      ..quadraticBezierTo(right + bulge, cy, right, bot - cornerR)
      // bottom-right corner
      ..quadraticBezierTo(right, bot, right - cornerR, bot)
      ..lineTo(left + cornerR, bot)
      // bottom-left corner
      ..quadraticBezierTo(left, bot, left, bot - cornerR)
      // left side bulging out
      ..quadraticBezierTo(left - bulge, cy, left, tlc.dy)
      // top-left corner
      ..quadraticBezierTo(left, top, tlc.dx, top)
      ..close();

    // Tassels at the 4 corners (drawn first so pillow sits on top)
    final tasselColor = Color.lerp(CatCafeTheme.cushionLight, Colors.white, 0.4)!;
    final tasselDark = outlineColor;
    void tassel(Offset tip, double dx, double dy) {
      final base = Offset(tip.dx + dx * 2.5, tip.dy + dy * 2.5);
      // String
      canvas.drawLine(
        tip,
        base,
        Paint()
          ..color = tasselDark
          ..strokeWidth = 0.9,
      );
      // Tuft (small triangle/blob)
      final t = Path()
        ..moveTo(base.dx - 1.8, base.dy)
        ..lineTo(base.dx + 1.8, base.dy)
        ..lineTo(base.dx + dx * 2.2, base.dy + dy * 2.2)
        ..close();
      canvas.drawPath(t, Paint()..color = tasselColor);
      canvas.drawPath(
        t,
        Paint()
          ..color = tasselDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }
    tassel(Offset(left, top), -1, -1);
    tassel(Offset(right, top), 1, -1);
    tassel(Offset(left, bot), -1, 1);
    tassel(Offset(right, bot), 1, 1);

    // Base fill — soft top-light gradient
    canvas.drawPath(
      pillow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(CatCafeTheme.cushionLight, Colors.white, 0.45)!,
            CatCafeTheme.cushion,
            CatCafeTheme.cushionDeep,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromLTRB(left, top, right, bot)),
    );

    // Center dimple shading — a soft dark blob to suggest the tuft pinch
    canvas.save();
    canvas.clipPath(pillow);
    canvas.drawCircle(
      Offset(cx, cy + h * 0.05),
      h * (0.18 + 0.10 * dent),
      Paint()
        ..color = CatCafeTheme.cushionDeep.withValues(alpha: 0.45 + 0.30 * dent)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 2 * dent),
    );

    // Cat-shaped dent shadow across the top of the pillow
    if (dent > 0.05) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, top + topSag * 0.6 + 1),
          width: w * 0.78,
          height: h * 0.30 * dent,
        ),
        Paint()
          ..color = CatCafeTheme.cushionDeep.withValues(alpha: 0.45 * dent)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
      );
    }

    // Lobe highlights — 4 soft white blobs around the dimple
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(Offset(cx - w * 0.22, cy - h * 0.22), h * 0.13, hlPaint);
    canvas.drawCircle(Offset(cx + w * 0.22, cy - h * 0.22), h * 0.11, hlPaint);
    canvas.drawCircle(Offset(cx - w * 0.22, cy + h * 0.20), h * 0.10, hlPaint);
    canvas.drawCircle(Offset(cx + w * 0.22, cy + h * 0.20), h * 0.10, hlPaint);

    // Crease lines from center toward each corner (the X tuft)
    final crease = Paint()
      ..color = CatCafeTheme.cushionDeep.withValues(alpha: 0.7)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void creaseTo(double tx, double ty) {
      final p = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(
          (cx + tx) / 2 + (tx - cx) * 0.05,
          (cy + ty) / 2 + (ty - cy) * 0.05,
          tx,
          ty,
        );
      canvas.drawPath(p, crease);
    }
    creaseTo(cx - w * 0.32, cy - h * 0.32);
    creaseTo(cx + w * 0.32, cy - h * 0.32);
    creaseTo(cx - w * 0.32, cy + h * 0.32);
    creaseTo(cx + w * 0.32, cy + h * 0.32);
    canvas.restore();

    // Dashed stitched seam just inside the outline (rebuild shape, inset)
    const inset = 2.6;
    final l2 = left + inset, r2 = right - inset, t2 = top + inset, b2 = bot - inset;
    final cR2 = cornerR - inset * 0.5;
    final tlc2x = l2 + cR2, trc2x = r2 - cR2;
    final tlc2y = t2 + cR2, brc2y = b2 - cR2;
    final seamPath = Path()
      ..moveTo(tlc2x, t2)
      ..quadraticBezierTo(cx, t2 + topSag, trc2x, t2)
      ..quadraticBezierTo(r2, t2, r2, tlc2y)
      ..quadraticBezierTo(r2 + bulge * 0.6, cy, r2, brc2y)
      ..quadraticBezierTo(r2, b2, trc2x, b2)
      ..lineTo(tlc2x, b2)
      ..quadraticBezierTo(l2, b2, l2, brc2y)
      ..quadraticBezierTo(l2 - bulge * 0.6, cy, l2, tlc2y)
      ..quadraticBezierTo(l2, t2, tlc2x, t2)
      ..close();
    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    for (final metric in seamPath.computeMetrics()) {
      double d = 0;
      const dash = 2.4, gap = 2.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, (d + dash).clamp(0, metric.length)),
          seamPaint,
        );
        d += dash + gap;
      }
    }

    // Bold dark outline
    canvas.drawPath(
      pillow,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Pulsing glow
    final pulseAlpha = (0.16 + sin(_time * 3) * 0.1).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(cx, cy),
      halfW + 5 + breathe,
      Paint()
        ..color = CatCafeTheme.cushion.withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}
