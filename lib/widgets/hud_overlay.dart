import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/game_provider.dart';

class HudOverlay extends StatelessWidget {
  final String levelName;
  final int floorNumber;
  final VoidCallback onBack;
  final VoidCallback onReset;
  final VoidCallback onUndo;
  final VoidCallback onRequestUndos;

  const HudOverlay({
    super.key,
    required this.levelName,
    required this.floorNumber,
    required this.onBack,
    required this.onReset,
    required this.onUndo,
    required this.onRequestUndos,
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
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 24),
            color: CatCafeTheme.darkText,
            tooltip: 'Back',
          ),

          // Level info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level $floorNumber - $levelName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CatCafeTheme.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Moves: ${gameProvider.moveCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Undo button with count
          Stack(
            children: [
              IconButton(
                onPressed: gameProvider.canUndo ? onUndo : onRequestUndos,
                icon: Icon(
                  Icons.undo_rounded,
                  size: 24,
                  color: gameProvider.canUndo
                      ? CatCafeTheme.darkText
                      : CatCafeTheme.darkText.withValues(alpha: 0.3),
                ),
                tooltip: gameProvider.canUndo
                    ? 'Undo'
                    : 'Watch ad for more undos',
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: gameProvider.undosRemaining > 0
                        ? CatCafeTheme.secondary
                        : CatCafeTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${gameProvider.undosRemaining}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: CatCafeTheme.darkText,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Reset button
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 24),
            color: CatCafeTheme.darkText,
            tooltip: 'Reset Level',
          ),
        ],
      ),
    );
  }
}
