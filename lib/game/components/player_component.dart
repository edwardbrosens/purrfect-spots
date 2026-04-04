import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/level_data.dart';

/// The café owner player character.
class PlayerComponent extends PositionComponent {
  Direction facing;
  bool _isMoving = false;
  Vector2? _targetPosition;
  late Vector2 _startPosition;
  double _moveProgress = 0;

  PlayerComponent({
    required Vector2 position,
    this.facing = Direction.down,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
          priority: 10,
        );

  bool get isMoving => _isMoving;

  /// Start animating to a new grid position.
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
        // Smooth ease-out interpolation
        final t = 1 - pow(1 - _moveProgress, 3).toDouble();
        position.setValues(
          _startPosition.x + (_targetPosition!.x - _startPosition.x) * t,
          _startPosition.y + (_targetPosition!.y - _startPosition.y) * t,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final tileSize = GameConstants.tileSize;
    final centerX = tileSize / 2;
    final centerY = tileSize / 2;

    // Body (blue apron)
    final bodyPaint = Paint()..color = CatCafeTheme.player;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 4),
          width: tileSize * 0.5,
          height: tileSize * 0.55,
        ),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFDBB4); // skin tone
    canvas.drawCircle(
      Offset(centerX, centerY - 10),
      tileSize * 0.2,
      headPaint,
    );

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 12),
        width: tileSize * 0.42,
        height: tileSize * 0.3,
      ),
      pi,
      pi,
      true,
      hairPaint,
    );

    // Eyes (direction-dependent)
    final eyePaint = Paint()..color = Colors.black;
    double eyeOffsetX = 0;
    double eyeOffsetY = 0;
    switch (facing) {
      case Direction.left:
        eyeOffsetX = -3;
      case Direction.right:
        eyeOffsetX = 3;
      case Direction.up:
        eyeOffsetY = -2;
      case Direction.down:
        eyeOffsetY = 1;
    }

    canvas.drawCircle(
      Offset(centerX - 5 + eyeOffsetX, centerY - 11 + eyeOffsetY),
      2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + 5 + eyeOffsetX, centerY - 11 + eyeOffsetY),
      2,
      eyePaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX + eyeOffsetX, centerY - 6),
        width: 8,
        height: 5,
      ),
      0.1,
      pi - 0.2,
      false,
      smilePaint,
    );

    // Apron pocket
    final pocketPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 8),
          width: tileSize * 0.25,
          height: tileSize * 0.15,
        ),
        const Radius.circular(3),
      ),
      pocketPaint,
    );
  }
}
