import 'package:flutter/material.dart';
import '../config/theme.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.05),
          child: Icon(
            index < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: index < stars ? CatCafeTheme.star : CatCafeTheme.starEmpty,
            size: size,
          ),
        );
      }),
    );
  }
}
