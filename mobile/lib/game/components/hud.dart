import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constants.dart';

class Hud extends Component {
  int lives = 3;
  double capturedPercent = 0;
  int elapsedSeconds = 0;
  int level = 1;
  int tokens = 0;
  int score = 0;
  int combo = 0;

  final double gameWidth;
  final double hudHeight = GameConstants.hudHeight;
  double _heartBeat = 0;
  double _progressGlow = 0;

  // Popup text
  String? _popup;
  double _popupTimer = 0;

  Hud({required this.gameWidth});

  void showPopup(String text) {
    _popup = text;
    _popupTimer = 1.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _heartBeat += dt * 4;
    _progressGlow += dt * 3;
    if (_popupTimer > 0) _popupTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    // HUD background
    canvas.drawRect(Rect.fromLTWH(0, 0, gameWidth, hudHeight), Paint()
      ..shader = Gradient.linear(const Offset(0, 0), Offset(0, hudHeight),
        [const Color(0xFF080818), const Color(0xDD0A0A2A)]));

    // Bottom neon line
    final borderGlow = Paint()..color = GameConstants.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 4..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(0, hudHeight), Offset(gameWidth, hudHeight), borderGlow);
    canvas.drawLine(Offset(0, hudHeight), Offset(gameWidth, hudHeight),
      Paint()..color = GameConstants.borderColor..strokeWidth = 2);

    // Hearts
    _drawHearts(canvas);

    // Progress bar + %
    _drawProgressBar(canvas);

    // Level + Time (right side)
    _drawText(canvas, 'LV.$level', gameWidth - 80, 8, fontSize: 9, color: GameConstants.borderColor);
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    _drawText(canvas, '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
      gameWidth - 80, 24, fontSize: 8, color: const Color(0xFFFFFF00));

    // Score
    _drawText(canvas, '$score', gameWidth - 80, 40, fontSize: 8, color: const Color(0xFFFFFFFF));

    // Tokens (left, below hearts)
    _drawText(canvas, '\u{1FA99} $tokens', 10, 38, fontSize: 7, color: const Color(0xFFFFCC00));

    // Popup text (center, large, fading)
    if (_popupTimer > 0 && _popup != null) {
      final alpha = (_popupTimer / 1.5).clamp(0.0, 1.0);
      final popY = hudHeight + 60 - (1.0 - alpha) * 30;
      _drawText(canvas, _popup!, gameWidth / 2 - 60, popY,
        fontSize: 16, color: Color.fromARGB((alpha * 255).toInt(), 0, 255, 136));
    }
  }

  void _drawHearts(Canvas canvas) {
    final scale = 1.0 + sin(_heartBeat) * 0.05;
    for (int i = 0; i < 3; i++) {
      _drawHeart(canvas, 10.0 + i * 20, 10, 14 * (i < lives ? scale : 1.0), i < lives);
    }
  }

  void _drawHeart(Canvas canvas, double x, double y, double size, bool filled) {
    final s = size / 2;
    final path = Path()
      ..moveTo(x + s, y + s * 0.8)
      ..cubicTo(x + s, y + s * 0.4, x + s * 2, y - s * 0.2, x + s * 2, y + s * 0.4)
      ..cubicTo(x + s * 2, y + s, x + s, y + s * 1.6, x + s, y + s * 1.8)
      ..cubicTo(x + s, y + s * 1.6, x, y + s, x, y + s * 0.4)
      ..cubicTo(x, y - s * 0.2, x + s, y + s * 0.4, x + s, y + s * 0.8)
      ..close();

    if (filled) {
      canvas.drawPath(path, Paint()
        ..color = GameConstants.heartColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawPath(path, Paint()..color = GameConstants.heartColor);
    } else {
      canvas.drawPath(path, Paint()
        ..color = const Color(0x44FF3366)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  void _drawProgressBar(Canvas canvas) {
    final barW = gameWidth * 0.3;
    const barH = 10.0;
    final barX = (gameWidth - barW) / 2;
    const barY = 10.0;

    // Background
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barW, barH), const Radius.circular(5)),
      Paint()..color = GameConstants.progressBarBg);

    // Fill
    final fillW = barW * capturedPercent.clamp(0.0, 1.0);
    if (fillW > 0) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, fillW, barH), const Radius.circular(5)),
        Paint()..shader = Gradient.linear(
          Offset(barX, barY), Offset(barX + fillW, barY),
          [const Color(0xFF00FF88), const Color(0xFF00CCFF)]));

      // Glow at edge
      final ga = 0.4 + sin(_progressGlow) * 0.2;
      canvas.drawCircle(Offset(barX + fillW, barY + barH / 2), barH / 2,
        Paint()..color = Color.fromARGB((ga * 255).toInt(), 0, 255, 136)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    // Border
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barW, barH), const Radius.circular(5)),
      Paint()..color = GameConstants.borderColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke..strokeWidth = 1);

    // Percentage text
    final pct = (capturedPercent * 100).toStringAsFixed(1);
    _drawText(canvas, '$pct%', barX + barW / 2 - 18, barY + barH + 3,
      fontSize: 8, color: GameConstants.progressBarFill);
  }

  void _drawText(Canvas canvas, String text, double x, double y,
      {double fontSize = 11, Color color = const Color(0xFFFFFFFF)}) {
    final builder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.left, fontSize: fontSize, fontFamily: 'PressStart2P',
    ))
      ..pushStyle(TextStyle(color: color, fontSize: fontSize, fontFamily: 'PressStart2P'))
      ..addText(text);
    final paragraph = builder.build()..layout(const ParagraphConstraints(width: 250));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
