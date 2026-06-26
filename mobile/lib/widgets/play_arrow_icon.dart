import 'package:flutter/material.dart';

class PlayArrowIcon extends StatelessWidget {
  final double size;
  const PlayArrowIcon({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlayArrowPainter(),
    );
  }
}

class _PlayArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 1;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      r + 3,
      Paint()
        ..color = const Color(0xFF00DDFF).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Circle fill
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00AADD), Color(0xFF00DDFF)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, circlePaint);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white,
    );

    // Play triangle
    final tri = Path()
      ..moveTo(cx - r * 0.25, cy - r * 0.38)
      ..lineTo(cx + r * 0.45, cy)
      ..lineTo(cx - r * 0.25, cy + r * 0.38)
      ..close();
    canvas.drawPath(tri, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_PlayArrowPainter _) => false;
}
