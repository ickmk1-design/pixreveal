import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final active = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            active ? Icons.star : Icons.star_border,
            color: active ? AppColors.gold : AppColors.gridLine,
            size: size,
            shadows: active
                ? [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
