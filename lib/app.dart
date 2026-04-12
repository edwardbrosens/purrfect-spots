import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/progress_provider.dart';
import 'services/purchase_service.dart';

/// Simple config object provided to the widget tree.
class AppConfig {
  final bool adsEnabled;
  const AppConfig({this.adsEnabled = false});
}

class CatCafeApp extends StatelessWidget {
  final bool firebaseReady;
  final bool adsEnabled;

  const CatCafeApp({
    super.key,
    this.firebaseReady = true,
    this.adsEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: AppConfig(adsEnabled: adsEnabled)),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(firebaseReady: firebaseReady)),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(
            create: (_) => ProgressProvider(firebaseReady: firebaseReady)),
        ChangeNotifierProvider(create: (_) => PurchaseService()),
      ],
      child: MaterialApp.router(
        title: 'Purrfect Spots',
        theme: CatCafeTheme.themeData,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => _ExitGuard(child: child ?? const SizedBox()),
      ),
    );
  }
}

/// Intercepts root-level back gestures (Android back button / iOS edge-swipe)
/// so the app doesn't quit by accident. If go_router can pop, it pops; otherwise
/// the user is asked to confirm exit.
class _ExitGuard extends StatelessWidget {
  final Widget child;
  const _ExitGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
        final l = AppLocalizations.of(context)!;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.exitTitle),
            content: Text(l.exitMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.stay),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.exit),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          // Pop the root system route to background the app.
          await SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
