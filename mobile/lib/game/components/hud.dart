import 'dart:ui';
import 'package:flame/components.dart';

class Hud extends Component {
  int lives = 3;
  double capturedPercent = 0;
  int elapsedSeconds = 0;
  int level = 1;

  final double gameWidth;
  final double hudHeight = 50;

  Hud({required this.gameWidth});

  @override
  void render(Canvas canvas) {
    // HUD background
    final bgPaint = Paint()..color = const Color(0xCC0A0A1A);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameWidth, hudHeight),
      bgPaint,
    );

    // Bottom border line
    final linePaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, hudHeight),
      Offset(gameWidth, hudHeight),
      linePaint,
    );

    // Lives
    _drawText(canvas, 'LIVES: $lives', 10, 18,
        fontSize: 11, color: const Color(0xFFFFFFFF));

    // Percentage
    final pct = (capturedPercent * 100).toStringAsFixed(1);
    _drawText(canvas, '$pct%', gameWidth / 2 - 30, 18,
        fontSize: 13, color: const Color(0xFF00FF00));

    // Level
    _drawText(canvas, 'LV.$level', gameWidth - 80, 18,
        fontSize: 11, color: const Color(0xFFFFFFFF));

    // Time
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    final timeStr =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    _drawText(canvas, timeStr, gameWidth - 80, 34,
        fontSize: 9, color: const Color(0xFFFFFF00));
  }

  void _drawText(Canvas canvas, String text, double x, double y,
      {double fontSize = 11, Color color = const Color(0xFFFFFFFF)}) {
    final builder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: fontSize,
      fontFamily: 'PressStart2P',
    ))
      ..pushStyle(TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'PressStart2P',
      ))
      ..addText(text);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 200));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
