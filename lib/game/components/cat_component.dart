import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// A pushable cat — the "box" in our puzzle game.
/// Rich detailed rendering with standing, walking, and curl-up animations.
class CatComponent extends PositionComponent {
  final Color catColor;
  final Color catDark; // darker shade for shading
  final Color catLight; // lighter shade for highlights
  final int catIndex;
  bool isOnTarget;
  bool _isMoving = false;
  Vector2? _targetPosition;
  late Vector2 _startPosition;
  double _moveProgress = 0;

  // Idle animation
  double _idleTimer = 0;
  double _tailWag = 0;
  double _earTwitch = 0;

  // Curl-up animation
  bool _isCurlingUp = false;
  double _curlProgress = 0;
  double _curledAmount = 0;

  // Settle sparkle particles
  final List<_Sparkle> _sparkles = [];

  // Stripe pattern seed
  late final bool _hasStripes;
  late final double _stripeSeed;

  static final List<Color> catColors = [
    const Color(0xFFFF9F68), // Orange tabby
    const Color(0xFF9E9E9E), // Gray
    const Color(0xFF3D3D3D), // Black
    const Color(0xFFFFE4B5), // Cream/white
    const Color(0xFFD2691E), // Chocolate
    const Color(0xFFFFB347), // Light orange
    const Color(0xFFB0B0B0), // Silver
    const Color(0xFF8B6914), // Siamese brown
  ];

