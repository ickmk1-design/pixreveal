import 'package:flutter/material.dart';

class LockIcon extends StatelessWidget {
  final double size;
  const LockIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.857, size),
      painter: _LockPainter(),
    );
  }
}

class _LockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final goldShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    ).createShader(Offset.zero & size);

    // Shackle (arc top)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round
      ..shader = goldShader;

    final arcRect = Rect.fromLTWH(w * 0.17, 0, w * 0.67, h * 0.57);
    canvas.drawArc(arcRect, 3.14, 3.14, false, arcPaint);

    // Body rect
    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = goldShader;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.43, w, h * 0.57),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF8B6508),
    );

    // Keyhole
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.65),
      w * 0.12,
      Paint()..color = const Color(0xFF5A4208),
    );
    final keyPath = Path()
      ..moveTo(w * 0.43, h * 0.74)
      ..lineTo(w * 0.57, h * 0.74)
      ..lineTo(w * 0.54, h * 0.88)
      ..lineTo(w * 0.46, h * 0.88)
      ..close();
    canvas.drawPath(keyPath, Paint()..color = const Color(0xFF5A4208));
  }

  @override
  bool shouldRepaint(_LockPainter _) => false;
}
