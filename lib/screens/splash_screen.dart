import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/level_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _bounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.7, curve: Curves.elasticOut)),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Preload levels
    await LevelLoader.loadAllLevels();

    // Initialize auth (gracefully handle if Firebase isn't configured)
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      try {
        await authProvider.initialize();
      } catch (e) {
        debugPrint('Auth init failed (Firebase not configured?): $e');
      }

      // Load progress
      if (mounted) {
        final progressProvider = context.read<ProgressProvider>();
        await progressProvider.initialize(authProvider.uid);
      }
    }

    // Wait for animation to finish
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      context.go('/menu');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: 0.5 + _bounce.value * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cat face icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: CatCafeTheme.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: CatCafeTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🐱',
                          style: TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Purrfect Spots',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            color: CatCafeTheme.darkText,
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Cat Café Puzzle',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