  CatComponent({
    required Vector2 position,
    required this.catIndex,
    this.isOnTarget = false,
  })  : catColor = catColors[catIndex % catColors.length],
        catDark = Color.lerp(catColors[catIndex % catColors.length], Colors.black, 0.25)!,
        catLight = Color.lerp(catColors[catIndex % catColors.length], Colors.white, 0.3)!,
        super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
          priority: 5,
        ) {
    if (isOnTarget) _curledAmount = 1.0;
    final rng = Random(catIndex * 37);
    _hasStripes = catIndex % 3 != 2; // ~2/3 of cats have stripes
    _stripeSeed = rng.nextDouble();
  }

  bool get isMoving => _isMoving;

  void moveTo(Vector2 target) {
    _startPosition = position.clone();
    _targetPosition = target;
    _moveProgress = 0;
    _isMoving = true;
  }

  void settle() {
    _isCurlingUp = true;
    _curlProgress = 0;
    // Spawn sparkles
    final rng = Random();
    _sparkles.clear();
    for (int i = 0; i < 8; i++) {
      _sparkles.add(_Sparkle(
        x: 20 + rng.nextDouble() * 24,
        y: 10 + rng.nextDouble() * 30,
        vx: (rng.nextDouble() - 0.5) * 30,
        vy: -20 - rng.nextDouble() * 25,
        life: 0.5 + rng.nextDouble() * 0.6,
        size: 2 + rng.nextDouble() * 3,
      ));
    }
  }

  void unsettle() {
    _curledAmount = 0;
    _isCurlingUp = false;
    _curlProgress = 0;
    _sparkles.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movement
    if (_isMoving && _targetPosition != null) {
      _moveProgress += dt / GameConstants.moveDuration.inMilliseconds * 1000;
      if (_moveProgress >= 1.0) {
        position.setFrom(_targetPosition!);
        _isMoving = false;
        _targetPosition = null;
      } else {
        final t = 1 - pow(1 - _moveProgress, 3).toDouble();
        position.setValues(
          _startPosition.x + (_targetPosition!.x - _startPosition.x) * t,
          _startPosition.y + (_targetPosition!.y - _startPosition.y) * t,
        );
      }
    }

    // Curl-up
    if (_isCurlingUp) {
      _curlProgress += dt * 2.5;
      if (_curlProgress >= 1.0) {
        _curlProgress = 1.0;
        _isCurlingUp = false;
        _curledAmount = 1.0;
      } else {
        _curledAmount = _curlProgress < 0.5
            ? 2 * _curlProgress * _curlProgress
            : 1 - pow(-2 * _curlProgress + 2, 2) / 2;
      }
    }

    // Uncurl when off target
    if (!isOnTarget && _curledAmount > 0 && !_isCurlingUp) {
      _curledAmount = (_curledAmount - dt * 4).clamp(0.0, 1.0);
    }

    // Idle animations
    _idleTimer += dt;
    if (_curledAmount < 0.5) {
      _tailWag = sin(_idleTimer * 3) * 6;
      _earTwitch = sin(_idleTimer * 5 + catIndex * 1.5) * 1.5;
    } else {
      _tailWag = sin(_idleTimer * 1.5) * 2;
      _earTwitch = 0;
    }

    // Update sparkles
    for (final sp in _sparkles) {
      sp.x += sp.vx * dt;
      sp.y += sp.vy * dt;
      sp.vy += 15 * dt; // slight gravity
      sp.life -= dt;
    }
    _sparkles.removeWhere((sp) => sp.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    final s = GameConstants.tileSize;
    final cx = s / 2;
    final cy = s / 2;
    final curl = _curledAmount;

    canvas.save();

    // --- SHADOW (soft, dynamic) ---
    final shadowWidth = s * (0.55 + curl * 0.1);
    final shadowY = cy + 16 + curl * 4;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, shadowY),
        width: shadowWidth,
        height: s * 0.12,
      ),
      shadowPaint,
    );

    if (curl < 0.01) {
      _renderStanding(canvas, s, cx, cy);
    } else if (curl > 0.99) {
      _renderCurled(canvas, s, cx, cy);
    } else {
      // Crossfade blend
      canvas.saveLayer(Rect.fromLTWH(0, 0, s, s),
          Paint()..color = Color.fromRGBO(255, 255, 255, 1.0 - curl));
      _renderStanding(canvas, s, cx, cy);
      canvas.restore();

      canvas.saveLayer(Rect.fromLTWH(0, 0, s, s),
          Paint()..color = Color.fromRGBO(255, 255, 255, curl));
      _renderCurled(canvas, s, cx, cy);
      canvas.restore();
    }

    canvas.restore();

    // Glow when on cushion
    if (isOnTarget && curl > 0.1) {
      final glowPaint = Paint()
        ..color = Color.fromRGBO(133, 205, 202, 0.18 * curl)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(cx, cy), s * 0.4, glowPaint);
    }

    // Render sparkles
    for (final sp in _sparkles) {
      final alpha = (sp.life * 2).clamp(0.0, 1.0);
      final sparkPaint = Paint()
        ..color = const Color(0xFFFFE4A8).withValues(alpha: alpha * 0.8);
      canvas.drawCircle(Offset(sp.x, sp.y), sp.size * alpha, sparkPaint);
      // Star shape accent
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.6)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(sp.x, sp.y), sp.size * alpha * 0.6, starPaint);
    }
  }

  void _renderStanding(Canvas canvas, double s, double cx, double cy) {
    final bodyPaint = Paint()..color = catColor;

    // --- BODY (gradient oval) ---
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 4),
      width: s * 0.5,
      height: s * 0.45,
    );
    final bodyGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.1,
        colors: [catLight, catColor, catDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect);
    canvas.drawOval(bodyRect, bodyGrad);

    // Fur stripes on body
    if (_hasStripes) {
      _drawBodyStripes(canvas, cx, cy + 4, s * 0.5, s * 0.45);
    }

    // Belly highlight
    final bellyPaint = Paint()
      ..color = catLight.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 6), width: s * 0.22, height: s * 0.2),
      bellyPaint,
    );

    // --- HEAD (gradient circle) ---
    final headCenter = Offset(cx, cy - 8);
    final headR = s * 0.22;
    final headRect = Rect.fromCenter(center: headCenter, width: headR * 2, height: headR * 2);
    final headGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 1.0,
        colors: [catLight, catColor, catDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(headRect);
    canvas.drawCircle(headCenter, headR, headGrad);

    // Forehead stripes
    if (_hasStripes) {
      _drawHeadStripes(canvas, headCenter.dx, headCenter.dy, headR);
    }

    // Face mask (lighter muzzle area)
    final muzzlePaint = Paint()
      ..color = catLight.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 5), width: s * 0.18, height: s * 0.12),
      muzzlePaint,
    );

    // --- EARS (with twitching) ---
    _drawEars(canvas, cx, cy - 8, headR, bodyPaint, _earTwitch);

    // --- EYES (expressive, with iris) ---
    _drawOpenEyes(canvas, cx, cy - 9);

    // Nose
    _drawNose(canvas, cx, cy - 5);

    // Mouth line
    final mouthPaint = Paint()
      ..color = catDark.withValues(alpha: 0.25)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 3.5), Offset(cx - 2.5, cy - 2), mouthPaint);
    canvas.drawLine(Offset(cx, cy - 3.5), Offset(cx + 2.5, cy - 2), mouthPaint);

    // Whiskers
    _drawWhiskers(canvas, cx, cy - 4);

    // --- TAIL (gradient, wagging) ---
    _drawStandingTail(canvas, cx, cy, s);

    // --- PAWS (with toe beans hint) ---
    _drawPaws(canvas, cx, cy + 18);

    // Subtle outline for definition
    final outlinePaint = Paint()
      ..color = catDark.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawOval(bodyRect, outlinePaint);
    canvas.drawCircle(headCenter, headR, outlinePaint);
  }

  void _renderCurled(Canvas canvas, double s, double cx, double cy) {
    final breathing = sin(_idleTimer * 1.5) * 1.5;

    // --- CURLED BODY (donut shape with gradient) ---
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 6 + breathing * 0.3),
      width: s * 0.62,
      height: s * 0.4 + breathing,
    );
    final bodyGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.1,
        colors: [catLight, catColor, catDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect);
    canvas.drawOval(bodyRect, bodyGrad);

    // Fur stripes on curled body
    if (_hasStripes) {
      _drawCurledStripes(canvas, cx, cy + 6, s * 0.62, s * 0.4);
    }

    // Body highlight
    final hlPaint = Paint()
      ..color = catLight.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 3, cy + 3),
        width: s * 0.3,
        height: s * 0.18,
      ),
      hlPaint,
    );

    // --- HEAD tucked ---
    final headCenter = Offset(cx - 8, cy - 2 + breathing * 0.2);
    final headR = s * 0.19;
    final headGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 1.0,
        colors: [catLight, catColor, catDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCenter(center: headCenter, width: headR * 2, height: headR * 2),
      );
    canvas.drawCircle(headCenter, headR, headGrad);

    // Muzzle patch
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy + 1), width: s * 0.14, height: s * 0.09),
      Paint()..color = catLight.withValues(alpha: 0.2),
    );

    // Ears (relaxed, smaller)
    _drawEars(canvas, cx - 8, cy - 2, s * 0.16, Paint()..color = catColor, 0);

    // Closed happy eyes (^_^)
    final eyeStroke = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 13, cy - 3), width: 7, height: 4),
      pi, pi, false, eyeStroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 3, cy - 3), width: 7, height: 4),
      pi, pi, false, eyeStroke,
    );

    // Rosy cheeks
    canvas.drawCircle(
      Offset(cx - 16, cy - 1),
      2.5,
      Paint()..color = const Color(0xFFFF9999).withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(cx, cy - 1),
      2.5,
      Paint()..color = const Color(0xFFFF9999).withValues(alpha: 0.2),
    );

    // Tiny nose
    _drawNose(canvas, cx - 8, cy + 1);

    // --- TAIL curled around ---
    final tailPaint = Paint()
      ..color = catColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path();
    tailPath.moveTo(cx + 16, cy + 8);
    tailPath.quadraticBezierTo(
      cx + 22, cy + 19,
      cx + 5, cy + 19 + breathing * 0.3,
    );
    tailPath.quadraticBezierTo(
      cx - 8, cy + 18,
      cx - 15, cy + 10,
    );
    canvas.drawPath(tailPath, tailPaint);

    // Tail highlight
    final tailHl = Paint()
      ..color = catLight.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tailPath, tailHl);

    // Tail tip darker
    final tipPath = Path();
    tipPath.moveTo(cx - 10, cy + 12);
    tipPath.quadraticBezierTo(cx - 13, cy + 11, cx - 15, cy + 10);
    canvas.drawPath(tipPath, Paint()
      ..color = catDark
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Front paw peeking out
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 3, cy + 14 + breathing * 0.2),
        width: 11, height: 6,
      ),
      Paint()..color = catColor,
    );
    // Toe beans on paw
    final beanPaint = Paint()..color = const Color(0xFFFFB6C1).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx + 1, cy + 15 + breathing * 0.2), 1.3, beanPaint);
    canvas.drawCircle(Offset(cx + 4, cy + 15 + breathing * 0.2), 1.3, beanPaint);

    // "Zzz" floating text with varying sizes
    final zAlpha = 0.3 + sin(_idleTimer * 2) * 0.1;
    final zFloat = sin(_idleTimer * 2) * 3;
    _drawZzz(canvas, cx + 12, cy - 18 + zFloat, zAlpha);

    // Subtle outline
    canvas.drawOval(bodyRect, Paint()
      ..color = catDark.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
  }

  // --- HELPER DRAWING METHODS ---

  void _drawBodyStripes(Canvas canvas, double cx, double cy, double w, double h) {
    final stripePaint = Paint()
      ..color = catDark.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final xOff = -6.0 + i * 6.0 + _stripeSeed * 3;
      final path = Path();
      path.moveTo(cx + xOff, cy - h * 0.35);
      path.quadraticBezierTo(cx + xOff + 2, cy, cx + xOff - 1, cy + h * 0.35);
      canvas.drawPath(path, stripePaint);
    }
  }

  void _drawHeadStripes(Canvas canvas, double hx, double hy, double r) {
    final stripePaint = Paint()
      ..color = catDark.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // M-shape forehead marking
    final mPath = Path();
    mPath.moveTo(hx - r * 0.5, hy - r * 0.2);
    mPath.lineTo(hx - r * 0.2, hy - r * 0.8);
    mPath.lineTo(hx, hy - r * 0.4);
    mPath.lineTo(hx + r * 0.2, hy - r * 0.8);
    mPath.lineTo(hx + r * 0.5, hy - r * 0.2);
    canvas.drawPath(mPath, stripePaint);
  }

  void _drawCurledStripes(Canvas canvas, double cx, double cy, double w, double h) {
    final stripePaint = Paint()
      ..color = catDark.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final angle = -0.4 + i * 0.3 + _stripeSeed * 0.2;
      final path = Path();
      path.moveTo(cx + cos(angle) * w * 0.2, cy + sin(angle) * h * 0.2);
      path.quadraticBezierTo(
        cx + cos(angle) * w * 0.35, cy + sin(angle) * h * 0.35,
        cx + cos(angle + 0.3) * w * 0.45, cy + sin(angle + 0.3) * h * 0.45,
      );
      canvas.drawPath(path, stripePaint);
    }
  }

  void _drawEars(Canvas canvas, double headX, double headY, double r, Paint paint, double twitch) {
    // Left ear
    final leftPath = Path();
    leftPath.moveTo(headX - r * 0.6, headY - r * 0.6);
    leftPath.lineTo(headX - r * 1.0 - twitch, headY - r * 1.65);
    leftPath.lineTo(headX - r * 0.1, headY - r * 0.95);
    leftPath.close();

    // Right ear
    final rightPath = Path();
    rightPath.moveTo(headX + r * 0.6, headY - r * 0.6);
    rightPath.lineTo(headX + r * 1.0 + twitch, headY - r * 1.65);
    rightPath.lineTo(headX + r * 0.1, headY - r * 0.95);
    rightPath.close();

    // Ear gradient (base darker → tip lighter)
    final earGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [catColor, catDark],
      ).createShader(
        Rect.fromLTWH(headX - r * 1.2, headY - r * 1.7, r * 2.4, r * 1.2),
      );
    canvas.drawPath(leftPath, earGrad);
    canvas.drawPath(rightPath, earGrad);

    // Inner ears (pink)
    final innerPaint = Paint()..color = const Color(0xFFFFB6C1).withValues(alpha: 0.6);
    final innerLeft = Path();
    innerLeft.moveTo(headX - r * 0.48, headY - r * 0.68);
    innerLeft.lineTo(headX - r * 0.82 - twitch * 0.8, headY - r * 1.4);
    innerLeft.lineTo(headX - r * 0.15, headY - r * 0.9);
    innerLeft.close();
    final innerRight = Path();
    innerRight.moveTo(headX + r * 0.48, headY - r * 0.68);
    innerRight.lineTo(headX + r * 0.82 + twitch * 0.8, headY - r * 1.4);
    innerRight.lineTo(headX + r * 0.15, headY - r * 0.9);
    innerRight.close();
    canvas.drawPath(innerLeft, innerPaint);
    canvas.drawPath(innerRight, innerPaint);
  }

  void _drawOpenEyes(Canvas canvas, double cx, double cy) {
    // Eye whites
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 6, cy), width: 9, height: 8),
      whitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy), width: 9, height: 8),
      whitePaint,
    );

    // Iris (colored based on cat)
    final irisColor = catIndex % 2 == 0
        ? const Color(0xFF4CAF50) // green
        : const Color(0xFFFFB300); // amber
    final irisPaint = Paint()..color = irisColor;
    canvas.drawCircle(Offset(cx - 6, cy), 3.2, irisPaint);
    canvas.drawCircle(Offset(cx + 6, cy), 3.2, irisPaint);

    // Pupils (vertical slits)
    final pupilPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 6, cy - 2), Offset(cx - 6, cy + 2), pupilPaint,
    );
    canvas.drawLine(
      Offset(cx + 6, cy - 2), Offset(cx + 6, cy + 2), pupilPaint,
    );

    // Eye highlights (two per eye for anime look)
    final hlPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 5, cy - 1.5), 1.5, hlPaint);
    canvas.drawCircle(Offset(cx - 7, cy + 1), 0.8, hlPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 1.5), 1.5, hlPaint);
    canvas.drawCircle(Offset(cx + 5, cy + 1), 0.8, hlPaint);

    // Eye outline
    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 6, cy), width: 9, height: 8),
      outlinePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy), width: 9, height: 8),
      outlinePaint,
    );
  }

  void _drawNose(Canvas canvas, double x, double y) {
    final nosePath = Path();
    nosePath.moveTo(x, y + 2.5);
    nosePath.lineTo(x - 3, y - 0.5);
    nosePath.quadraticBezierTo(x, y - 1.5, x + 3, y - 0.5);
    nosePath.close();

    // Nose gradient
    final nosePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [Color(0xFFFFAAAA), Color(0xFFFF8888)],
      ).createShader(Rect.fromCenter(center: Offset(x, y + 1), width: 8, height: 5));
    canvas.drawPath(nosePath, nosePaint);

    // Nose highlight
    canvas.drawCircle(
      Offset(x - 0.5, y - 0.2),
      0.8,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _drawWhiskers(Canvas canvas, double x, double y) {
    final whiskerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    // Three per side for more detail
    canvas.drawLine(Offset(x - 4, y - 1), Offset(x - 20, y - 5), whiskerPaint);
    canvas.drawLine(Offset(x - 4, y), Offset(x - 21, y - 1), whiskerPaint);
    canvas.drawLine(Offset(x - 4, y + 1), Offset(x - 19, y + 3), whiskerPaint);
    canvas.drawLine(Offset(x + 4, y - 1), Offset(x + 20, y - 5), whiskerPaint);
    canvas.drawLine(Offset(x + 4, y), Offset(x + 21, y - 1), whiskerPaint);
    canvas.drawLine(Offset(x + 4, y + 1), Offset(x + 19, y + 3), whiskerPaint);
  }

  void _drawStandingTail(Canvas canvas, double cx, double cy, double s) {
    final tailPath = Path();
    tailPath.moveTo(cx + 14, cy + 8);
    tailPath.cubicTo(
      cx + 22 + _tailWag, cy + 2,
      cx + 24 + _tailWag * 0.7, cy - 8,
      cx + 18 + _tailWag * 0.4, cy - 14,
    );

    // Tail body
    canvas.drawPath(tailPath, Paint()
      ..color = catColor
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Tail highlight
    canvas.drawPath(tailPath, Paint()
      ..color = catLight.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Tail tip (darker)
    final tipPath = Path();
    tipPath.moveTo(cx + 20 + _tailWag * 0.6, cy - 10);
    tipPath.quadraticBezierTo(
      cx + 19 + _tailWag * 0.4, cy - 12,
      cx + 18 + _tailWag * 0.4, cy - 14,
    );
    canvas.drawPath(tipPath, Paint()
      ..color = catDark
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);
  }

  void _drawPaws(Canvas canvas, double cx, double pawY) {
    for (final xOff in [-8.0, 8.0]) {
      final px = cx + xOff;
      // Paw body
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, pawY), width: 10, height: 6),
        Paint()..color = catColor,
      );
      // Paw highlight
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, pawY - 0.5), width: 7, height: 3.5),
        Paint()..color = catLight.withValues(alpha: 0.25),
      );
      // Toe beans (tiny pink circles)
      final beanPaint = Paint()..color = const Color(0xFFFFB6C1).withValues(alpha: 0.35);
      canvas.drawCircle(Offset(px - 2.5, pawY + 0.5), 1.2, beanPaint);
      canvas.drawCircle(Offset(px, pawY + 1), 1.2, beanPaint);
      canvas.drawCircle(Offset(px + 2.5, pawY + 0.5), 1.2, beanPaint);
    }
  }

  void _drawZzz(Canvas canvas, double x, double y, double alpha) {
    final style = TextStyle(
      color: Colors.black.withValues(alpha: alpha),
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
    );
    // Three Z's at increasing sizes floating upward
    for (int i = 0; i < 3; i++) {
      final fontSize = 7.0 + i * 2.5;
      final xOff = i * 5.0;
      final yOff = -i * 8.0 + sin(_idleTimer * 1.8 + i * 0.8) * 2;
      final tp = TextPainter(
        text: TextSpan(text: 'z', style: style.copyWith(fontSize: fontSize)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + xOff, y + yOff));
    }
  }
}

class _Sparkle {
  double x, y, vx, vy, life, size;
  _Sparkle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
  });
}
