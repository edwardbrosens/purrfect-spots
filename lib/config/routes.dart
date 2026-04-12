import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/game_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/account_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
    GoRoute(
      path: '/levels/:categoryIndex',
      builder: (context, state) {
        final categoryIndex =
            int.tryParse(state.pathParameters['categoryIndex'] ?? '0') ?? 0;
        return LevelSelectScreen(
            key: ValueKey('levels_$categoryIndex'),
            categoryIndex: categoryIndex);
      },
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) =>
          const LevelSelectScreen(key: ValueKey('levels_0'), categoryIndex: 0),
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = state.pathParameters['levelId']!;
        return GameScreen(key: ValueKey(levelId), levelId: levelId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountScreen(),
    ),
  ],
);
