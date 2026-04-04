import '../../models/level_data.dart';
import 'game_state.dart';

/// Result of a move attempt.
class MoveResult {
  final bool valid;
  final GameState newState;
  final int? pushedCatIndex; // Index of cat that was pushed, or null

  const MoveResult({
    required this.valid,
    required this.newState,
    this.pushedCatIndex,
  });
}

/// Applies moves to GameState following Sokoban rules.
class MoveExecutor {
  /// Attempt to move in a direction.
  ///
  /// Rules:
  /// - Player can move to an empty floor or target cell
  /// - If a cat is in the way, it gets pushed (if the cell behind it is free)
  /// - Cats cannot push other cats
  /// - Walls block everything
  static MoveResult execute(GameState state, Direction direction) {
    final delta = direction.delta;
    final newPlayerPos = state.playerPosition + delta;

    // Check bounds and wall
    if (state.isWall(newPlayerPos)) {
      return MoveResult(valid: false, newState: state);
    }

    // Check if there's a cat at the target position
    final catIndex = state.catIndexAt(newPlayerPos);

    if (catIndex >= 0) {
      // There's a cat — try to push it
      final newCatPos = newPlayerPos + delta;

      // Cat can't be pushed into a wall or another cat
      if (state.isWall(newCatPos) || state.hasCat(newCatPos)) {
        return MoveResult(valid: false, newState: state);
      }

      // Push the cat
      final newCatPositions = List<Position>.from(state.catPositions);
      newCatPositions[catIndex] = newCatPos;

      return MoveResult(
        valid: true,
        newState: state.copyWith(
          playerPosition: newPlayerPos,
          catPositions: newCatPositions,
          moveCount: state.moveCount + 1,
        ),
        pushedCatIndex: catIndex,
      );
    }

    // No cat — just move player
    return MoveResult(
      valid: true,
      newState: state.copyWith(
        playerPosition: newPlayerPos,
        moveCount: state.moveCount + 1,
      ),
    );
  }
}
