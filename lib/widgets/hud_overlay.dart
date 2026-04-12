import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/game_provider.dart';

class HudOverlay extends StatelessWidget {
  final String levelName;
  final int floorNumber;
  final String categoryName;
  final VoidCallback onBack;

  const HudOverlay({
    super.key,
    required this.levelName,
    required this.floorNumber,
    required this.categoryName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CatCafeTheme.background.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Back | Title | Settings
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                color: CatCafeTheme.darkText,
                tooltip: 'Back',
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CatCafeTheme.darkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Level $floorNumber',
                      style: TextStyle(
                        fontSize: 12,
                        color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // balance the back button
            ],
          ),

          // Moves count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              'MOVES  ${gameProvider.moveCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CatCafeTheme.darkText.withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Hint text when no moves yet
          if (gameProvider.moveCount == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Swipe to move and push cats',
                style: TextStyle(
                  fontSize: 11,
                  color: CatCafeTheme.darkText.withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GameBottomBar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onUndo;
  final VoidCallback onRequestUndos;
  final VoidCallback? onUndoNoCredits;
  final bool isPremium;

  const GameBottomBar({
    super.key,
    required this.onReset,
    required this.onUndo,
    required this.onRequestUndos,
    this.onUndoNoCredits,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final outlineColor = CatCafeTheme.darkText.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: CatCafeTheme.background.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          _BottomBarAction(
            onTap: onReset,
            icon: Icons.refresh_rounded,
            label: 'Reset',
            outlineColor: outlineColor,
          ),

          // Undo button (large, coral pink)
          _UndoButton(
            onTap: gameProvider.canUndo
                ? onUndo
                : (gameProvider.undosRemaining == 0 && gameProvider.moveCount > 0)
                    ? onUndoNoCredits
                    : null,
            undosRemaining: gameProvider.undosRemaining,
            isPremium: isPremium,
          ),

          // +10 Undos button (hidden for premium)
          if (!isPremium)
            _BottomBarAction(
              onTap: onRequestUndos,
              icon: Icons.add_circle_outline_rounded,
              label: '+10 Undos',
              outlineColor: outlineColor,
            ),
          if (isPremium)
            const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _BottomBarAction extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color outlineColor;

  const _BottomBarAction({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outlineColor, width: 1.5),
            ),
            child: Icon(icon, size: 22, color: CatCafeTheme.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: CatCafeTheme.darkText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  final VoidCallback? onTap;
  final int undosRemaining;
  final bool isPremium;

  const _UndoButton({
    required this.onTap,
    required this.undosRemaining,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: CatCafeTheme.pinkAccent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CatCafeTheme.pinkAccent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.undo_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              // Badge with remaining count
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  decoration: BoxDecoration(
                    color: undosRemaining > 0
                        ? CatCafeTheme.secondary
                        : CatCafeTheme.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CatCafeTheme.background,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    isPremium ? '\u221E' : '$undosRemaining',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPremium ? 14 : 10,
                      fontWeight: FontWeight.bold,
                      color: CatCafeTheme.darkText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Undo',
            style: TextStyle(
              fontSize: 11,
              color: CatCafeTheme.darkText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
