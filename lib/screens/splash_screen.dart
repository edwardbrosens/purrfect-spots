import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/level_loader.dart';
import '../services/purchase_service.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _imageScale;
  late Animation<double> _titleSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _titleSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _imageScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await LevelLoader.loadAllLevels();

    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      try {
        await authProvider.initialize();
      } catch (e) {
        debugPrint('Auth init failed (Firebase not configured?): $e');
      }

      if (mounted) {
        final progressProvider = context.read<ProgressProvider>();
        await progressProvider.initialize(authProvider.uid);
      }

      // Initialize in-app purchases and wire to auth
      if (mounted) {
        final purchaseService = context.read<PurchaseService>();
        purchaseService.onPurchaseVerified = (_) {
          authProvider.activatePremium();
        };
        await purchaseService.initialize();
      }
    }

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
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.65;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final fade = _fadeIn.value;
          final slide = _titleSlide.value;
          final scale = _imageScale.value;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF0EC), // soft pink top
                  Color(0xFFFFF5EE), // warm cream
                  Color(0xFFFFF8E8), // pale yellow bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements (star, cup, paw)
                Positioned(
                  right: size.width * 0.08,
                  top: size.height * 0.32,
                  child: Opacity(
                    opacity: fade * 0.5,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.star_border_rounded,
                        size: 36,
                        color: CatCafeTheme.pinkAccent.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: size.width * 0.06,
                  bottom: size.height * 0.18,
                  child: Opacity(
                    opacity: fade * 0.4,
                    child: Icon(
                      Icons.coffee_rounded,
                      size: 32,
                      color: CatCafeTheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  right: size.width * 0.12,
                  bottom: size.height * 0.22,
                  child: Opacity(
                    opacity: fade * 0.35,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: Icon(
                        Icons.pets_rounded,
                        size: 28,
                        color: CatCafeTheme.pinkAccent.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title: "Purrfect" in pink, "Spots" in dark
                      Opacity(
                        opacity: fade,
                        child: Transform.translate(
                          offset: Offset(0, slide),
                          child: Column(
                            children: [
                              Text(
                                l.splashTitle1,
                                style: CatCafeTheme.display(
                                  fontSize: 52,
                                  color: CatCafeTheme.pinkAccent,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -8),
                                child: Text(
                                  l.splashTitle2,
                                  style: CatCafeTheme.display(
                                    fontSize: 52,
                                    color: CatCafeTheme.darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Circular cat image with white border and shadow
                      Opacity(
                        opacity: fade,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: imageSize + 12,
                            height: imageSize + 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: CatCafeTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/categories/latte_lounge.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: CatCafeTheme.primary.withValues(alpha: 0.2),
                                    child: const Icon(
                                      Icons.pets_rounded,
                                      size: 80,
                                      color: CatCafeTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.08),

                      // Subtitle and version
                      Opacity(
                        opacity: fade,
                        child: Column(
                          children: [
                            Text(
                              l.splashSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: CatCafeTheme.darkText.withValues(alpha: 0.55),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v1.0.4',
                              style: TextStyle(
                                fontSize: 12,
                                color: CatCafeTheme.darkText.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
