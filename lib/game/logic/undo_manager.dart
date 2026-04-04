import 'game_state.dart';

/// Manages undo history with a limited number of undos.
class UndoManager {
  final List<GameState> _history = [];
  int _undosRemaining;

  UndoManager({required int undoLimit}) : _undosRemaining = undoLimit;

  int get undosRemaining => _undosRemaining;
  bool get canUndo => _history.isNotEmpty && _undosRemaining > 0;
  int get historyLength => _history.length;

  /// Push a state onto the undo stack (call before applying a move).
  void push(GameState state) {
    _history.add(state);
  }

  /// Undo the last move. Returns the previous state, or null if can't undo.
  GameState? undo() {
    if (!canUndo) return null;
    _undosRemaining--;
    return _history.removeLast();
  }

  /// Grant additional undos (e.g., from watching an ad).
  void addUndos(int count) {
    _undosRemaining += count;
  }

  /// Reset the undo manager (e.g., on level restart).
  void reset({required int undoLimit}) {
    _history.clear();
    _undosRemaining = undoLimit;
  }
}
