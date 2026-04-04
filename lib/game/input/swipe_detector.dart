import 'package:flutter/gestures.dart';
import '../../models/level_data.dart';

/// Converts swipe/tap gestures to game directions.
/// Uses drag distance (not velocity) for reliable mobile input.
class SwipeDetector {
  Offset? _startPosition;
  static const double _minSwipeDistance = 30.0;
  bool _hasFired = false;

  /// Call on drag start.
  void onDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _hasFired = false;
  }

  /// Call on drag update — fires direction as soon as threshold is crossed.
  /// This gives snappy one-tile-per-swipe movement.
  Direction? onDragUpdate(DragUpdateDetails details) {
    if (_startPosition == null || _hasFired) return null;

    final current = details.globalPosition;
    final dx = current.dx - _startPosition!.dx;
    final dy = current.dy - _startPosition!.dy;

    if (dx.abs() < _minSwipeDistance && dy.abs() < _minSwipeDistance) {
      return null;
    }

    // Fire once per swipe
    _hasFired = true;

    if (dx.abs() > dy.abs()) {
      return dx > 0 ? Direction.right : Direction.left;
    } else {
      return dy > 0 ? Direction.down : Direction.up;
    }
  }

  /// Call on drag end — reset for next swipe.
  void onDragEnd(DragEndDetails details) {
    _startPosition = null;
    _hasFired = false;
  }

  void reset() {
    _startPosition = null;
    _hasFired = false;
  }
}
