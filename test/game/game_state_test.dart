import 'package:flutter_test/flutter_test.dart';
import 'package:purrfect_spots/models/level_data.dart';
import 'package:purrfect_spots/game/logic/game_state.dart';
import 'package:purrfect_spots/game/logic/move_executor.dart';
import 'package:purrfect_spots/game/logic/undo_manager.dart';

LevelData _createTestLevel(List<String> grid) {
  return LevelData.fromJson({
    'id': 'test',
    'name': 'Test',
    'floor': 1,
    'starThresholds': [30, 20, 10],
    'undoLimit': 3,
    'grid': grid,
  });
}

void main() {
  group('GameState', () {
    test('creates initial state from level', () {
      final level = _createTestLevel([
        '#####',
        '#P.T#',
        '#.C.#',
        '#...#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);

      expect(state.playerPosition, const Position(1, 1));
      expect(state.catPositions, [const Position(2, 2)]);
      expect(state.targetPositions, [const Position(1, 3)]);
      expect(state.moveCount, 0);
      expect(state.isComplete, false);
    });

    test('detects completion when all cats on targets', () {
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#.X.#',
        '#...#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      expect(state.isComplete, true);
    });

    test('wall detection works', () {
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#.C.#',
        '#..T#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      expect(state.isWall(const Position(0, 0)), true);
      expect(state.isWall(const Position(1, 1)), false);
      expect(state.isWall(const Position(-1, 0)), true); // out of bounds
    });
  });

  group('MoveExecutor', () {
    test('moves player to empty space', () {
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#...#',
        '#..T#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.right);

      expect(result.valid, true);
      expect(result.newState.playerPosition, const Position(1, 2));
      expect(result.newState.moveCount, 1);
      expect(result.pushedCatIndex, null);
    });

    test('blocks movement into wall', () {
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#...#',
        '#..T#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.up);

      expect(result.valid, false);
      expect(result.newState.playerPosition, const Position(1, 1));
      expect(result.newState.moveCount, 0);
    });

    test('pushes cat to empty space', () {
      final level = _createTestLevel([
        '#####',
        '#PC.#',
        '#..T#',
        '#...#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.right);

      expect(result.valid, true);
      expect(result.newState.playerPosition, const Position(1, 2));
      expect(result.newState.catPositions[0], const Position(1, 3));
      expect(result.pushedCatIndex, 0);
    });

    test('blocks push into wall', () {
      final level = _createTestLevel([
        '#####',
        '#.PC#',
        '#..T#',
        '#...#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.right);

      expect(result.valid, false);
    });

    test('blocks push into another cat', () {
      final level = _createTestLevel([
        '######',
        '#PCC.#',
        '#..TT#',
        '######',
      ]);

      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.right);

      expect(result.valid, false);
    });

    test('detects win after pushing cat to target', () {
      // Simple: push cat right onto target
      // Row 0: #####
      // Row 1: #PCT#  - player(1,1), cat(1,2), target(1,3)
      // Row 2: #...#
      // Row 3: #####
      final level = _createTestLevel([
        '#####',
        '#PCT#',
        '#...#',
        '#####',
      ]);
      final state = GameState.fromLevel(level);
      final result = MoveExecutor.execute(state, Direction.right);

      expect(result.valid, true);
      expect(result.newState.playerPosition, const Position(1, 2));
      expect(result.newState.catPositions[0], const Position(1, 3));
      expect(result.newState.isComplete, true);
    });
  });

  group('UndoManager', () {
    test('can undo within limit', () {
      final manager = UndoManager(undoLimit: 3);
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#...#',
        '#..T#',
        '#####',
      ]);

      final state1 = GameState.fromLevel(level);
      manager.push(state1);

      expect(manager.canUndo, true);
      final undone = manager.undo();
      expect(undone, isNotNull);
      expect(undone!.playerPosition, state1.playerPosition);
      expect(manager.undosRemaining, 2);
    });

    test('cannot undo past limit', () {
      final manager = UndoManager(undoLimit: 1);
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#...#',
        '#..T#',
        '#####',
      ]);

      final state = GameState.fromLevel(level);
      manager.push(state);
      manager.push(state);

      // First undo should work
      expect(manager.undo(), isNotNull);
      // Second should fail (limit reached)
      expect(manager.canUndo, false);
      expect(manager.undo(), null);
    });

    test('addUndos grants more', () {
      final manager = UndoManager(undoLimit: 0);
      expect(manager.canUndo, false);

      manager.addUndos(3);
      expect(manager.undosRemaining, 3);
    });

    test('reset clears history', () {
      final manager = UndoManager(undoLimit: 3);
      final level = _createTestLevel([
        '#####',
        '#P..#',
        '#...#',
        '#..T#',
        '#####',
      ]);

      manager.push(GameState.fromLevel(level));
      manager.push(GameState.fromLevel(level));

      manager.reset();
      expect(manager.historyLength, 0);
      // Undos are global — reset only clears history, not the count
      expect(manager.undosRemaining, 3);
    });
  });

  group('LevelData', () {
    test('parses JSON correctly', () {
      final level = _createTestLevel([
        '#####',
        '#P.T#',
        '#.C.#',
        '#...#',
        '#####',
      ]);

      expect(level.width, 5);
      expect(level.height, 5);
      expect(level.playerStart, const Position(1, 1));
      expect(level.catStarts.length, 1);
      expect(level.targetPositions.length, 1);
    });

    test('calculates stars correctly', () {
      final level = _createTestLevel([
        '####',
        '#PT#',
        '####',
      ]);

      expect(level.starsForMoves(5), 3); // under threshold[2]=10
      expect(level.starsForMoves(15), 2); // under threshold[1]=20
      expect(level.starsForMoves(25), 1); // under threshold[0]=30
      expect(level.starsForMoves(50), 1); // over all thresholds
    });

    test('parses X as cat on target', () {
      final level = _createTestLevel([
        '####',
        '#PX#',
        '####',
      ]);

      expect(level.catStarts.length, 1);
      expect(level.targetPositions.length, 1);
      expect(level.catStarts[0], level.targetPositions[0]);
    });
  });
}
