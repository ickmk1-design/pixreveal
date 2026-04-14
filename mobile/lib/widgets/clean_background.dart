import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/cyber_theme.dart';

/// Minimal dark background with subtle floating particles.
/// Used on most screens — no synthwave sun/grid (those are for hero/menu only).
class CleanBackground extends StatefulWidget {
  final Widget? child;
  const CleanBackground({super.key, this.child});

  @override
  State<CleanBackground> createState() => _CleanBackgroundState();
}

class _CleanBackgroundState extends State<CleanBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final rng = Random(7);
    for (int i = 0; i < 35; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 0.5 + rng.nextDouble() * 1.2,
        speed: 0.2 + rng.nextDouble() * 0.5,
        offset: rng.nextDouble() * 6.28,
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Cyber.bgPrimary),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(painter: _ParticlePainter(_ctrl.value, _particles)),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  final double x, y, size, speed, offset;
  _Particle({required this.x, required this.y, required this.size,
    required this.speed, required this.offset});
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;
  _ParticlePainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final twinkle = 0.3 + (sin(t * 12 * p.speed + p.offset) + 1) * 0.25;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * twinkle,
        Paint()..color = Color.fromARGB((twinkle * 200).toInt(), 200, 220, 255),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
