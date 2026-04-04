import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/level_data.dart';
import '../widgets/star_rating.dart';

class ResultScreen extends StatefulWidget {
  final LevelData levelData;
  final int moves;
  final int stars;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onLevelSelect;

  const ResultScreen({
    super.key,
    required this.levelData,
    required this.moves,
    required this.stars,
    required this.onNextLevel,
    required this.onRetry,
    required this.onLevelSelect,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: CatCafeTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration
                    const Text(
                      '😸',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Purrfect!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: CatCafeTheme.darkText,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Floor ${widget.levelData.floor} - ${widget.levelData.name}',
                      style: TextStyle(
                        color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stars
                    StarRating(stars: widget.stars, size: 40),

                    const SizedBox(height: 16),

                    // Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CatCafeTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ResultStat(
                              label: 'Moves', value: '${widget.moves}'),
                          _ResultStat(
                              label: 'Cats',
                              value:
                                  '${widget.levelData.catStarts.length}'),
                          _ResultStat(
                            label: 'Rating',
                            value: widget.stars == 3
                                ? 'Perfect!'
                                : widget.stars == 2
                                    ? 'Great'
                                    : 'Good',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CatCafeTheme.darkText,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: widget.onNextLevel,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next Floor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CatCafeTheme.secondary,
                              foregroundColor: CatCafeTheme.darkText,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onLevelSelect,
                      child: const Text('Back to Floor Select'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;

  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
