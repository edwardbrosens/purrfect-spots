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
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
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
  int _undosAtStart = 0; // track undos at level start for undosUsed calc

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _initAdsIfNeeded() async {
    if (_adService != null) return;
    try {
      final appConfig = context.read<AppConfig>();
      final authProvider = context.read<AuthProvider>();
      if (appConfig.adsEnabled && authProvider.showAds) {
        _adService = AdService();
        await _adService!.initialize();
      }
    } catch (_) {
      // AppConfig not available — ads stay disabled
    }
  }

  Future<void> _loadLevel() async {
    final level = await LevelLoader.loadLevel(widget.levelId);
    if (!mounted) return;

    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AuthProvider>();
    await _initAdsIfNeeded();
    _undosAtStart = authProvider.undosRemaining;

    final game = CatCafeGame(
      levelData: level,
      initialUndosRemaining: authProvider.undosRemaining,
      unlimitedUndos: authProvider.isPremium,
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
    final undosUsed = (_undosAtStart - _game!.undosRemaining).clamp(0, 999);

    // Persist global undo count to user profile
    authProvider.setUndosRemaining(_game!.undosRemaining);

    progressProvider.saveLevelComplete(
      levelId: _levelData!.id,
      moves: moves,
      stars: stars,
      undosUsed: undosUsed,
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

    // Track undos at start of new attempt (undos carry over, they're global)
    _undosAtStart = _game!.undosRemaining;

    gameProvider.resetLevel();
    setState(() => _showResult = false);
  }

  Future<void> _onRequestUndos() async {
    void grantUndos() {
      if (!mounted) return;
      final gameProvider = context.read<GameProvider>();
      gameProvider.addUndos(GameConstants.undosPerAd);
      _persistUndos();
    }

    if (_adService != null) {
      // Wait briefly for the ad to load if not ready yet
      if (!_adService!.isRewardedReady) {
        _adService!.loadRewarded();
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.loadingAd),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        for (int i = 0; i < 8; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (_adService!.isRewardedReady) break;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }

      if (_adService!.isRewardedReady) {
        final earned = await _adService!.showRewarded();
        if (earned) grantUndos();
        return;
      }
    }

    // No ad service or ad still not available — grant for free
    grantUndos();
    if (mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.plusUndosGranted(GameConstants.undosPerAd)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _persistUndos() {
    if (_game == null) return;
    context.read<AuthProvider>().setUndosRemaining(_game!.undosRemaining);
  }

  Future<void> _showUndoPrompt() async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.outOfUndos),
        content: Text(
          l.watchAdForUndos(GameConstants.undosPerAd),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.noThanks),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.getUndos(GameConstants.undosPerAd)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await _onRequestUndos();
    }
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
        final l = AppLocalizations.of(navContext)!;
        final shouldLeave = await showDialog<bool>(
          context: navContext,
          builder: (ctx) => AlertDialog(
            title: Text(l.leaveLevel),
            content: Text(l.leaveLevelMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.keepPlaying),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.leave),
              ),
            ],
          ),
        );
        if (shouldLeave == true && navContext.mounted) {
          _persistUndos();
          navContext.go('/levels/${((_levelData!.floor - 1) ~/ 10).clamp(0, 9)}');
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

            // HUD overlay (top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HudOverlay(
                levelName: _levelData!.name,
                floorNumber: _levelData!.floor,
                categoryName: themeForFloor(_levelData!.floor).localizedName(AppLocalizations.of(context)!),
                onBack: () => context.go('/levels/${((_levelData!.floor - 1) ~/ 10).clamp(0, 9)}'),
              ),
            ),

            // Bottom action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GameBottomBar(
                onReset: _onReset,
                onUndo: () {
                  final gameProvider = context.read<GameProvider>();
                  if (gameProvider.canUndo) {
                    gameProvider.handleUndo();
                    _persistUndos();
                  }
                },
                onRequestUndos: _onRequestUndos,
                onUndoNoCredits: _showUndoPrompt,
                isPremium: context.read<AuthProvider>().isPremium,
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
                onLevelSelect: () => context.go('/levels/${((_levelData!.floor - 1) ~/ 10).clamp(0, 9)}'),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
