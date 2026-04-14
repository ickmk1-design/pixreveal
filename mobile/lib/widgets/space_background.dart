import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpaceBackground extends StatelessWidget {
  final Widget child;
  final bool withNebula;
  final bool withStars;
  final EdgeInsetsGeometry padding;

  const SpaceBackground({
    super.key,
    required this.child,
    this.withNebula = true,
    this.withStars = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.9),
          radius: 1.35,
          colors: [
            Color(0xFF32161E),
            Color(0xFF180D14),
            Color(0xFF090B12),
            Color(0xFF040507),
          ],
          stops: [0.0, 0.28, 0.72, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (withNebula) ...[
            const _GlowOrb(
              size: 320,
              alignment: Alignment(-0.95, -0.82),
              color: Color(0x66FF5B5B),
            ),
            const _GlowOrb(
              size: 280,
              alignment: Alignment(0.95, -0.45),
              color: Color(0x33FF8A3D),
            ),
            const _GlowOrb(
              size: 220,
              alignment: Alignment(-0.7, 0.55),
              color: Color(0x22B243FF),
            ),
          ],
          if (withStars) const Positioned.fill(child: _StarField()),
          Padding(padding: padding, child: child),
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
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: size * 0.6,
                spreadRadius: size * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(8);
    final small = Paint()..color = Colors.white.withOpacity(0.72);
    final medium = Paint()..color = const Color(0xFFEAEFFF).withOpacity(0.9);
    final glow = Paint()..color = const Color(0x66FFD36A);

    for (int i = 0; i < 140; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final r = rnd.nextDouble() * 1.4 + 0.4;
      canvas.drawCircle(
        Offset(dx, dy),
        r,
        i % 14 == 0 ? medium : small,
      );
      if (i % 21 == 0) {
        canvas.drawCircle(Offset(dx, dy), r * 4.5, glow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}