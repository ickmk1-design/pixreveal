import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RetroProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color fillColor;
  final Color bgColor;

  const RetroProgressBar({
    super.key,
    required this.value,
    this.height = 16,
    this.fillColor = AppColors.neonGreen,
    this.bgColor = AppColors.darkCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: fillColor.withValues(alpha: 0.5), width: 1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: fillColor.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
