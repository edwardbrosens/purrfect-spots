import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _SectionHeader(title: 'Account'),
          Card(
            color: CatCafeTheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: CatCafeTheme.primary,
                    backgroundImage: authProvider.profile?.avatarUrl != null
                        ? NetworkImage(authProvider.profile!.avatarUrl!)
                        : null,
                    child: authProvider.profile?.avatarUrl == null
                        ? const Icon(Icons.person,
                            color: CatCafeTheme.darkText)
                        : null,
                  ),
                  title: Text(authProvider.displayName),
                  subtitle: Text(
                    authProvider.isAnonymous
                        ? 'Playing as guest'
                        : 'Signed in with Google',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/account'),
                      icon: Icon(authProvider.isAnonymous
                          ? Icons.login_rounded
                          : Icons.manage_accounts_rounded),
                      label: Text(authProvider.isAnonymous
                          ? 'Sign in / Sign up'
                          : 'Manage account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CatCafeTheme.secondary,
                        foregroundColor: CatCafeTheme.darkText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info
          _SectionHeader(title: 'About'),
          Card(
            color: CatCafeTheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Text('🐱', style: TextStyle(fontSize: 24)),
                  title: Text('Purrfect Spots'),
                  subtitle: Text('Version 1.0.0'),
                ),
                ListTile(
                  leading: Text('🧩', style: TextStyle(fontSize: 24)),
                  title: Text('How to Play'),
                  subtitle: Text(
                    'Swipe to move. Push cats onto their cushions. '
                    'Use as few moves as possible for more stars!',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Danger zone — reset personal progress
          _SectionHeader(title: 'Danger zone'),
          Card(
            color: CatCafeTheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset all progress?'),
                        content: const Text(
                          'This will permanently delete your stars, best '
                          'moves, undos, and every completed level on this '
                          'account. This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Reset everything'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    if (!context.mounted) return;
                    await context.read<ProgressProvider>().resetAllProgress();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progress reset.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red),
                  label: const Text('Reset all progress',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sign in prompt for anonymous users
          if (authProvider.isAnonymous)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CatCafeTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CatCafeTheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '💡 Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CatCafeTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sign in with Google to save your progress '
                    'across devices and appear on leaderboards!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CatCafeTheme.darkText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CatCafeTheme.darkText.withValues(alpha: 0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
