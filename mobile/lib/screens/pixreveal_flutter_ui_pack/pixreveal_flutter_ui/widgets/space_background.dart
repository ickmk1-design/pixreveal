import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpaceBackground extends StatelessWidget {
  final Widget child;

  const SpaceBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.85),
          radius: 1.3,
          colors: [
            Color(0xFF2A1120),
            Color(0xFF170D17),
            Color(0xFF090C14),
            Color(0xFF04060A),
          ],
          stops: [0.0, 0.32, 0.72, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _GlowOrb(
            size: 320,
            alignment: Alignment(-0.95, -0.82),
            color: Color(0x33FF5353),
          ),
          const _GlowOrb(
            size: 260,
            alignment: Alignment(0.92, -0.38),
            color: Color(0x22FF9648),
          ),
          const _GlowOrb(
            size: 220,
            alignment: Alignment(-0.70, 0.66),
            color: Color(0x221A88FF),
          ),
          const CustomPaint(painter: _StarsPainter()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.20),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Alignment alignment;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.6,
              spreadRadius: size * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    for (int i = 0; i < 150; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 1.3 + 0.3;
      final bright = rnd.nextDouble();

      final paint = Paint()
        ..color = bright > 0.92
            ? const Color(0xFFFFD78A).withOpacity(0.95)
            : Colors.white.withOpacity(0.82);

      canvas.drawCircle(Offset(dx, dy), radius, paint);

      if (bright > 0.95) {
        final glow = Paint()
          ..color = const Color(0x33FFD78A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(dx, dy), radius * 4, glow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
