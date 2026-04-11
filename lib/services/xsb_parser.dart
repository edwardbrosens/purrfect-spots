import '../models/level_data.dart';

/// Parses standard XSB/SOK format puzzle levels into our LevelData format.
///
/// XSB format characters:
///   # = wall
///   (space) = floor
///   $ = box (cat in our game)
///   . = goal (cushion)
///   @ = player
///   + = player on goal
///   * = box on goal
///   - or _ = floor (alternative)
class XsbParser {
  /// Parse a multi-level XSB string into a list of LevelData.
  /// Levels are separated by blank lines.
  /// Lines starting with ; are comments (may contain title/author).
  static List<LevelData> parseMultipleLevels(
    String xsbContent, {
    String collectionName = 'Classic',
    int startFloor = 1,
    int defaultUndoLimit = 3,
  }) {
    final levels = <LevelData>[];
    final lines = xsbContent.split('\n');

    List<String> currentGrid = [];
    String? currentTitle;
    int levelIndex = 0;

    for (final rawLine in lines) {
      final line = rawLine.trimRight();

      // Comment lines — may contain metadata
      if (line.startsWith(';')) {
        final comment = line.substring(1).trim();
        if (comment.toLowerCase().startsWith('title:')) {
          currentTitle = comment.substring(6).trim();
        } else if (currentGrid.isEmpty && currentTitle == null && comment.isNotEmpty) {
          // Use first comment as title if no explicit title
          currentTitle = comment;
        }
        continue;
      }

      // Check if this line is part of a grid (contains wall characters)
      if (line.isNotEmpty && _isGridLine(line)) {
        currentGrid.add(line);
      } else if (currentGrid.isNotEmpty) {
        // End of a level — parse it
        final level = _parseSingleLevel(
          currentGrid,
          id: 'floor_${(startFloor + levelIndex).toString().padLeft(2, '0')}',
          name: currentTitle ?? '$collectionName #${levelIndex + 1}',
          floor: startFloor + levelIndex,
          undoLimit: defaultUndoLimit,
        );
        if (level != null) {
          levels.add(level);
          levelIndex++;
        }
        currentGrid = [];
        currentTitle = null;
      }
    }

    // Don't forget the last level
    if (currentGrid.isNotEmpty) {
      final level = _parseSingleLevel(
        currentGrid,
        id: 'floor_${(startFloor + levelIndex).toString().padLeft(2, '0')}',
        name: currentTitle ?? '$collectionName #${levelIndex + 1}',
        floor: startFloor + levelIndex,
        undoLimit: defaultUndoLimit,
      );
      if (level != null) {
        levels.add(level);
      }
    }

    return levels;
  }

  /// Check if a line looks like a puzzle grid row.
  static bool _isGridLine(String line) {
    // Must contain at least one wall character
    if (!line.contains('#')) return false;
    // All characters must be valid XSB characters
    return line.runes.every((r) {
      final c = String.fromCharCode(r);
      return '#.@+\$* -_'.contains(c);
    });
  }

  /// Parse a single level grid.
  static LevelData? _parseSingleLevel(
    List<String> gridLines, {
    required String id,
    required String name,
    required int floor,
    required int undoLimit,
  }) {
    if (gridLines.isEmpty) return null;

    // Determine grid dimensions
    final height = gridLines.length;
    final width = gridLines.map((l) => l.length).reduce(max);

    // Pad lines to equal width
    final paddedLines =
        gridLines.map((l) => l.padRight(width)).toList();

    // Parse into our format
    final grid = <List<CellType>>[];
    Position? playerStart;
    final catStarts = <Position>[];
    final targetPositions = <Position>[];

    for (int row = 0; row < height; row++) {
      final gridRow = <CellType>[];
      for (int col = 0; col < width; col++) {
        final char = paddedLines[row][col];
        switch (char) {
          case '#':
            gridRow.add(CellType.wall);
          case '.': // Goal
            gridRow.add(CellType.target);
            targetPositions.add(Position(row, col));
          case '\$': // Box (cat)
            gridRow.add(CellType.floor);
            catStarts.add(Position(row, col));
          case '*': // Box on goal
            gridRow.add(CellType.target);
            targetPositions.add(Position(row, col));
            catStarts.add(Position(row, col));
          case '@': // Player
            gridRow.add(CellType.floor);
            playerStart = Position(row, col);
          case '+': // Player on goal
            gridRow.add(CellType.target);
            targetPositions.add(Position(row, col));
            playerStart = Position(row, col);
          default: // space, -, _ = floor (or outside = wall)
            // Determine if this space is inside or outside the level
            if (_isInsideLevel(paddedLines, row, col)) {
              gridRow.add(CellType.floor);
            } else {
              gridRow.add(CellType.wall);
            }
        }
      }
      grid.add(gridRow);
    }

    // Validate
    if (playerStart == null) return null;
    if (catStarts.isEmpty) return null;
    if (catStarts.length != targetPositions.length) return null;

    // Calculate star thresholds based on level complexity
    final optimalEstimate = catStarts.length * 15 + width + height;
    final starThresholds = [
      optimalEstimate * 3, // 1 star
      optimalEstimate * 2, // 2 stars
      optimalEstimate, // 3 stars
    ];

    return LevelData(
      id: id,
      name: name,
      floor: floor,
      width: width,
      height: height,
      grid: grid,
      playerStart: playerStart,
      catStarts: catStarts,
      targetPositions: targetPositions,
      starThresholds: starThresholds,
      undoLimit: undoLimit,
    );
  }

  /// Simple flood-fill check: is this space reachable from any
  /// wall-enclosed interior? (Spaces outside walls should be walls.)
  static bool _isInsideLevel(List<String> grid, int row, int col) {
    // If on the edge of the grid and it's a space, it's outside
    if (row == 0 ||
        row == grid.length - 1 ||
        col == 0 ||
        col == grid[0].length - 1) {
      final c = grid[row][col];
      return c != ' ' && c != '-' && c != '_';
    }

    // Check if enclosed by walls in all 4 cardinal directions
    bool wallLeft = false, wallRight = false;
    bool wallUp = false, wallDown = false;

    for (int c = col - 1; c >= 0; c--) {
      if (grid[row][c] == '#') { wallLeft = true; break; }
    }
    for (int c = col + 1; c < grid[row].length; c++) {
      if (grid[row][c] == '#') { wallRight = true; break; }
    }
    for (int r = row - 1; r >= 0; r--) {
      if (col < grid[r].length && grid[r][col] == '#') {
        wallUp = true;
        break;
      }
    }
    for (int r = row + 1; r < grid.length; r++) {
      if (col < grid[r].length && grid[r][col] == '#') {
        wallDown = true;
        break;
      }
    }

    return wallLeft && wallRight && wallUp && wallDown;
  }

  static int max(int a, int b) => a > b ? a : b;
}
