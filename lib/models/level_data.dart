/// Types of cells in the game grid.
enum CellType {
  wall,
  floor,
  target, // cushion
}

/// A position on the grid.
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) => Position(row + other.row, col + other.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode * 31);

  @override
  String toString() => 'Position($row, $col)';
}

/// Direction of movement.
enum Direction {
  up,
  down,
  left,
  right;

  Position get delta {
    switch (this) {
      case Direction.up:
        return const Position(-1, 0);
      case Direction.down:
        return const Position(1, 0);
      case Direction.left:
        return const Position(0, -1);
      case Direction.right:
        return const Position(0, 1);
    }
  }
}

/// Parsed level definition.
class LevelData {
  final String id;
  final String name;
  final int floor;
  final int width;
  final int height;
  final List<List<CellType>> grid;
  final Position playerStart;
  final List<Position> catStarts;
  final List<Position> targetPositions;
  final List<int> starThresholds; // [1-star max, 2-star max, 3-star max]
  final int undoLimit;

  const LevelData({
    required this.id,
    required this.name,
    required this.floor,
    required this.width,
    required this.height,
    required this.grid,
    required this.playerStart,
    required this.catStarts,
    required this.targetPositions,
    required this.starThresholds,
    required this.undoLimit,
  });

  /// Calculate star rating based on number of moves.
  int starsForMoves(int moves) {
    if (starThresholds.length >= 3 && moves <= starThresholds[2]) return 3;
    if (starThresholds.length >= 2 && moves <= starThresholds[1]) return 2;
    return 1;
  }

  /// Parse a level from JSON map.
  factory LevelData.fromJson(Map<String, dynamic> json) {
    final gridStrings = List<String>.from(json['grid']);
    final height = gridStrings.length;
    final width = gridStrings[0].length;

    final grid = <List<CellType>>[];
    Position? playerStart;
    final catStarts = <Position>[];
    final targetPositions = <Position>[];

    for (int row = 0; row < height; row++) {
      final gridRow = <CellType>[];
      for (int col = 0; col < width; col++) {
        final char = gridStrings[row][col];
        switch (char) {
          case '#':
            gridRow.add(CellType.wall);
          case '.':
            gridRow.add(CellType.floor);
          case 'T':
            gridRow.add(CellType.target);
            targetPositions.add(Position(row, col));
          case 'C':
            gridRow.add(CellType.floor);
            catStarts.add(Position(row, col));
          case 'P':
            gridRow.add(CellType.floor);
            playerStart = Position(row, col);
          case 'X': // Cat already on a target
            gridRow.add(CellType.target);
            targetPositions.add(Position(row, col));
            catStarts.add(Position(row, col));
          default:
            gridRow.add(CellType.floor);
        }
      }
      grid.add(gridRow);
    }

    if (playerStart == null) {
      throw FormatException('Level ${json['id']} has no player start position');
    }

    return LevelData(
      id: json['id'] as String,
      name: json['name'] as String,
      floor: json['floor'] as int,
      width: width,
      height: height,
      grid: grid,
      playerStart: playerStart,
      catStarts: catStarts,
      targetPositions: targetPositions,
      starThresholds: List<int>.from(json['starThresholds']),
      undoLimit: json['undoLimit'] as int? ?? 3,
    );
  }
}
