import 'package:flutter/material.dart';

class GoldStar extends StatelessWidget {
  final double size;
  final bool filled;
  final bool glow;

  const GoldStar({
    super.key,
    this.size = 38,
    this.filled = true,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = filled ? const Color(0xFFFFD84D) : const Color(0x55FFD84D);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: const Color(0x66FFD84D),
                  blurRadius: size * 0.45,
                  spreadRadius: size * 0.04,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (filled)
            Icon(
              Icons.star,
              size: size,
              color: const Color(0x66FFF4A4),
            ),
          ShaderMask(
            shaderCallback: (Rect rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF0A8),
                  Color(0xFFFFD84D),
                  Color(0xFFC98B11),
                ],
              ).createShader(rect);
            },
            child: Icon(
              filled ? Icons.star : Icons.star_outline,
              size: size * 0.92,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}