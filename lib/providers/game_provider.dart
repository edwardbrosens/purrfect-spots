import 'package:flutter/foundation.dart';
import '../game/cat_cafe_game.dart';

/// Bridges CatCafeGame state to Flutter widgets (HUD, overlays).
class GameProvider extends ChangeNotifier {
  CatCafeGame? _game;

  CatCafeGame? get game => _game;
  int get moveCount => _game?.moveCount ?? 0;
  int get undosRemaining => _game?.undosRemaining ?? 0;
  bool get canUndo => _game?.canUndo ?? false;
  bool get isComplete => _game?.isComplete ?? false;

  void setGame(CatCafeGame game) {
    _game = game;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void handleUndo() {
    _game?.undo();
    notifyListeners();
  }

  void resetLevel() {
    _game?.resetLevel();
    notifyListeners();
  }

  void addUndos(int count) {
    _game?.addUndos(count);
    notifyListeners();
  }
}
