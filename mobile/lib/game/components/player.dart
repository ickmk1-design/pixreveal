import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constants.dart';

enum MoveDirection { up, down, left, right, none }

class Player extends PositionComponent {
  int col;
  int row;
  MoveDirection direction = MoveDirection.none;
  bool isDrawing = false;

  double _glowPhase = 0;
  double _engineFlicker = 0;

  Player({required this.col, required this.row, double size = 16})
      : super(size: Vector2.all(size), anchor: Anchor.center);

  Offset get centerOffset => Offset(position.x, position.y);

  void moveTo(int c, int r, Offset screenPos) {
    col = c; row = r;
    position = Vector2(screenPos.dx, screenPos.dy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _glowPhase += dt * 4;
    _engineFlicker += dt * 12;
  }

  @override
  void render(Canvas canvas) {
    final s = size.x / 2;
    final glow = 0.4 + sin(_glowPhase) * 0.12;
    // Drawings are designed for 22px reference; scale to actual size
    final scale = size.x / 22.0;

    canvas.save();
    canvas.translate(s, s);
    canvas.scale(scale);

    // Rotate based on direction
    double angle = 0;
    switch (direction) {
      case MoveDirection.up: angle = 0;
      case MoveDirection.right: angle = pi / 2;
      case MoveDirection.down: angle = pi;
      case MoveDirection.left: angle = -pi / 2;
      case MoveDirection.none: angle = 0;
    }
    canvas.rotate(angle);

    // === OUTER GLOW ===
    canvas.drawCircle(Offset.zero, 14, Paint()
      ..color = GameConstants.playerColor.withValues(alpha: glow * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // === SHIP BODY ===
    // Main hull
    final hull = Path()
      ..moveTo(0, -9)    // nose tip
      ..lineTo(4, -3)    // right front
      ..lineTo(6, 2)     // right mid
      ..lineTo(8, 5)     // right wing tip
      ..lineTo(4, 4)     // right wing inner
      ..lineTo(3, 8)     // right engine
      ..lineTo(-3, 8)    // left engine
      ..lineTo(-4, 4)    // left wing inner
      ..lineTo(-8, 5)    // left wing tip
      ..lineTo(-6, 2)    // left mid
      ..lineTo(-4, -3)   // left front
      ..close();

    // Glow outline
    canvas.drawPath(hull, Paint()
      ..color = GameConstants.playerColor.withValues(alpha: glow * 0.8)
      ..style = PaintingStyle.stroke..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Fill with gradient
    canvas.drawPath(hull, Paint()
      ..shader = Gradient.linear(
        const Offset(0, -9), const Offset(0, 8),
        [GameConstants.playerColor, const Color(0xFF008855)],
      ));

    // Cockpit window
    final cockpit = Path()
      ..moveTo(0, -6)
      ..lineTo(2.5, -1)
      ..lineTo(0, 1)
      ..lineTo(-2.5, -1)
      ..close();
    canvas.drawPath(cockpit, Paint()..color = const Color(0xCC88FFCC));
    canvas.drawPath(cockpit, Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke..strokeWidth = 0.5);

    // Center stripe
    canvas.drawLine(const Offset(0, 1), const Offset(0, 7),
      Paint()..color = const Color(0x44FFFFFF)..strokeWidth = 1.5);

    // Wing detail lines
    canvas.drawLine(const Offset(4, 2), const Offset(7, 4),
      Paint()..color = const Color(0x44FFFFFF)..strokeWidth = 0.8);
    canvas.drawLine(const Offset(-4, 2), const Offset(-7, 4),
      Paint()..color = const Color(0x44FFFFFF)..strokeWidth = 0.8);

    // === ENGINE EXHAUST ===
    final engineGlow = 0.5 + sin(_engineFlicker) * 0.3;
    // Left engine
    canvas.drawCircle(const Offset(-2, 8), 2.5, Paint()
      ..color = Color.fromARGB((engineGlow * 200).toInt(), 0, 200, 255)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(const Offset(-2, 8), 1.2, Paint()
      ..color = const Color(0xCCFFFFFF));
    // Right engine
    canvas.drawCircle(const Offset(2, 8), 2.5, Paint()
      ..color = Color.fromARGB((engineGlow * 200).toInt(), 0, 200, 255)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(const Offset(2, 8), 1.2, Paint()
      ..color = const Color(0xCCFFFFFF));

    // Engine trail (short exhaust)
    if (direction != MoveDirection.none) {
      final trailLen = 3 + sin(_engineFlicker * 1.5) * 2;
      canvas.drawLine(Offset(-2, 9), Offset(-2, 9 + trailLen),
        Paint()..color = Color.fromARGB((engineGlow * 150).toInt(), 0, 180, 255)
          ..strokeWidth = 2..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      canvas.drawLine(Offset(2, 9), Offset(2, 9 + trailLen),
        Paint()..color = Color.fromARGB((engineGlow * 150).toInt(), 0, 180, 255)
          ..strokeWidth = 2..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }

    canvas.restore();
  }
}
