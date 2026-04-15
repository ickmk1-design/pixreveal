import 'package:flutter/material.dart';

class GoldStar extends StatelessWidget {
  final double size;
  final bool filled;

  const GoldStar({
    super.key,
    this.size = 34,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (filled)
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x55FFD36A),
                    blurRadius: size * 0.35,
                    spreadRadius: size * 0.03,
                  ),
                ],
              ),
            ),
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF2A9),
                  Color(0xFFFFD44E),
                  Color(0xFFC98A12),
                ],
              ).createShader(rect);
            },
            child: Icon(
              filled ? Icons.star : Icons.star_outline,
              size: size,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
