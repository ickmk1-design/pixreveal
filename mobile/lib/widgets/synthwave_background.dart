import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/cyber_theme.dart';

/// Animated synthwave background: gradient sky + retro sun + perspective grid + stars.
class SynthwaveBackground extends StatefulWidget {
  final Widget? child;
  const SynthwaveBackground({super.key, this.child});

  @override
  State<SynthwaveBackground> createState() => _SynthwaveBackgroundState();
}

class _SynthwaveBackgroundState extends State<SynthwaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rng = Random(42);
    for (int i = 0; i < 80; i++) {
      _stars.add(_Star(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.6,
        size: 0.5 + rng.nextDouble() * 1.5,
        twinkleOffset: rng.nextDouble() * 6.28,
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Cyber.bgPrimary, Color(0xFF1A0033), Cyber.bgPrimary],
            ),
          ),
        ),
        // Animated synthwave layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => CustomPaint(
              painter: _SynthwavePainter(_ctrl.value, _stars),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Star {
  final double x, y, size, twinkleOffset;
  _Star({required this.x, required this.y, required this.size, required this.twinkleOffset});
}

class _SynthwavePainter extends CustomPainter {
  final double t;
  final List<_Star> stars;
  _SynthwavePainter(this.t, this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.55;

    // Stars (top half)
    for (final s in stars) {
      final twinkle = 0.3 + (sin(t * 12 + s.twinkleOffset) + 1) * 0.35;
      canvas.drawCircle(
        Offset(s.x * w, s.y * horizonY),
        s.size * twinkle,
        Paint()..color = Color.fromARGB((twinkle * 255).toInt(), 255, 255, 255),
      );
    }

    // Retro sun
    final sunCenterX = w / 2;
    final sunCenterY = horizonY - 20;
    final sunR = w * 0.25;

    // Sun glow
    canvas.drawCircle(
      Offset(sunCenterX, sunCenterY), sunR * 1.4,
      Paint()
        ..color = Cyber.sunPink.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Sun body — half visible above horizon
    final sunRect = Rect.fromCircle(center: Offset(sunCenterX, sunCenterY), radius: sunR);
    canvas.drawCircle(
      Offset(sunCenterX, sunCenterY), sunR,
      Paint()..shader = Cyber.sunGradient.createShader(sunRect),
    );

    // Sun horizontal stripes (Tron style)
    final stripePaint = Paint()..color = Cyber.bgPrimary..blendMode = BlendMode.srcOver;
    for (int i = 0; i < 6; i++) {
      final stripeY = sunCenterY + sunR * 0.1 + i * (sunR * 0.13);
      if (stripeY < sunCenterY + sunR) {
        canvas.drawRect(
          Rect.fromLTWH(sunCenterX - sunR, stripeY, sunR * 2, 2 + i * 0.5),
          stripePaint,
        );
      }
    }

    // Mountain silhouette
    final mountPath = Path();
    mountPath.moveTo(0, horizonY);
    final mountPoints = [
      [0.0, 0.0], [0.1, -0.08], [0.18, -0.04], [0.25, -0.12],
      [0.35, -0.06], [0.42, -0.14], [0.5, -0.05], [0.58, -0.13],
      [0.65, -0.07], [0.75, -0.15], [0.82, -0.06], [0.9, -0.1], [1.0, -0.04],
    ];
    for (final p in mountPoints) {
      mountPath.lineTo(p[0] * w, horizonY + p[1] * horizonY);
    }
    mountPath.lineTo(w, horizonY);
    mountPath.close();
    canvas.drawPath(mountPath, Paint()..color = const Color(0xFF1A0033));

    // Mountain glow line
    canvas.drawPath(mountPath, Paint()
      ..color = Cyber.accentPink.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

    // Horizon line
    canvas.drawLine(
      Offset(0, horizonY), Offset(w, horizonY),
      Paint()
        ..color = Cyber.accentCyan.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Perspective grid (below horizon, animated)
    _drawPerspectiveGrid(canvas, w, h, horizonY);
  }

  void _drawPerspectiveGrid(Canvas canvas, double w, double h, double horizonY) {
    final gridPaint = Paint()
      ..color = Cyber.accentCyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final glowPaint = Paint()
      ..color = Cyber.accentPink.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final centerX = w / 2;

    // Vertical lines (perspective lines from horizon)
    for (int i = -10; i <= 10; i++) {
      final endX = centerX + i * (w * 0.12);
      canvas.drawLine(Offset(centerX, horizonY), Offset(endX, h), gridPaint);
      canvas.drawLine(Offset(centerX, horizonY), Offset(endX, h), glowPaint);
    }

    // Horizontal lines (animated, moving toward viewer)
    final scrollOffset = (t * 1.0) % 1.0;
    for (int i = 0; i < 12; i++) {
      // Exponential spacing for perspective effect
      final progress = (i + scrollOffset) / 12;
      final lineY = horizonY + (h - horizonY) * (progress * progress);
      if (lineY > horizonY && lineY < h) {
        final alpha = (1.0 - progress) * 0.8;
        canvas.drawLine(
          Offset(0, lineY), Offset(w, lineY),
          Paint()
            ..color = Cyber.accentCyan.withValues(alpha: alpha)
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SynthwavePainter old) => true;
}
