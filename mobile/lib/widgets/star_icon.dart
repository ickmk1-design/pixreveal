import 'package:flutter/material.dart';

class StarIcon extends StatelessWidget {
  final bool filled;
  final double size;

  const StarIcon({super.key, required this.filled, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(filled: filled),
    );
  }
}

class _StarPainter extends CustomPainter {
  final bool filled;
  _StarPainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    // 5-point star path scaled to size
    const points = [
      [0.5, 0.0],
      [0.625, 0.35],
      [1.0, 0.35],
      [0.72, 0.58],
      [0.82, 0.95],
      [0.5, 0.73],
      [0.18, 0.95],
      [0.28, 0.58],
      [0.0, 0.35],
      [0.375, 0.35],
    ];
    path.moveTo(points[0][0] * w, points[0][1] * h);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i][0] * w, points[i][1] * h);
    }
    path.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: filled
            ? const [Color(0xFFFFE066), Color(0xFFFF9500)]
            : const [Color(0xFF3A3A4A), Color(0xFF1A1A28)],
      ).createShader(Offset.zero & size);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = filled ? const Color(0xFFFFC04D) : const Color(0xFF444444);

    if (filled) {
      canvas.drawShadow(path, const Color(0xFFFFC800), 3, false);
    }
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.filled != filled;
}
