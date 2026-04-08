import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RetroCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsetsGeometry padding;

  const RetroCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.neonBlue,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
