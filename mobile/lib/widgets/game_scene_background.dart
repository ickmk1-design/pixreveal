import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/cyber_theme.dart';

/// Animated game scene background — shows a half-revealed image with
/// a spider chasing a player along an animated trail. Demonstrates the
/// game concept at a glance.
class GameSceneBackground extends StatefulWidget {
  const GameSceneBackground({super.key});

  @override
  State<GameSceneBackground> createState() => _GameSceneBackgroundState();
}

class _GameSceneBackgroundState extends State<GameSceneBackground>
    with TickerProviderStateMixin {
  late AnimationController _trailCtrl;
  late AnimationController _idleCtrl;

  @override
  void initState() {
    super.initState();
    _trailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _trailCtrl.dispose();
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Background image (galaxy)
        Image.asset(
          'assets/images/space_1.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Cyber.bgPrimary),
        ),

        // Layer 2: Partial blue overlay (simulates captured/uncaptured)
        // Using ClipPath to create an irregular reveal pattern
        Positioned.fill(
          child: CustomPaint(painter: _OverlayPainter()),
        ),

        // Layer 3: Animated game scene (spider + player + trail)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_trailCtrl, _idleCtrl]),
            builder: (_, __) => CustomPaint(
              painter: _ScenePainter(_trailCtrl.value, _idleCtrl.value),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws partial colored overlay simulating uncaptured area
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Build a path of "uncaptured" regions (random rectangles forming an irregular shape)
    final path = Path();

    // Top-left region
    path.addRect(Rect.fromLTWH(0, 0, w * 0.55, h * 0.40));
    // Right strip
    path.addRect(Rect.fromLTWH(w * 0.65, 0, w * 0.35, h * 0.65));
    // Bottom-left
    path.addRect(Rect.fromLTWH(0, h * 0.55, w * 0.30, h * 0.45));
    // Bottom-right corner
    path.addRect(Rect.fromLTWH(w * 0.75, h * 0.75, w * 0.25, h * 0.25));

    canvas.drawPath(path, Paint()..color = const Color(0xEB0022AA));

    // Strong dark vignette top + bottom for text readability
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.30),
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Cyber.bgPrimary, Color(0x000A0A14)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.30)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.35),
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x000A0A14), Cyber.bgPrimary],
      ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35)),
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => false;
}

/// Draws spider, player, and animated trail
class _ScenePainter extends CustomPainter {
  final double trailT;
  final double idleT;
  _ScenePainter(this.trailT, this.idleT);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scene anchor — middle vertical
    final centerY = h * 0.48;

    // === SPIDER (left side) ===
    final spiderX = w * 0.18;
    final spiderY = centerY + sin(idleT * 2 * pi) * 3;
    _drawSpider(canvas, spiderX, spiderY);

    // === PLAYER (right side) ===
    final playerX = w * 0.82;
    final playerY = centerY - 30;
    _drawPlayer(canvas, playerX, playerY);

