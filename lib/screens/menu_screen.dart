import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/level_themes.dart';
import '../models/level_data.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/level_loader.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<LevelData> _levels = [];
  bool _isLoading = true;
  int _currentTab = 0;

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

  Map<int, List<LevelData>> _groupedByTheme() {
    final Map<int, List<LevelData>> grouped = {};
    for (final lvl in _levels) {
      final idx = ((lvl.floor - 1) ~/ 10).clamp(0, kLevelThemes.length - 1);
      grouped.putIfAbsent(idx, () => []).add(lvl);
    }
    return grouped;
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      setState(() => _currentTab = 0);
      return;
    }
    if (index == 3) {
      context.go('/settings');
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Coming soon!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final continueLevel = _isLoading ? null : _continueLevel(progressProvider);
    final grouped = _groupedByTheme();
    final sortedKeys = grouped.keys.toList()..sort();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit Purrfect Spots?'),
            content: const Text('Are you sure you want to leave the caf\u00e9?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: CatCafeTheme.background,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: CatCafeTheme.primary,
          unselectedItemColor: CatCafeTheme.darkText.withValues(alpha: 0.4),
          backgroundColor: CatCafeTheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets_rounded),
              label: 'Cats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Header with title and star count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.pets_rounded,
                                    size: 24,
                                    color: CatCafeTheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Purrfect Spots',
                                    style: CatCafeTheme.display(fontSize: 28),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: CatCafeTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFEDE0D8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.pets_rounded,
                                    size: 16,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${progressProvider.totalStars}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Hero continue card
                    if (continueLevel != null)
                      SliverToBoxAdapter(
                        child: _HeroContinueCard(
                          level: continueLevel,
                          onTap: () =>
                              context.go('/game/${continueLevel.id}'),
                        ),
                      ),

                    // Section title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          'Caf\u00e9 Areas',
                          style: CatCafeTheme.display(fontSize: 20),
                        ),
                      ),
                    ),

                    // Category list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final themeIdx = sortedKeys[index];
                            final theme = kLevelThemes[themeIdx];
                            final levels = grouped[themeIdx]!;
                            final completed = levels
                                .where((l) =>
                                    progressProvider
                                        .getLevelProgress(l.id)
                                        ?.completed ??
                                    false)
                                .length;

                            return _CategoryRow(
                              theme: theme,
                              completedCount: completed,
                              totalCount: levels.length,
                              onTap: () => context.go('/levels/$themeIdx'),
                            );
                          },
                          childCount: sortedKeys.length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroContinueCard extends StatelessWidget {
  final LevelData level;
  final VoidCallback onTap;

  const _HeroContinueCard({
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeForFloor(level.floor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: CatCafeTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE0D8)),
            boxShadow: [
              BoxShadow(
                color: CatCafeTheme.shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      theme.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: theme.color.withValues(alpha: 0.3),
                        child: Icon(
                          theme.icon,
                          size: 48,
                          color: theme.color,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            theme.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Level ${level.floor}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: CatCafeTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Continue',
                              style: CatCafeTheme.display(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final LevelTheme theme;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.theme,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CatCafeTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDE0D8)),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    theme.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: theme.color.withValues(alpha: 0.2),
                      child: Icon(theme.icon, color: theme.color, size: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: CatCafeTheme.display(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completedCount/$totalCount cleared',
                      style: TextStyle(
                        fontSize: 13,
                        color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                theme.icon,
                size: 22,
                color: theme.color,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: CatCafeTheme.darkText.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
