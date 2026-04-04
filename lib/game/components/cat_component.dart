import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// A pushable cat — the "box" in our Sokoban game.
/// When placed on a cushion, the cat curls up and lies down.
class CatComponent extends PositionComponent {
  final Color catColor;
  final int catIndex;
  bool isOnTarget;
  bool _isMoving = false;
  Vector2? _targetPosition;
  late Vector2 _startPosition;
  double _moveProgress = 0;

  // Idle animation
  double _idleTimer = 0;
  double _tailWag = 0;

  // Curl-up animation (when landing on cushion)
  bool _isCurlingUp = false;
  double _curlProgress = 0; // 0 = standing, 1 = fully curled

  // Stays curled once settled
  double _curledAmount = 0; // persistent curl state

  static final List<Color> catColors = [
    const Color(0xFFFF9F68), // Orange tabby
    const Color(0xFF8B8B8B), // Gray
    const Color(0xFF2C2C2C), // Black
    const Color(0xFFFFE4B5), // Cream/white
    const Color(0xFFD2691E), // Chocolate
    const Color(0xFFFFB347), // Light orange
    const Color(0xFFA0A0A0), // Silver
    const Color(0xFF8B6914), // Siamese brown
  ];

  CatComponent({
    required Vector2 position,
    required this.catIndex,
    this.isOnTarget = false,
  })  : catColor = catColors[catIndex % catColors.length],
        super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
          priority: 5,
        ) {
    // If starting on target, already curled
    if (isOnTarget) _curledAmount = 1.0;
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
  }

  /// Called when cat is pushed OFF a cushion (undo or pushed away)
  void unsettle() {
    _curledAmount = 0;
    _isCurlingUp = false;
    _curlProgress = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movement animation
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

    // Curl-up animation (slow, cozy transition)
    if (_isCurlingUp) {
      _curlProgress += dt * 2.5; // ~0.4 seconds to curl up
      if (_curlProgress >= 1.0) {
        _curlProgress = 1.0;
        _isCurlingUp = false;
        _curledAmount = 1.0;
      } else {
        // Ease-in-out curve
        _curledAmount = _curlProgress < 0.5
            ? 2 * _curlProgress * _curlProgress
            : 1 - pow(-2 * _curlProgress + 2, 2) / 2;
      }
    }

    // When not on target, uncurl
    if (!isOnTarget && _curledAmount > 0 && !_isCurlingUp) {
      _curledAmount = (_curledAmount - dt * 4).clamp(0.0, 1.0);
    }

    // Idle animation (only when standing, not curled)
    _idleTimer += dt;
    if (_curledAmount < 0.5) {
      _tailWag = sin(_idleTimer * 3) * 5;
    } else {
      // Gentle breathing when curled
      _tailWag = sin(_idleTimer * 1.5) * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    final s = GameConstants.tileSize;
    final cx = s / 2;
    final cy = s / 2;
    final curl = _curledAmount;

    canvas.save();

    // --- SHADOW ---
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.1);
    final shadowWidth = s * (0.55 + curl * 0.1); // wider shadow when curled
    final shadowY = cy + 16 + curl * 4; // lower shadow when curled
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, shadowY),
        width: shadowWidth,
        height: s * 0.15,
      ),
      shadowPaint,
    );

    if (curl < 0.01) {
      _renderStanding(canvas, s, cx, cy);
    } else if (curl > 0.99) {
      _renderCurled(canvas, s, cx, cy);
    } else {
      // Blend: draw standing at (1-curl) opacity, curled at curl opacity
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
    if (isOnTarget) {
      final glowPaint = Paint()
        ..color = Color.fromRGBO(133, 205, 202, 0.15 * curl)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(cx, cy), s * 0.4, glowPaint);
    }
  }

  /// Render the standing/alert cat pose.
  void _renderStanding(Canvas canvas, double s, double cx, double cy) {
    final bodyPaint = Paint()..color = catColor;

    // Body (oval, upright)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: s * 0.5,
        height: s * 0.45,
      ),
      bodyPaint,
    );

    // Head
    canvas.drawCircle(Offset(cx, cy - 8), s * 0.22, bodyPaint);

    // Ears
    _drawEars(canvas, cx, cy - 8, s * 0.22, bodyPaint);

    // Open eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 6, cy - 9), 3, eyePaint);
    canvas.drawCircle(Offset(cx + 6, cy - 9), 3, eyePaint);
    // Highlights
    final hlPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 5, cy - 10), 1.2, hlPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 10), 1.2, hlPaint);

    // Nose
    _drawNose(canvas, cx, cy - 5);

    // Whiskers
    _drawWhiskers(canvas, cx, cy - 5);

    // Tail (wagging)
    final tailPaint = Paint()
      ..color = catColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path();
    tailPath.moveTo(cx + 14, cy + 8);
    tailPath.quadraticBezierTo(
      cx + 22 + _tailWag, cy - 2,
      cx + 18 + _tailWag * 0.5, cy - 10,
    );
    canvas.drawPath(tailPath, tailPaint);

    // Paws (two little bumps at bottom)
    final pawPaint = Paint()..color = catColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy + 18), width: 8, height: 5),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 8, cy + 18), width: 8, height: 5),
      pawPaint,
    );
  }

  /// Render the curled-up/sleeping cat pose.
  void _renderCurled(Canvas canvas, double s, double cx, double cy) {
    final bodyPaint = Paint()..color = catColor;
    final breathing = sin(_idleTimer * 1.5) * 1.5;

    // Curled body — wider, flatter oval (like a donut shape)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 6 + breathing * 0.3),
        width: s * 0.6,
        height: s * 0.38 + breathing,
      ),
      bodyPaint,
    );

    // Head tucked to the side, resting on body
    canvas.drawCircle(
      Offset(cx - 8, cy - 2 + breathing * 0.2),
      s * 0.18,
      bodyPaint,
    );

    // Ears (smaller, relaxed)
    _drawEars(canvas, cx - 8, cy - 2, s * 0.16, bodyPaint);

    // Closed happy eyes (^_^)
    final eyeStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx - 13, cy - 3),
        width: 6, height: 4,
      ),
      pi, pi, false, eyeStroke,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx - 3, cy - 3),
        width: 6, height: 4,
      ),
      pi, pi, false, eyeStroke,
    );

    // Tiny nose
    _drawNose(canvas, cx - 8, cy + 1);

    // Tail curled around body
    final tailPaint = Paint()
      ..color = catColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path();
    tailPath.moveTo(cx + 16, cy + 8);
    tailPath.quadraticBezierTo(
      cx + 20, cy + 18,
      cx + 5, cy + 18 + breathing * 0.3,
    );
    tailPath.quadraticBezierTo(
      cx - 8, cy + 17,
      cx - 14, cy + 10,
    );
    canvas.drawPath(tailPath, tailPaint);

    // Front paw peeking out
    final pawPaint = Paint()..color = catColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 2, cy + 14 + breathing * 0.2),
        width: 10, height: 5,
      ),
      pawPaint,
    );

    // "Zzz" indicator
    final zStyle = TextStyle(
      color: Colors.black.withValues(alpha: 0.25),
      fontSize: 9,
      fontWeight: FontWeight.bold,
    );
    final tp = TextPainter(
      text: TextSpan(text: 'z z', style: zStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx + 8, cy - 16 + sin(_idleTimer * 2) * 2));
  }

  void _drawEars(Canvas canvas, double headX, double headY, double r, Paint paint) {
    final earPath = Path();
    // Left ear
    earPath.moveTo(headX - r * 0.6, headY - r * 0.7);
    earPath.lineTo(headX - r * 1.0, headY - r * 1.6);
    earPath.lineTo(headX - r * 0.1, headY - r * 1.0);
    earPath.close();
    // Right ear
    earPath.moveTo(headX + r * 0.6, headY - r * 0.7);
    earPath.lineTo(headX + r * 1.0, headY - r * 1.6);
    earPath.lineTo(headX + r * 0.1, headY - r * 1.0);
    earPath.close();
    canvas.drawPath(earPath, paint);

    // Inner ears (pink)
    final innerPaint = Paint()..color = const Color(0xFFFFB6C1);
    final innerPath = Path();
    innerPath.moveTo(headX - r * 0.5, headY - r * 0.75);
    innerPath.lineTo(headX - r * 0.85, headY - r * 1.35);
    innerPath.lineTo(headX - r * 0.15, headY - r * 0.95);
    innerPath.close();
    innerPath.moveTo(headX + r * 0.5, headY - r * 0.75);
    innerPath.lineTo(headX + r * 0.85, headY - r * 1.35);
    innerPath.lineTo(headX + r * 0.15, headY - r * 0.95);
    innerPath.close();
    canvas.drawPath(innerPath, innerPaint);
  }

  void _drawNose(Canvas canvas, double x, double y) {
    final nosePaint = Paint()..color = const Color(0xFFFF9999);
    final nosePath = Path();
    nosePath.moveTo(x, y + 2);
    nosePath.lineTo(x - 2.5, y - 0.5);
    nosePath.lineTo(x + 2.5, y - 0.5);
    nosePath.close();
    canvas.drawPath(nosePath, nosePaint);
  }

  void _drawWhiskers(Canvas canvas, double x, double y) {
    final whiskerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(x - 4, y), Offset(x - 18, y - 3), whiskerPaint);
    canvas.drawLine(Offset(x - 4, y + 1), Offset(x - 18, y + 2), whiskerPaint);
    canvas.drawLine(Offset(x + 4, y), Offset(x + 18, y - 3), whiskerPaint);
    canvas.drawLine(Offset(x + 4, y + 1), Offset(x + 18, y + 2), whiskerPaint);
  }
}
