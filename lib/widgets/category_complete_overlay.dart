import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
import '../config/level_themes.dart';
import '../config/theme.dart';

/// Full-screen celebration overlay shown after clearing the final level of
/// a category (floor % 10 == 0). A happy cat curls up on a themed cushion
/// and winks at the player.
class CategoryCompleteOverlay extends StatefulWidget {
  final LevelTheme theme;
  final int floor;
  final VoidCallback onDismiss;

  const CategoryCompleteOverlay({
    super.key,
    required this.theme,
    required this.floor,
    required this.onDismiss,
  });

  @override
  State<CategoryCompleteOverlay> createState() =>
      _CategoryCompleteOverlayState();
}

class _CategoryCompleteOverlayState extends State<CategoryCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = widget.theme.palette;
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _float]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_intro.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Category image background
              Image.asset(
                widget.theme.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color.lerp(palette.floorLight, Colors.white, 0.15)!,
                        palette.floorBase,
                        palette.floorDark,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // Dark overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Sparkle layer
              CustomPaint(
                painter: _SparklePainter(
                  progress: _float.value,
                  color: Colors.white.withValues(alpha: 0.85),
                  accent: widget.theme.color,
                ),
              ),

              // Category image in circular frame — floats gently
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                        0, 24 * (1 - t) + math.sin(_float.value * math.pi * 2) * 4),
                    child: Transform.scale(
                      scale: 0.5 + 0.45 * t,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: widget.theme.color.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: ClipOval(
                            child: Image.asset(
                              widget.theme.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: widget.theme.color.withValues(alpha: 0.2),
                                child: Icon(widget.theme.icon,
                                    size: 64, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title + subtitle + button
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: t,
                  child: Column(
                    children: [
                      Icon(widget.theme.icon,
                          size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        l.categoryComplete(widget.theme.localizedName(l)),
                        textAlign: TextAlign.center,
                        style: CatCafeTheme.display(fontSize: 36).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.everyCushionClaimed(widget.floor),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: t,
                    child: ElevatedButton.icon(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(l.continueButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.color,
                        foregroundColor: CatCafeTheme.darkText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accent;
  _SparklePainter({required this.progress, required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final phase = (progress + rng.nextDouble()) % 1.0;
      final a = (math.sin(phase * math.pi * 2) * 0.5 + 0.5);
      final r = 1.5 + rng.nextDouble() * 2.2;
      final c = (i % 5 == 0 ? accent : color).withValues(alpha: a * 0.9);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = c);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) =>
      old.progress != progress;
}

