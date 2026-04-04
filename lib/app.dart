import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/progress_provider.dart';

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
      ],
      child: MaterialApp.router(
        title: 'Purrfect Spots',
        theme: CatCafeTheme.themeData,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