    // === TRAIL (animated, from spider toward player) ===
    _drawTrail(canvas, spiderX, spiderY, playerX, playerY, w);
  }

  void _drawSpider(Canvas canvas, double cx, double cy) {
    // Aura
    canvas.drawCircle(
      Offset(cx, cy), 50,
      Paint()
        ..color = const Color(0x55FF1040)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // 8 legs (animated)
    for (int side = 0; side < 2; side++) {
      final dir = side == 0 ? -1.0 : 1.0;
      for (int i = 0; i < 4; i++) {
        final phase = idleT * 2 * pi + i * 0.8 + side * 1.5;
        final wave = sin(phase) * 4;

        final baseAngle = (-0.7 + i * 0.45);
        final s1Len = 28.0;
        final j1x = cx + dir * cos(baseAngle) * s1Len;
        final j1y = cy + sin(baseAngle) * 18 + i * 3 - 4 + wave * 0.3;

        final kneeAngle = baseAngle + dir * 0.8;
        final s2Len = 26.0;
        final endX = j1x + dir * cos(kneeAngle) * s2Len;
        final endY = j1y + sin(kneeAngle) * 16 + 8 - wave;

        final legPaint = Paint()
          ..color = const Color(0xFF1A0808)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx + dir * 8, cy + i * 2 - 2), Offset(j1x, j1y), legPaint);
        canvas.drawLine(Offset(j1x, j1y), Offset(endX, endY), legPaint);
        canvas.drawCircle(Offset(j1x, j1y), 2.5, Paint()..color = const Color(0xFF2A1010));
      }
    }

    // Abdomen (back, large)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 50, height: 38),
      Paint()..color = const Color(0xFF0D0606),
    );
    // Highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 4, cy + 4), width: 18, height: 14),
      Paint()..color = const Color(0xFF1A0F0A),
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 14), width: 26, height: 22),
      Paint()..color = const Color(0xFF15080A),
    );

    // RED GLOWING EYES (4)
    final eyePulse = 0.7 + (sin(idleT * 4 * pi) + 1) * 0.15;
    _drawSpiderEye(canvas, cx - 6, cy - 16, 5, eyePulse);
    _drawSpiderEye(canvas, cx + 6, cy - 16, 5, eyePulse);
    _drawSpiderEye(canvas, cx - 11, cy - 12, 3, eyePulse * 0.8);
    _drawSpiderEye(canvas, cx + 11, cy - 12, 3, eyePulse * 0.8);

    // Fangs
    final fangP = Paint()
      ..color = const Color(0xFFCCBB99)..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 4, cy - 6), Offset(cx - 6, cy + 2), fangP);
    canvas.drawLine(Offset(cx + 4, cy - 6), Offset(cx + 6, cy + 2), fangP);
  }

  void _drawSpiderEye(Canvas canvas, double x, double y, double r, double glow) {
    canvas.drawCircle(Offset(x, y), r + 3, Paint()
      ..color = Color.fromARGB((glow * 200).toInt(), 255, 0, 0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(Offset(x, y), r, Paint()..color = const Color(0xFFFF0000));
    canvas.drawCircle(Offset(x - r * 0.3, y - r * 0.3), r * 0.4,
      Paint()..color = Colors.white.withValues(alpha: glow));
  }

  void _drawPlayer(Canvas canvas, double cx, double cy) {
    // Glow
    canvas.drawCircle(
      Offset(cx, cy), 30,
      Paint()
        ..color = const Color(0x6600F0FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Diamond
    final s = 16.0;
    final path = Path()
      ..moveTo(cx, cy - s)
      ..lineTo(cx + s, cy)
      ..lineTo(cx, cy + s)
      ..lineTo(cx - s, cy)
      ..close();

    // Outer glow stroke
    canvas.drawPath(path, Paint()
      ..color = Cyber.accentCyan
      ..style = PaintingStyle.stroke..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Fill
    canvas.drawPath(path, Paint()..color = Cyber.accentCyan);

    // Inner core (white)
    final coreS = 10.0;
    final corePath = Path()
      ..moveTo(cx, cy - coreS)
      ..lineTo(cx + coreS, cy)
      ..lineTo(cx, cy + coreS)
      ..lineTo(cx - coreS, cy)
      ..close();
    canvas.drawPath(corePath, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  void _drawTrail(Canvas canvas, double sx, double sy, double px, double py, double w) {
    // Trail path: spider → middle wavy → player
    final path = Path()..moveTo(sx + 30, sy);
    final midX = (sx + px) / 2;
    final midY1 = sy - 40;
    final midY2 = py + 30;

    path.lineTo(midX - 20, midY1);
    path.lineTo(midX + 20, midY2);
    path.lineTo(px - 20, py);

    // Animated dash effect
    final dashLength = 12.0;
    final gapLength = 8.0;
    final totalLength = dashLength + gapLength;
    final pathMetrics = path.computeMetrics();

    for (final pm in pathMetrics) {
      double dist = -trailT * totalLength;
      while (dist < pm.length) {
        final start = max(0.0, dist);
        final end = min(pm.length, dist + dashLength);
        if (end > start) {
          final extracted = pm.extractPath(start, end);
          // Glow
          canvas.drawPath(extracted, Paint()
            ..color = Cyber.accentPink.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
          // Core
          canvas.drawPath(extracted, Paint()
            ..color = Cyber.accentPink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
        }
        dist += totalLength;
      }
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}
