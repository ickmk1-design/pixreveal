import 'package:flutter/material.dart';

// JSX custom-screens.jsx LockIcon — SVG viewBox="0 0 24 28" birebir
// Shackle: M7 12V8 a5 5 0 0 1 10 0 v4  → stroke=gold-gradient, width=2.2, cap=round
// Body:    rect x=4,y=12,w=16,h=13,rx=2.5  fill=gold-gradient, stroke=#8b6508 w=1
// Circle:  cx=12,cy=18,r=1.8  fill=#5a4208
// Line:    M12 19v3  stroke=#5a4208, width=1.6, cap=round

class LockIcon extends StatelessWidget {
  final double size;
  const LockIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    // viewBox 24:28 ratio
    return CustomPaint(
      size: Size(size * 24 / 28, size),
      painter: _LockPainter(),
    );
  }
}

class _LockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 0 0 24 28 → scale to actual size
    final sx = size.width / 24;
    final sy = size.height / 28;
    canvas.scale(sx, sy);

    // Gold gradient over entire viewBox
    final goldGrad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    ).createShader(const Rect.fromLTWH(0, 0, 24, 28));

    // ── Shackle: M7 12 V8 a5 5 0 0 1 10 0 v4 ──────────────────
    // Start at (7,12) → go up to (7,8) → arc to (17,8) r=5 CW → down to (17,12)
    final shackle = Path()
      ..moveTo(7, 12)
      ..lineTo(7, 8)
      ..arcToPoint(const Offset(17, 8),
          radius: const Radius.circular(5), clockwise: true)
      ..lineTo(17, 12);

    canvas.drawPath(
      shackle,
      Paint()
        ..shader = goldGrad
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // ── Body rect: x=4,y=12,w=16,h=13,rx=2.5 ──────────────────
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 12, 16, 13),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(body,
        Paint()..shader = goldGrad..style = PaintingStyle.fill);
    canvas.drawRRect(
        body,
        Paint()
          ..color = const Color(0xFF8B6508)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // ── Keyhole circle: cx=12, cy=18, r=1.8 ────────────────────
    canvas.drawCircle(const Offset(12, 18), 1.8,
        Paint()..color = const Color(0xFF5A4208));

    // ── Keyhole line: M12 19 v3 ─────────────────────────────────
    canvas.drawLine(
      const Offset(12, 19),
      const Offset(12, 22),
      Paint()
        ..color = const Color(0xFF5A4208)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
