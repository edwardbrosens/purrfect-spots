import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/level_themes.dart';
import '../config/theme.dart';

/// Full-screen celebration overlay shown after clearing the final level of
/// a category (floor % 10 == 0). A happy cat curls up on a themed cushion
/// and winks at the player.
class CategoryCompleteOverlay extends StatefulWidget {
  final LevelTheme theme;
  final int floor;
  final VoidCallback onDismiss;

  const CategoryCompleteOverlay({
    super.key,
    required this.theme,
    required this.floor,
    required this.onDismiss,
  });

  @override
  State<CategoryCompleteOverlay> createState() =>
      _CategoryCompleteOverlayState();
}

class _CategoryCompleteOverlayState extends State<CategoryCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _wink;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _wink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    // Start winking after intro settles, then loop slowly.
    Future.delayed(const Duration(milliseconds: 1100), () async {
      while (mounted) {
        await _wink.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 1600));
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _wink.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.theme.palette;
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _wink, _float]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_intro.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Themed background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color.lerp(palette.floorLight, Colors.white, 0.15)!,
                      palette.floorBase,
                      palette.floorDark,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Sparkle layer
              CustomPaint(
                painter: _SparklePainter(
                  progress: _float.value,
                  color: Colors.white.withValues(alpha: 0.85),
                  accent: widget.theme.color,
                ),
              ),

              // Cat on cushion — scales and rises in
              Center(
                child: Transform.translate(
                  offset: Offset(
                      0, 24 * (1 - t) + math.sin(_float.value * math.pi * 2) * 4),
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * t,
                    child: SizedBox(
                      width: 260,
                      height: 220,
                      child: CustomPaint(
                        painter: _CatOnCushionPainter(
                          themeColor: widget.theme.color,
                          cushionColor: CatCafeTheme.cushion,
                          cushionDeep: CatCafeTheme.cushionDeep,
                          cushionLight: CatCafeTheme.cushionLight,
                          winkProgress: _winkEase(_wink.value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title + subtitle + button
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: t,
                  child: Column(
                    children: [
                      Icon(widget.theme.icon,
                          size: 48, color: CatCafeTheme.darkText),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.theme.name} Complete!',
                        textAlign: TextAlign.center,
                        style: CatCafeTheme.display(fontSize: 36),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Every cushion claimed · Floor ${widget.floor}',
                        style: TextStyle(
                          fontSize: 15,
                          color: CatCafeTheme.darkText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: t,
                    child: ElevatedButton.icon(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.color,
                        foregroundColor: CatCafeTheme.darkText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _winkEase(double v) {
    // 0..1 -> close then open (triangle smoothed)
    final x = (v < 0.5) ? v * 2 : (1 - v) * 2;
    return Curves.easeInOut.transform(x.clamp(0.0, 1.0));
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accent;
  _SparklePainter({required this.progress, required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final phase = (progress + rng.nextDouble()) % 1.0;
      final a = (math.sin(phase * math.pi * 2) * 0.5 + 0.5);
      final r = 1.5 + rng.nextDouble() * 2.2;
      final c = (i % 5 == 0 ? accent : color).withValues(alpha: a * 0.9);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = c);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) =>
      old.progress != progress;
}

class _CatOnCushionPainter extends CustomPainter {
  final Color themeColor;
  final Color cushionColor;
  final Color cushionDeep;
  final Color cushionLight;
  final double winkProgress; // 0 open, 1 fully closed

  _CatOnCushionPainter({
    required this.themeColor,
    required this.cushionColor,
    required this.cushionDeep,
    required this.cushionLight,
    required this.winkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;

    // ── Cushion (big, plush) ──
    final cushW = size.width * 0.82;
    final cushH = size.height * 0.34;
    final cushRect =
        Rect.fromCenter(center: Offset(cx, cy + 12), width: cushW, height: cushH);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(cushRect.shift(const Offset(0, 10)),
          Radius.circular(cushH * 0.45)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final outline =
        Color.lerp(cushionDeep, Colors.black, 0.45)!;
    final cushRR =
        RRect.fromRectAndRadius(cushRect, Radius.circular(cushH * 0.45));
    canvas.drawRRect(
      cushRR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(cushionLight, Colors.white, 0.4)!,
            cushionColor,
            cushionDeep,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(cushRect),
    );
    canvas.drawRRect(
      cushRR,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Cat body (curled up, oval blob)
    final catColor = themeColor;
    final catDark = Color.lerp(catColor, Colors.black, 0.3)!;
    final catLight = Color.lerp(catColor, Colors.white, 0.35)!;

    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy - 10),
      width: cushW * 0.62,
      height: cushH * 1.15,
    );
    final bodyPath = Path()..addOval(bodyRect);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [catLight, catColor, catDark],
        ).createShader(bodyRect),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Tail curling along the side
    final tail = Path()
      ..moveTo(cx + bodyRect.width * 0.45, cy - 4)
      ..cubicTo(
        cx + bodyRect.width * 0.75, cy - 10,
        cx + bodyRect.width * 0.70, cy + 20,
        cx + bodyRect.width * 0.35, cy + 18,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = catColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tail,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Head (slightly above body)
    final headCenter = Offset(cx - 4, cy - bodyRect.height * 0.35);
    final headR = bodyRect.width * 0.33;
    final headRect =
        Rect.fromCenter(center: headCenter, width: headR * 2, height: headR * 1.9);
    canvas.drawOval(
      headRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [catLight, catColor],
        ).createShader(headRect),
    );
    canvas.drawOval(
      headRect,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Ears (two triangles)
    void ear(double dx) {
      final base = Offset(headCenter.dx + dx, headCenter.dy - headR * 0.75);
      final p = Path()
        ..moveTo(base.dx - 10, base.dy + 4)
        ..lineTo(base.dx + 10, base.dy + 4)
        ..lineTo(base.dx + dx.sign * 3, base.dy - 18)
        ..close();
      canvas.drawPath(p, Paint()..color = catColor);
      canvas.drawPath(
        p,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      // Inner ear
      final inner = Path()
        ..moveTo(base.dx - 5, base.dy + 2)
        ..lineTo(base.dx + 5, base.dy + 2)
        ..lineTo(base.dx + dx.sign * 2, base.dy - 10)
        ..close();
      canvas.drawPath(
        inner,
        Paint()..color = const Color(0xFFFFB4C4).withValues(alpha: 0.9),
      );
    }

    ear(-headR * 0.55);
    ear(headR * 0.55);

    // Eyes — left eye winks
    final leftEye = Offset(headCenter.dx - headR * 0.38, headCenter.dy + 2);
    final rightEye = Offset(headCenter.dx + headR * 0.38, headCenter.dy + 2);
    final eyeOpen = 1 - winkProgress; // 1 open, 0 closed

    // Right eye — always open, happy arch
    canvas.drawArc(
      Rect.fromCenter(center: rightEye, width: 14, height: 12),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Left eye — wink
    if (eyeOpen > 0.15) {
      canvas.drawArc(
        Rect.fromCenter(center: leftEye, width: 14, height: 12 * eyeOpen),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // closed line
      canvas.drawLine(
        Offset(leftEye.dx - 7, leftEye.dy),
        Offset(leftEye.dx + 7, leftEye.dy),
        Paint()
          ..color = outline
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Nose
    final nose = Path()
      ..moveTo(headCenter.dx - 3, headCenter.dy + 8)
      ..lineTo(headCenter.dx + 3, headCenter.dy + 8)
      ..lineTo(headCenter.dx, headCenter.dy + 12)
      ..close();
    canvas.drawPath(
      nose,
      Paint()..color = const Color(0xFFE48AA0),
    );
    canvas.drawPath(
      nose,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Happy mouth (smile)
    final mouth = Path()
      ..moveTo(headCenter.dx - 5, headCenter.dy + 13)
      ..quadraticBezierTo(headCenter.dx, headCenter.dy + 18,
          headCenter.dx + 5, headCenter.dy + 13);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Blush cheeks
    canvas.drawCircle(
      Offset(headCenter.dx - headR * 0.55, headCenter.dy + 10),
      4,
      Paint()..color = const Color(0xFFFFB4C4).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(headCenter.dx + headR * 0.55, headCenter.dy + 10),
      4,
      Paint()..color = const Color(0xFFFFB4C4).withValues(alpha: 0.7),
    );

    // Whiskers
    final whiskerPaint = Paint()
      ..color = outline.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(headCenter.dx - headR * 0.3, headCenter.dy + 10 + i * 3),
        Offset(headCenter.dx - headR * 0.85, headCenter.dy + 10 + i * 5),
        whiskerPaint,
      );
      canvas.drawLine(
        Offset(headCenter.dx + headR * 0.3, headCenter.dy + 10 + i * 3),
        Offset(headCenter.dx + headR * 0.85, headCenter.dy + 10 + i * 5),
        whiskerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CatOnCushionPainter old) =>
      old.winkProgress != winkProgress;
}
