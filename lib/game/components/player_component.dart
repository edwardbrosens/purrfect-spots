import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/level_data.dart';

/// The café owner player character — richly detailed top-down character.
class PlayerComponent extends PositionComponent {
  Direction facing;
  bool _isMoving = false;
  Vector2? _targetPosition;
  late Vector2 _startPosition;
  double _moveProgress = 0;

  // Idle animation
  double _idleTimer = 0;
  double _bobAmount = 0;

  PlayerComponent({
    required Vector2 position,
    this.facing = Direction.down,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
          priority: 10,
        );

  bool get isMoving => _isMoving;

  void moveTo(Vector2 target, Direction direction) {
    facing = direction;
    _startPosition = position.clone();
    _targetPosition = target;
    _moveProgress = 0;
    _isMoving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isMoving && _targetPosition != null) {
      _moveProgress += dt / GameConstants.moveDuration.inMilliseconds * 1000;
      if (_moveProgress >= 1.0) {
        _moveProgress = 1.0;
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

    _idleTimer += dt;
    _bobAmount = sin(_idleTimer * 2.5) * 0.8;
  }

  @override
  void render(Canvas canvas) {
    final s = GameConstants.tileSize;
    final cx = s / 2;
    final cy = s / 2;

    // Direction offsets for eyes/face
    double eyeOffX = 0, eyeOffY = 0;
    switch (facing) {
      case Direction.left:  eyeOffX = -3;
      case Direction.right: eyeOffX = 3;
      case Direction.up:    eyeOffY = -2;
      case Direction.down:  eyeOffY = 1;
    }

    // --- SHADOW ---
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 20),
        width: s * 0.5,
        height: s * 0.1,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final bob = _bobAmount;

    // --- BODY / APRON (gradient) ---
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 4 + bob),
      width: s * 0.52,
      height: s * 0.56,
    );
    final bodyRR = RRect.fromRectAndRadius(bodyRect, const Radius.circular(10));
    final bodyGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CatCafeTheme.playerLight,
          CatCafeTheme.player,
          CatCafeTheme.playerDark,
        ],
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRR, bodyGrad);

    // Apron highlight (left edge sheen)
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRR, sheenPaint);

    // Apron strings
    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    // Left string
    canvas.drawLine(
      Offset(cx - s * 0.22, cy - 2 + bob),
      Offset(cx - s * 0.3, cy + 4 + bob),
      stringPaint,
    );
    // Right string
    canvas.drawLine(
      Offset(cx + s * 0.22, cy - 2 + bob),
      Offset(cx + s * 0.3, cy + 4 + bob),
      stringPaint,
    );

    // Apron pocket with gradient
    final pocketRect = Rect.fromCenter(
      center: Offset(cx, cy + 10 + bob),
      width: s * 0.26,
      height: s * 0.14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pocketRect, const Radius.circular(4)),
      Paint()..color = CatCafeTheme.playerLight.withValues(alpha: 0.4),
    );
    // Pocket stitch
    canvas.drawRRect(
      RRect.fromRectAndRadius(pocketRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Cat treat peeking from pocket
    final treatPaint = Paint()..color = const Color(0xFFE8A87C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 3, cy + 5 + bob),
          width: 5, height: 8,
        ),
        const Radius.circular(2),
      ),
      treatPaint,
    );

    // --- HEAD ---
    final headCy = cy - 10 + bob;
    final headR = s * 0.21;
    final headRect = Rect.fromCenter(
      center: Offset(cx, headCy),
      width: headR * 2,
      height: headR * 2,
    );

    // Skin with gradient
    final skinGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [
          const Color(0xFFFFE0C0),
          const Color(0xFFFFDBB4),
          const Color(0xFFEEC99C),
        ],
      ).createShader(headRect);
    canvas.drawCircle(Offset(cx, headCy), headR, skinGrad);

    // --- HAIR (gradient, layered) ---
    final hairRect = Rect.fromCenter(
      center: Offset(cx, headCy - 3),
      width: s * 0.46,
      height: s * 0.34,
    );
    final hairGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.5),
        radius: 1.0,
        colors: [
          const Color(0xFF6D4C3A),
          const Color(0xFF5D4037),
          const Color(0xFF3E2723),
        ],
      ).createShader(hairRect);
    canvas.drawArc(hairRect, pi, pi, true, hairGrad);

    // Hair highlight
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx - 3, headCy - 5),
        width: s * 0.25,
        height: s * 0.15,
      ),
      pi, pi * 0.6, false,
      Paint()
        ..color = const Color(0xFF8D6E5A).withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Side hair
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - headR + 2, headCy),
        width: 6, height: 10,
      ),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + headR - 2, headCy),
        width: 6, height: 10,
      ),
      Paint()..color = const Color(0xFF5D4037),
    );

    // --- EYES ---
    final eyeY = headCy + eyeOffY;
    for (final side in [-1.0, 1.0]) {
      final ex = cx + side * 5.5 + eyeOffX;

      // Eye white
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, eyeY), width: 7, height: 6.5),
        Paint()..color = Colors.white,
      );
      // Iris
      canvas.drawCircle(Offset(ex, eyeY), 2.5, Paint()..color = const Color(0xFF5D4037));
      // Pupil
      canvas.drawCircle(Offset(ex, eyeY), 1.3, Paint()..color = Colors.black);
      // Highlight
      canvas.drawCircle(
        Offset(ex + 0.8, eyeY - 0.8),
        0.9,
        Paint()..color = Colors.white,
      );
      // Eye outline
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, eyeY), width: 7, height: 6.5),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 5.5 + eyeOffX, eyeY - 5), width: 8, height: 4),
      pi + 0.3, pi * 0.5, false, browPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 5.5 + eyeOffX, eyeY - 5), width: 8, height: 4),
      pi + 0.3, pi * 0.5, false, browPaint,
    );

    // --- MOUTH (friendly smile) ---
    final mouthY = headCy + 5 + eyeOffY * 0.3;
    final smilePaint = Paint()
      ..color = const Color(0xFF8B6450)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + eyeOffX * 0.3, mouthY),
        width: 8, height: 5,
      ),
      0.1, pi - 0.2, false, smilePaint,
    );

    // Rosy cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9999).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(cx - 10, headCy + 2), 4, cheekPaint);
    canvas.drawCircle(Offset(cx + 10, headCy + 2), 4, cheekPaint);

    // --- ARMS ---
    final armPaint = Paint()
      ..color = const Color(0xFFFFDBB4)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Left arm
    final leftArm = Path();
    leftArm.moveTo(cx - s * 0.23, cy - 2 + bob);
    leftArm.quadraticBezierTo(cx - s * 0.35, cy + 6 + bob, cx - s * 0.28, cy + 14 + bob);
    canvas.drawPath(leftArm, armPaint);
    // Right arm
    final rightArm = Path();
    rightArm.moveTo(cx + s * 0.23, cy - 2 + bob);
    rightArm.quadraticBezierTo(cx + s * 0.35, cy + 6 + bob, cx + s * 0.28, cy + 14 + bob);
    canvas.drawPath(rightArm, armPaint);
    // Hands
    canvas.drawCircle(
      Offset(cx - s * 0.28, cy + 14 + bob), 3,
      Paint()..color = const Color(0xFFFFDBB4),
    );
    canvas.drawCircle(
      Offset(cx + s * 0.28, cy + 14 + bob), 3,
      Paint()..color = const Color(0xFFFFDBB4),
    );

    // --- BODY OUTLINE (subtle) ---
    canvas.drawRRect(bodyRR, Paint()
      ..color = CatCafeTheme.playerDark.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6);
  }
}
