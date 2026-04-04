import 'package:flame/components.dart';
import '../../config/constants.dart';
import '../../models/level_data.dart';
import 'tile_component.dart';

/// The board component that holds all tile sprites.
class Board extends Component {
  final LevelData levelData;

  Board({required this.levelData});

  @override
  Future<void> onLoad() async {
    // Create tile components for each cell
    for (int row = 0; row < levelData.height; row++) {
      for (int col = 0; col < levelData.width; col++) {
        final cellType = levelData.grid[row][col];
        final position = Vector2(
          col * GameConstants.tileSize,
          row * GameConstants.tileSize,
        );

        add(TileComponent(
          cellType: cellType,
          position: position,
          isTarget: cellType == CellType.target,
        ));
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
