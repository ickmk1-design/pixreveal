import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'powerups.dart';
import '../utils/game_constants.dart';

class Hud extends Component {
  int lives = 3;
  double capturedPercent = 0;
  int elapsedSeconds = 0;
  int level = 1;
  int tokens = 0;
  int score = 0;
  int combo = 0;
  ActivePowerUp? activePowerUp; // legacy single
  List<ActivePowerUp> activeEffects = []; // all active effects

  final double gameWidth;
  final double hudHeight = GameConstants.hudHeight;
  double _heartBeat = 0;
  double _progressGlow = 0;

  // Popup text
  String? _popup;
  double _popupTimer = 0;

  // Power-up announcement (big center popup)
  String? _puAnnouncement;
  String? _puDescription;
  Color _puColor = const Color(0xFFFFFFFF);
  double _puTimer = 0;

  // PNG sprites — Cowork tarafından eklenen assets/images/powerup_*.png dosyaları.
  // Dosya yoksa null kalır → procedural fallback çizilir.
  final Map<PowerUpType, Sprite?> _puSprites = {};

  Hud({required this.gameWidth});

  @override
  Future<void> onLoad() async {
    for (final type in PowerUpType.values) {
      final path = switch (type) {
        PowerUpType.freeze => 'powerup_freeze.png',
        PowerUpType.speed  => 'powerup_speed.png',
        PowerUpType.shield => 'powerup_shield.png',
      };
      try {
        _puSprites[type] = await Sprite.load(path);
      } catch (_) {
        _puSprites[type] = null;
      }
    }
  }

  void showPopup(String text) {
    _popup = text;
    _popupTimer = 1.5;
  }

  void showPowerUpAnnouncement(String title, String desc, Color color) {
    _puAnnouncement = title;
    _puDescription = desc;
    _puColor = color;
    _puTimer = 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _heartBeat += dt * 4;
    _progressGlow += dt * 3;
    if (_popupTimer > 0) _popupTimer -= dt;
    if (_puTimer > 0) _puTimer -= dt;
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

    // Active power-ups — multiple effects side by side
    for (int i = 0; i < activeEffects.length; i++) {
      _drawActivePowerUpAt(canvas, activeEffects[i], i);
    }

    // Big center announcement (when new power-up collected)
    if (_puTimer > 0 && _puAnnouncement != null) {
      _drawAnnouncement(canvas);
    }
  }

  void _drawAnnouncement(Canvas canvas) {
    // Fade in first 0.3s, hold, fade out last 0.4s
    final t = _puTimer / 2.0;
    double alpha;
    double scale;
    if (t > 0.85) {
      // fade in (remaining 2.0→1.7)
      final p = (2.0 - _puTimer) / 0.3;
      alpha = p.clamp(0.0, 1.0);
      scale = 0.7 + 0.3 * alpha;
    } else if (t < 0.2) {
      // fade out
      alpha = (t / 0.2).clamp(0.0, 1.0);
      scale = 1.0;
    } else {
      alpha = 1.0;
      scale = 1.0;
    }

    final cx = gameWidth / 2;
    final cy = hudHeight + 120;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    canvas.translate(-cx, -cy);

    // Background dark panel
    final panelW = gameWidth * 0.85;
    const panelH = 100.0;
    final panelRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: panelW, height: panelH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(12)),
      Paint()..color = Color.fromARGB((alpha * 220).toInt(), 10, 10, 30),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(12)),
      Paint()
        ..color = _puColor.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(12)),
      Paint()
        ..color = _puColor.withValues(alpha: alpha * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Title
    final titleBuilder = ParagraphBuilder(ParagraphStyle(
      fontSize: 20, fontFamily: 'PressStart2P', textAlign: TextAlign.center,
    ))
      ..pushStyle(TextStyle(
        color: Color.fromARGB((alpha * 255).toInt(),
          _puColor.r.toInt(), _puColor.g.toInt(), _puColor.b.toInt()),
        shadows: [Shadow(color: _puColor, blurRadius: 12)],
      ))
      ..addText(_puAnnouncement!);
    final titleP = titleBuilder.build()..layout(ParagraphConstraints(width: panelW));
    canvas.drawParagraph(titleP, Offset(cx - panelW / 2, cy - 32));

    // Description
    final descBuilder = ParagraphBuilder(ParagraphStyle(
      fontSize: 9, fontFamily: 'PressStart2P', textAlign: TextAlign.center,
    ))
      ..pushStyle(TextStyle(
        color: Color.fromARGB((alpha * 200).toInt(), 255, 255, 255),
      ))
      ..addText(_puDescription ?? '');
    final descP = descBuilder.build()..layout(ParagraphConstraints(width: panelW));
    canvas.drawParagraph(descP, Offset(cx - panelW / 2, cy + 10));

    canvas.restore();
  }

  void _drawActivePowerUpAt(Canvas canvas, ActivePowerUp ap, int index) {
    final x = gameWidth - 100 - index * 36.0;
    const y = 28.0;
    final frac = (ap.remaining / ap.total).clamp(0.0, 1.0);

    Color col;
    switch (ap.type) {
      case PowerUpType.freeze: col = const Color(0xFF00DDFF);
      case PowerUpType.speed: col = const Color(0xFFFFDD00);
      case PowerUpType.shield: col = const Color(0xFF00FF88);
    }

    // Glow
    canvas.drawCircle(Offset(x, y), 16, Paint()
      ..color = col.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Circle bg
    canvas.drawCircle(Offset(x, y), 13, Paint()..color = const Color(0xDD000018));
    canvas.drawCircle(Offset(x, y), 13, Paint()
      ..color = col..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Mini icon — PNG sprite if loaded, else procedural fallback
    final sprite = _puSprites[ap.type];
    if (sprite != null) {
      sprite.render(canvas,
        position: Vector2(x - 9, y - 9),
        size: Vector2(18, 18),
      );
    } else {
      switch (ap.type) {
        case PowerUpType.freeze:
          for (int i = 0; i < 6; i++) {
            final a = i * pi / 3;
            canvas.drawLine(Offset(x, y), Offset(x + cos(a) * 7, y + sin(a) * 7),
              Paint()..color = col..strokeWidth = 1.4..strokeCap = StrokeCap.round);
          }
        case PowerUpType.speed:
          final p = Path()
            ..moveTo(x - 2, y - 6)..lineTo(x + 3, y - 1)
            ..lineTo(x - 1, y - 1)..lineTo(x + 2, y + 6)
            ..lineTo(x - 3, y + 1)..lineTo(x + 1, y + 1)..close();
          canvas.drawPath(p, Paint()..color = col);
        case PowerUpType.shield:
          final p = Path()
            ..moveTo(x, y - 7)..lineTo(x + 6, y - 4)
            ..lineTo(x + 6, y + 2)..lineTo(x, y + 7)
            ..lineTo(x - 6, y + 2)..lineTo(x - 6, y - 4)..close();
          canvas.drawPath(p, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }
    }

    // Progress bar under icon
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 15, y + 17, 30, 3), const Radius.circular(1.5)),
      Paint()..color = const Color(0x44FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 15, y + 17, 30 * frac, 3), const Radius.circular(1.5)),
      Paint()..color = col,
    );
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
