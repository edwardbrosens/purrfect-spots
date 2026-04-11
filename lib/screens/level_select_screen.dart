import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/level_themes.dart';
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
  final Map<int, GlobalKey> _themeKeys = {};
  final ScrollController _scrollController = ScrollController();

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

  /// Find the next floor the player should play (lowest unlocked + uncompleted),
  /// falling back to the highest unlocked level if everything is done.
  LevelData? _continueLevel(ProgressProvider p) {
    LevelData? lastUnlocked;
    for (final lvl in _levels) {
      final unlocked = p.isLevelUnlocked(lvl.floor) || lvl.floor == 1;
      if (!unlocked) break;
      lastUnlocked = lvl;
      final prog = p.getLevelProgress(lvl.id);
      if (prog == null || !prog.completed) return lvl;
    }
    return lastUnlocked;
  }

@override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final continueLevel = _continueLevel(progressProvider);

    // Group levels by theme index (every 10 floors)
    final Map<int, List<LevelData>> grouped = {};
    for (final lvl in _levels) {
      final idx = ((lvl.floor - 1) ~/ 10).clamp(0, kLevelThemes.length - 1);
      grouped.putIfAbsent(idx, () => []).add(lvl);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: const Text('Select Floor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
      ),
      floatingActionButton: continueLevel == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Continue · Level ${continueLevel.floor}'),
              backgroundColor: CatCafeTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => context.go('/game/${continueLevel.id}'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _levels.isEmpty
              ? const Center(
                  child: Text('No levels found!',
                      style: TextStyle(fontSize: 18)))
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    for (final idx in sortedKeys) ...[
                      SliverToBoxAdapter(
                        key: _themeKeys.putIfAbsent(idx, () => GlobalKey()),
                        child: _ThemeHeader(
                          theme: kLevelThemes[idx],
                          levels: grouped[idx]!,
                          progress: progressProvider,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final level = grouped[idx]![i];
                              final progress =
                                  progressProvider.getLevelProgress(level.id);
                              final isUnlocked = progressProvider
                                      .isLevelUnlocked(level.floor) ||
                                  level.floor == 1;
                              return _LevelCard(
                                level: level,
                                progress: progress,
                                isUnlocked: isUnlocked,
                                accent: kLevelThemes[idx].color,
                                onTap: () {
                                  if (isUnlocked) {
                                    context.go('/game/${level.id}');
                                  }
                                },
                              );
                            },
                            childCount: grouped[idx]!.length,
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  final LevelTheme theme;
  final List<LevelData> levels;
  final ProgressProvider progress;
  const _ThemeHeader({
    required this.theme,
    required this.levels,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final completed =
        levels.where((l) => progress.getLevelProgress(l.id)?.completed ?? false).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.color.withValues(alpha: 0.85),
            theme.color.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(theme.icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Floors ${levels.first.floor}–${levels.last.floor}  ·  $completed/${levels.length} cleared',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final dynamic progress; // LevelProgress?
  final bool isUnlocked;
  final Color accent;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.accent,
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
                ? accent
                : isUnlocked
                    ? accent.withValues(alpha: 0.35)
                    : Colors.grey.shade300,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_rounded, size: 32, color: Colors.grey.shade400)
            else ...[
              Text(
                '${level.floor}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CatCafeTheme.darkText,
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
