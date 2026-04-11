import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../game/cat_cafe_game.dart';
import '../game/input/swipe_detector.dart';
import '../models/level_data.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../app.dart';
import '../services/ad_service.dart';
import '../services/level_loader.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/category_complete_overlay.dart';
import '../config/level_themes.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  CatCafeGame? _game;
  LevelData? _levelData;
  final SwipeDetector _swipeDetector = SwipeDetector();
  AdService? _adService;
  bool _showResult = false;
  bool _showCategoryComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize ads once when dependencies are available
    if (_adService == null) {
      try {
        final appConfig = context.read<AppConfig>();
        if (appConfig.adsEnabled) {
          _adService = AdService()..initialize();
        }
      } catch (_) {
        // AppConfig not available — ads stay disabled
      }
    }
  }

  Future<void> _loadLevel() async {
    final level = await LevelLoader.loadLevel(widget.levelId);
    if (!mounted) return;

    final gameProvider = context.read<GameProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final storedRemaining =
        progressProvider.getLevelProgress(level.id)?.undosRemaining;

    final game = CatCafeGame(
      levelData: level,
      initialUndosRemaining: storedRemaining,
      onLevelComplete: _onLevelComplete,
      onMoveChanged: () {
        if (mounted) {
          gameProvider.refresh();
        }
      },
    );

    gameProvider.setGame(game);

    setState(() {
      _levelData = level;
      _game = game;
      _isLoading = false;
    });
  }

  void _onLevelComplete() {
    if (!mounted || _levelData == null || _game == null) return;

    final authProvider = context.read<AuthProvider>();
    final progressProvider = context.read<ProgressProvider>();

    final moves = _game!.moveCount;
    final stars = _levelData!.starsForMoves(moves);
    final undosUsed = _levelData!.undoLimit - _game!.undosRemaining;

    progressProvider.saveLevelComplete(
      levelId: _levelData!.id,
      moves: moves,
      stars: stars,
      undosUsed: undosUsed,
      undosRemaining: _game!.undosRemaining,
      displayName: authProvider.displayName,
    );

    // Wait a moment so the player can see the last cat settle
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final isCategoryFinale = _levelData!.floor % 10 == 0;
      void showNext() {
        if (!mounted) return;
        if (isCategoryFinale) {
          setState(() => _showCategoryComplete = true);
        } else {
          setState(() => _showResult = true);
        }
      }
      if (_adService != null) {
        _adService!.showInterstitial().then((_) => showNext());
      } else {
        showNext();
      }
    });
  }

  void _onReset() {
    final gameProvider = context.read<GameProvider>();

    // Show interstitial ad on reset (if enabled)
    _adService?.showInterstitial();

    gameProvider.resetLevel();
    setState(() => _showResult = false);
  }

  Future<void> _onRequestUndos() async {
    if (_adService != null) {
      final earned = await _adService!.showRewarded();
      if (earned && mounted) {
        final gameProvider = context.read<GameProvider>();
        gameProvider.addUndos(GameConstants.undosPerAd);
        _persistUndos();
      }
    } else {
      // Ads disabled — grant undos for free during development
      if (mounted) {
        final gameProvider = context.read<GameProvider>();
        gameProvider.addUndos(GameConstants.undosPerAd);
        _persistUndos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+3 undos (ads disabled)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _persistUndos() {
    if (_levelData == null || _game == null) return;
    context
        .read<ProgressProvider>()
        .saveUndosRemaining(_levelData!.id, _game!.undosRemaining);
  }

  @override
  void dispose() {
    _adService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _game == null) {
      return Scaffold(
        backgroundColor: CatCafeTheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navContext = context;
        final shouldLeave = await showDialog<bool>(
          context: navContext,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave level?'),
            content: const Text('Your progress on this level will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Keep playing'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        if (shouldLeave == true && navContext.mounted) {
          _persistUndos();
          navContext.go('/levels');
        }
      },
      child: Scaffold(
      backgroundColor: CatCafeTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Game with swipe detection
            GestureDetector(
              onPanStart: _swipeDetector.onDragStart,
              onPanUpdate: (details) {
                final direction = _swipeDetector.onDragUpdate(details);
                if (direction != null) {
                  _game!.handleMove(direction);
                }
              },
              onPanEnd: _swipeDetector.onDragEnd,
              child: GameWidget(game: _game!),
            ),

            // HUD overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HudOverlay(
                levelName: _levelData!.name,
                floorNumber: _levelData!.floor,
                onBack: () => context.go('/levels'),
                onReset: _onReset,
                onUndo: () {
                  final gameProvider = context.read<GameProvider>();
                  if (gameProvider.canUndo) {
                    gameProvider.handleUndo();
                  } else {
                    _onRequestUndos();
                  }
                },
                onRequestUndos: _onRequestUndos,
              ),
            ),

            // Category-complete full-screen celebration
            if (_showCategoryComplete)
              CategoryCompleteOverlay(
                theme: themeForFloor(_levelData!.floor),
                floor: _levelData!.floor,
                onDismiss: () => setState(() {
                  _showCategoryComplete = false;
                  _showResult = true;
                }),
              ),

            // Result overlay
            if (_showResult)
              ResultScreen(
                levelData: _levelData!,
                moves: _game!.moveCount,
                stars: _levelData!.starsForMoves(_game!.moveCount),
                onNextLevel: () {
                  final nextFloor = _levelData!.floor + 1;
                  final nextId =
                      'floor_${nextFloor.toString().padLeft(2, '0')}';
                  context.go('/game/$nextId');
                },
                onRetry: _onReset,
                onLevelSelect: () => context.go('/levels'),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
