import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

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
                if (authProvider.isAnonymous)
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => authProvider.signInWithGoogle(),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CatCafeTheme.secondary,
                          foregroundColor: CatCafeTheme.darkText,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => authProvider.signOut(),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out'),
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
