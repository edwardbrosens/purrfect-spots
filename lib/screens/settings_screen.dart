import 'package:flutter/material.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../services/purchase_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: Text(l.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _SectionHeader(title: l.account),
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
                        ? l.playingAsGuest
                        : (authProvider.profile?.authProvider.contains('apple') ?? false)
                            ? l.signedInWithApple
                            : (authProvider.profile?.authProvider == 'password')
                                ? l.signedInWithEmail
                                : l.signedInWithGoogle,
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
                          ? l.signInSignUp
                          : l.manageAccount),
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

          // Language section
          _SectionHeader(title: l.language),
          _LanguageCard(),

          const SizedBox(height: 16),

          // Premium section
          _SectionHeader(title: l.premium),
          _PremiumCard(isPremium: authProvider.isPremium),

          const SizedBox(height: 16),

          // Info
          _SectionHeader(title: l.about),
          Card(
            color: CatCafeTheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🐱', style: TextStyle(fontSize: 24)),
                  title: Text(l.appTitle),
                  subtitle: Text(l.version('1.0.0')),
                ),
                ListTile(
                  leading: const Text('🧩', style: TextStyle(fontSize: 24)),
                  title: Text(l.howToPlay),
                  subtitle: Text(l.howToPlayDescription),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Danger zone — reset personal progress
          _SectionHeader(title: l.dangerZone),
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
                        title: Text(l.resetAllProgressTitle),
                        content: Text(l.resetAllProgressMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(l.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: Text(l.resetEverything),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    if (!context.mounted) return;
                    await context.read<ProgressProvider>().resetAllProgress();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.progressReset),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red),
                  label: Text(l.resetAllProgress,
                      style: const TextStyle(color: Colors.red)),
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
              child: Column(
                children: [
                  Text(
                    '💡 ${l.tipTitle}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CatCafeTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.tipSignIn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: CatCafeTheme.darkText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  static final _languages = <(String?, String)>[
    (null, 'System'),
    ('en', 'English'),
    ('nl', 'Nederlands'),
    ('de', 'Deutsch'),
    ('fr', 'Français'),
    ('es', 'Español'),
    ('it', 'Italiano'),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.locale?.languageCode;

    return Card(
      color: CatCafeTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _languages.map((entry) {
          final (code, label) = entry;
          final isSelected = code == current;
          return ListTile(
            title: Text(label),
            trailing: isSelected
                ? const Icon(Icons.check_rounded, color: CatCafeTheme.primary)
                : null,
            onTap: () => localeProvider
                .setLocale(code != null ? Locale(code) : null),
          );
        }).toList(),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final bool isPremium;
  const _PremiumCard({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final purchaseService = context.watch<PurchaseService>();

    if (isPremium) {
      return Card(
        color: CatCafeTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
          title: Text(l.premiumActive,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(l.unlimitedUndosNoAds),
        ),
      );
    }

    return Card(
      color: CatCafeTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
            const SizedBox(height: 8),
            Text(
              l.purrfectPremium,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CatCafeTheme.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.unlimitedUndosNoAdsShort,
              style: TextStyle(
                color: CatCafeTheme.darkText.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.pricePerMonth(purchaseService.priceLabel),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CatCafeTheme.darkText,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: purchaseService.purchasePending
                    ? null
                    : () => purchaseService.buyPremium(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CatCafeTheme.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: purchaseService.purchasePending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l.subscribe,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => purchaseService.restorePurchases(),
              child: Text(
                l.restorePurchases,
                style: TextStyle(
                  color: CatCafeTheme.darkText.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
            if (purchaseService.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  purchaseService.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://edwardbrosens.github.io/purrfect-spots/')),
                  child: Text(
                    l.privacyPolicy,
                    style: TextStyle(
                      color: CatCafeTheme.darkText.withValues(alpha: 0.5),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '·',
                    style: TextStyle(
                      color: CatCafeTheme.darkText.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
                  child: Text(
                    l.termsOfUse,
                    style: TextStyle(
                      color: CatCafeTheme.darkText.withValues(alpha: 0.5),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
