import 'package:flutter/material.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/level_themes.dart';
import '../models/level_data.dart';
import '../providers/progress_provider.dart';
import '../services/level_loader.dart';

class LevelSelectScreen extends StatefulWidget {
  final int categoryIndex;

  const LevelSelectScreen({super.key, required this.categoryIndex});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<LevelData> _levels = [];
  bool _isLoading = true;

  LevelTheme get _theme =>
      kLevelThemes[widget.categoryIndex.clamp(0, kLevelThemes.length - 1)];

  int get _firstFloor => widget.categoryIndex * 10 + 1;
  int get _lastFloor => widget.categoryIndex * 10 + 10;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final all = await LevelLoader.loadAllLevels();
    final filtered = all
        .where((l) => l.floor >= _firstFloor && l.floor <= _lastFloor)
        .toList()
      ..sort((a, b) => a.floor.compareTo(b.floor));
    setState(() {
      _levels = filtered;
      _isLoading = false;
    });
  }

  int _categoryStars(ProgressProvider progress) {
    int total = 0;
    for (final level in _levels) {
      final p = progress.getLevelProgress(level.id);
      if (p != null) total += p.stars;
    }
    return total;
  }

  int _completedCount(ProgressProvider progress) {
    int count = 0;
    for (final level in _levels) {
      final p = progress.getLevelProgress(level.id);
      if (p != null && p.completed) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final progress = context.watch<ProgressProvider>();
    final maxStars = _levels.length * 3;
    final earnedStars = _categoryStars(progress);
    final completed = _completedCount(progress);
    final progressPercent =
        _levels.isEmpty ? 0.0 : completed / _levels.length;

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Header bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: CatCafeTheme.darkText,
                          onPressed: () => context.go('/menu'),
                        ),
                        const Spacer(),
                        Text(
                          _theme.localizedName(l),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CatCafeTheme.darkText,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.pets_rounded,
                            size: 18, color: CatCafeTheme.star),
                        const SizedBox(width: 4),
                        Text(
                          '$earnedStars/$maxStars',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CatCafeTheme.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero image card
                          _HeroCard(
                            theme: _theme,
                            categoryIndex: widget.categoryIndex,
                            firstFloor: _firstFloor,
                            lastFloor: _lastFloor,
                          ),
                          const SizedBox(height: 16),

                          // Progress bar
                          _ProgressBar(
                            percent: progressPercent,
                          ),
                          const SizedBox(height: 20),

                          // Levels section header
                          Text(
                            l.levels,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CatCafeTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Level grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _levels.length,
                            itemBuilder: (context, index) {
                              final level = _levels[index];
                              final levelProgress =
                                  progress.getLevelProgress(level.id);
                              final isUnlocked =
                                  progress.isLevelUnlocked(level.floor) ||
                                      level.floor == 1;
                              final isCompleted =
                                  levelProgress?.completed ?? false;
                              final stars = levelProgress?.stars ?? 0;

                              return _LevelTile(
                                floor: level.floor,
                                isUnlocked: isUnlocked,
                                isCompleted: isCompleted,
                                stars: stars,
                                onTap: isUnlocked
                                    ? () => context.go('/game/${level.id}')
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom nav bar
                  _BottomNavBar(categoryIndex: widget.categoryIndex),
                ],
              ),
            ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final LevelTheme theme;
  final int categoryIndex;
  final int firstFloor;
  final int lastFloor;

  const _HeroCard({
    required this.theme,
    required this.categoryIndex,
    required this.firstFloor,
    required this.lastFloor,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final subtitle = categoryIndex == 0
        ? l.floorsRangeTutorial(firstFloor, lastFloor)
        : l.floorsRange(firstFloor, lastFloor);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              theme.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.color.withValues(alpha: 0.8),
                      theme.color.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(theme.icon, size: 64, color: Colors.white),
                ),
              ),
            ),
            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      theme.localizedName(l),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;

  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final displayPercent = (percent * 100).round();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.progress,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CatCafeTheme.darkText,
              ),
            ),
            Text(
              '$displayPercent%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CatCafeTheme.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: CatCafeTheme.lockedTile,
            valueColor:
                const AlwaysStoppedAnimation<Color>(CatCafeTheme.primary),
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int floor;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.floor,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    if (isCompleted) {
      bgColor = CatCafeTheme.pinkAccent;
    } else if (isUnlocked) {
      bgColor = Colors.white;
    } else {
      bgColor = CatCafeTheme.lockedTile;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_rounded, size: 28, color: Colors.grey.shade400)
            else ...[
              Text(
                '$floor',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      isCompleted ? Colors.white : CatCafeTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              _StarDots(stars: stars, isCompleted: isCompleted),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarDots extends StatelessWidget {
  final int stars;
  final bool isCompleted;

  const _StarDots({required this.stars, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? CatCafeTheme.star : Colors.transparent,
              border: filled
                  ? null
                  : Border.all(
                      color: isCompleted
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFFD4C5B2),
                      width: 1,
                    ),
            ),
          ),
        );
      }),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int categoryIndex;

  const _BottomNavBar({required this.categoryIndex});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: CatCafeTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.play_arrow_rounded,
                label: l.play,
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.pets_rounded,
                label: l.cats,
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.store_rounded,
                label: l.shop,
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: l.settings,
                isActive: false,
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? CatCafeTheme.primary : CatCafeTheme.darkText.withValues(alpha: 0.4);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
