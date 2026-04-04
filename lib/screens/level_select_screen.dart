import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/level_data.dart';
import '../providers/progress_provider.dart';
import '../services/level_loader.dart';
import '../widgets/star_rating.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<LevelData> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final levels = await LevelLoader.loadAllLevels();
    setState(() {
      _levels = levels;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: const Text('Select Floor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _levels.isEmpty
              ? const Center(
                  child: Text('No levels found!',
                      style: TextStyle(fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final progress =
                          progressProvider.getLevelProgress(level.id);
                      final isUnlocked =
                          progressProvider.isLevelUnlocked(level.floor);

                      return _LevelCard(
                        level: level,
                        progress: progress,
                        isUnlocked: isUnlocked || index == 0,
                        onTap: () {
                          if (isUnlocked || index == 0) {
                            context.go('/game/${level.id}');
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final dynamic progress; // LevelProgress?
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.completed ?? false;
    final stars = progress?.stars ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked ? CatCafeTheme.surface : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? CatCafeTheme.secondary
                : isUnlocked
                    ? CatCafeTheme.primary.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: CatCafeTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floor number / lock icon
            if (!isUnlocked)
              Icon(Icons.lock_rounded,
                  size: 32, color: Colors.grey.shade400)
            else ...[
              Text(
                '${level.floor}F',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? CatCafeTheme.darkText
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                level.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: CatCafeTheme.darkText.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Star rating
              StarRating(stars: stars, size: 18),
              if (isCompleted && progress?.bestMoves != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${progress.bestMoves} moves',
                    style: TextStyle(
                      fontSize: 11,
                      color: CatCafeTheme.darkText.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
