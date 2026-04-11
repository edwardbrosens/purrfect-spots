import 'package:flame/components.dart';
import '../../config/constants.dart';
import '../../config/level_themes.dart';
import '../../models/level_data.dart';
import 'tile_component.dart';

/// The board component that holds all tile sprites.
class Board extends Component {
  final LevelData levelData;

  final Map<int, TileComponent> _targetTiles = {};

  Board({required this.levelData});

  static int _key(int row, int col) => row * 10000 + col;

  void setCatOnTarget(Position pos, bool hasCat) {
    _targetTiles[_key(pos.row, pos.col)]?.hasCat = hasCat;
  }

  @override
  Future<void> onLoad() async {
    final palette = themeForFloor(levelData.floor).palette;
    // Create tile components for each cell
    for (int row = 0; row < levelData.height; row++) {
      for (int col = 0; col < levelData.width; col++) {
        final cellType = levelData.grid[row][col];
        final position = Vector2(
          col * GameConstants.tileSize,
          row * GameConstants.tileSize,
        );

        final tile = TileComponent(
          cellType: cellType,
          position: position,
          palette: palette,
          isTarget: cellType == CellType.target,
          row: row,
          col: col,
        );
        if (cellType == CellType.target) {
          _targetTiles[_key(row, col)] = tile;
        }
        add(tile);
      }
    }
  }

  /// Get the pixel position for a grid coordinate.
  static Vector2 gridToPixel(Position gridPos) {
    return Vector2(
      gridPos.col * GameConstants.tileSize,
      gridPos.row * GameConstants.tileSize,
    );
  }

  /// Get the grid position from a pixel coordinate.
  static Position pixelToGrid(Vector2 pixel) {
    return Position(
      (pixel.y / GameConstants.tileSize).floor(),
      (pixel.x / GameConstants.tileSize).floor(),
    );
  }
}
