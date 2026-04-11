import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/level_data.dart';
import 'components/board.dart';
import 'components/cat_component.dart';
import 'components/player_component.dart';
import 'logic/game_state.dart';
import 'logic/move_executor.dart';
import 'logic/undo_manager.dart';

/// The main Flame game — bridges logic to rendering.
class CatCafeGame extends FlameGame {
  final LevelData levelData;
  final VoidCallback? onLevelComplete;
  final VoidCallback? onMoveChanged;

  GameState _gameState;
  final UndoManager _undoManager;
  late PlayerComponent _player;
  late Board _board;
  List<CatComponent> _cats = [];
  bool _inputLocked = false;

  CatCafeGame({
    required this.levelData,
    this.onLevelComplete,
    this.onMoveChanged,
    int? initialUndosRemaining,
  })  : _gameState = GameState.fromLevel(levelData),
        _undoManager = UndoManager(
          undoLimit: levelData.undoLimit,
          initialRemaining: initialUndosRemaining,
        );

  GameState get gameState => _gameState;
  UndoManager get undoManager => _undoManager;
  int get moveCount => _gameState.moveCount;
  int get undosRemaining => _undoManager.undosRemaining;
  bool get canUndo => _undoManager.canUndo;
  bool get isComplete => _gameState.isComplete;

  @override
  Color backgroundColor() => CatCafeTheme.background;

  @override
  Future<void> onLoad() async {
    // Calculate board size and center it
    final boardWidth = levelData.width * GameConstants.tileSize;
    final boardHeight = levelData.height * GameConstants.tileSize;

    // Use camera to center the board
    final boardCenter = Vector2(boardWidth / 2, boardHeight / 2);
    camera.viewfinder.position = boardCenter;

    // Scale to fit screen
    _fitBoardToScreen(boardWidth, boardHeight);

    // Add the tile board
    _board = Board(levelData: levelData);
    world.add(_board);

    // Add cat components
    _cats = [];
    for (int i = 0; i < levelData.catStarts.length; i++) {
      final catPos = levelData.catStarts[i];
      final onTarget = levelData.targetPositions.contains(catPos);
      final cat = CatComponent(
        position: Board.gridToPixel(catPos),
        catIndex: i,
        isOnTarget: onTarget,
      );
      _cats.add(cat);
      world.add(cat);
      if (onTarget) _board.setCatOnTarget(catPos, true);
    }

    // Add player component
    _player = PlayerComponent(
      position: Board.gridToPixel(levelData.playerStart),
    );
    world.add(_player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      final boardWidth = levelData.width * GameConstants.tileSize;
      final boardHeight = levelData.height * GameConstants.tileSize;
      _fitBoardToScreen(boardWidth, boardHeight);
    }
  }

  void _fitBoardToScreen(double boardWidth, double boardHeight) {
    final screenSize = size;
    // Leave some padding for HUD
    final availableWidth = screenSize.x * 0.95;
    final availableHeight = screenSize.y * 0.85;

    final scaleX = availableWidth / boardWidth;
    final scaleY = availableHeight / boardHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    camera.viewfinder.zoom = scale.clamp(0.3, 2.0);
  }

  /// Handle a swipe direction input.
  void handleMove(Direction direction) {
    if (_inputLocked || _gameState.isComplete) return;

    final result = MoveExecutor.execute(_gameState, direction);

    if (!result.valid) return;

    // Save current state for undo
    _undoManager.push(_gameState);
    _gameState = result.newState;

    // Animate player
    _player.moveTo(
      Board.gridToPixel(_gameState.playerPosition),
      direction,
    );

    // Animate pushed cat
    if (result.pushedCatIndex != null) {
      final catIndex = result.pushedCatIndex!;
      final cat = _cats[catIndex];
      final newPos = _gameState.catPositions[catIndex];
      // Clear dent at old target (if any)
      for (final t in levelData.targetPositions) {
        _board.setCatOnTarget(t, _gameState.catPositions.contains(t));
      }
      cat.moveTo(Board.gridToPixel(newPos));
      cat.isOnTarget = _gameState.isCatOnTarget(catIndex);
      if (cat.isOnTarget) {
        cat.settle();
      }
    }

    // Lock input during animation
    _inputLocked = true;
    Future.delayed(GameConstants.moveDuration, () {
      _inputLocked = false;
      onMoveChanged?.call();

      // Check win condition
      if (_gameState.isComplete) {
        onLevelComplete?.call();
      }
    });
  }

  /// Undo the last move.
  bool undo() {
    if (_inputLocked) return false;

    final previousState = _undoManager.undo();
    if (previousState == null) return false;

    _gameState = previousState;

    // Snap positions (no animation for undo)
    _player.position.setFrom(Board.gridToPixel(_gameState.playerPosition));
    for (int i = 0; i < _cats.length; i++) {
      _cats[i].position.setFrom(Board.gridToPixel(_gameState.catPositions[i]));
      final wasOnTarget = _cats[i].isOnTarget;
      _cats[i].isOnTarget = _gameState.isCatOnTarget(i);
      if (wasOnTarget && !_cats[i].isOnTarget) {
        _cats[i].unsettle(); // Wake up — no longer on cushion
      }
    }
    for (final t in levelData.targetPositions) {
      _board.setCatOnTarget(t, _gameState.catPositions.contains(t));
    }

    onMoveChanged?.call();
    return true;
  }

  /// Reset the level to initial state.
  void resetLevel() {
    _gameState = GameState.fromLevel(levelData);
    _undoManager.reset(undoLimit: levelData.undoLimit);

    _player.position.setFrom(Board.gridToPixel(_gameState.playerPosition));
    _player.facing = Direction.down;

    for (int i = 0; i < _cats.length; i++) {
      _cats[i].position.setFrom(Board.gridToPixel(_gameState.catPositions[i]));
      final onTarget = levelData.targetPositions.contains(levelData.catStarts[i]);
      _cats[i].isOnTarget = onTarget;
      if (!onTarget) _cats[i].unsettle();
    }
    for (final t in levelData.targetPositions) {
      _board.setCatOnTarget(t, _gameState.catPositions.contains(t));
    }

    _inputLocked = false;
    onMoveChanged?.call();
  }

  /// Add extra undos (from watching an ad).
  void addUndos(int count) {
    _undoManager.addUndos(count);
    onMoveChanged?.call();
  }
}
