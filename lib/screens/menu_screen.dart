import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  '🐱',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 12),
                Text(
                  'Purrfect Spots',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 36,
                        color: CatCafeTheme.darkText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guide the cats to their cushions!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                      ),
                ),

                const SizedBox(height: 48),

                // Stats summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CatCafeTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CatCafeTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: '⭐',
                        value: '${progressProvider.totalStars}',
                        label: 'Stars',
                      ),
                      _StatItem(
                        icon: '✅',
                        value: '${progressProvider.levelsCompleted}',
                        label: 'Cleared',
                      ),
                      _StatItem(
                        icon: '👤',
                        value: authProvider.isAnonymous ? 'Guest' : 'Signed In',
                        label: 'Account',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Menu buttons
                _MenuButton(
                  label: 'Play',
                  icon: Icons.play_arrow_rounded,
                  color: CatCafeTheme.primary,
                  onTap: () => context.go('/levels'),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: 'Leaderboard',
                  icon: Icons.leaderboard_rounded,
                  color: CatCafeTheme.secondary,
                  onTap: () => context.go('/leaderboard'),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: 'Settings',
                  icon: Icons.settings_rounded,
                  color: CatCafeTheme.accent,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: CatCafeTheme.darkText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CatCafeTheme.darkText.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: CatCafeTheme.darkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
