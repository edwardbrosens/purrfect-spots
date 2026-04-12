import 'game_state.dart';

/// Manages undo history with a limited number of undos.
class UndoManager {
  final List<GameState> _history = [];
  int _undosRemaining;
  bool unlimited;

  UndoManager({
    required int undoLimit,
    int? initialRemaining,
    this.unlimited = false,
  }) : _undosRemaining = initialRemaining ?? undoLimit;

  int get undosRemaining => _undosRemaining;
  bool get canUndo => _history.isNotEmpty && (unlimited || _undosRemaining > 0);
  int get historyLength => _history.length;

  /// Push a state onto the undo stack (call before applying a move).
  void push(GameState state) {
    _history.add(state);
  }

  /// Undo the last move. Returns the previous state, or null if can't undo.
  GameState? undo() {
    if (!canUndo) return null;
    if (!unlimited) _undosRemaining--;
    return _history.removeLast();
  }

  /// Grant additional undos (e.g., from watching an ad).
  void addUndos(int count) {
    _undosRemaining += count;
  }

  /// Reset the undo history (e.g., on level restart).
  /// Undos are global — do NOT reset the remaining count.
  void reset() {
    _history.clear();
  }
}
