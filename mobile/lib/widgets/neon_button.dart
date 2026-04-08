import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;
  final double fontSize;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.neonPink,
    this.width = 220,
    this.height = 52,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: fontSize,
              color: color,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
