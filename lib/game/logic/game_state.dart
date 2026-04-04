import '../../models/level_data.dart';

/// Pure Sokoban game state — no rendering logic.
/// Immutable: every move creates a new GameState.
class GameState {
  final List<List<CellType>> grid;
  final int width;
  final int height;
  final Position playerPosition;
  final List<Position> catPositions;
  final List<Position> targetPositions;
  final int moveCount;

  const GameState({
    required this.grid,
    required this.width,
    required this.height,
    required this.playerPosition,
    required this.catPositions,
    required this.targetPositions,
    this.moveCount = 0,
  });

  /// Create initial state from level data.
  factory GameState.fromLevel(LevelData level) {
    return GameState(
      grid: level.grid,
      width: level.width,
      height: level.height,
      playerPosition: level.playerStart,
      catPositions: List.from(level.catStarts),
      targetPositions: List.from(level.targetPositions),
      moveCount: 0,
    );
  }

  /// Check if a position is within bounds.
  bool isInBounds(Position pos) =>
      pos.row >= 0 && pos.row < height && pos.col >= 0 && pos.col < width;

  /// Check if a position is a wall.
  bool isWall(Position pos) =>
      !isInBounds(pos) || grid[pos.row][pos.col] == CellType.wall;

  /// Check if there's a cat at the given position.
  bool hasCat(Position pos) => catPositions.contains(pos);

  /// Get the index of a cat at the given position, or -1.
  int catIndexAt(Position pos) => catPositions.indexOf(pos);

  /// Check if the level is complete — all cats on target positions.
  bool get isComplete {
    for (final target in targetPositions) {
      if (!hasCat(target)) return false;
    }
    return true;
  }

  /// Check if a specific cat is on a target.
  bool isCatOnTarget(int catIndex) =>
      targetPositions.contains(catPositions[catIndex]);

  /// Create a copy with updated positions.
  GameState copyWith({
    Position? playerPosition,
    List<Position>? catPositions,
    int? moveCount,
  }) =>
      GameState(
        grid: grid,
        width: width,
        height: height,
        playerPosition: playerPosition ?? this.playerPosition,
        catPositions: catPositions ?? List.from(this.catPositions),
        targetPositions: targetPositions,
        moveCount: moveCount ?? this.moveCount,
      );
}
