import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'enemy_base.dart';
import '../utils/game_constants.dart';

/// Spider enemy: bounces randomly inside the game area
/// Used in World 1, Levels 1-5
class Spider extends EnemyBase {
  double _directionTimer = 0;
  double _nextDirectionChange = 2.0;
  double _animAngle = 0;

  Spider({
    required super.gameBounds,
    super.speedMultiplier,
  }) : super(speed: 80, radius: 12);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spawnRandom();

    // Random initial direction
    final angle = rng.nextDouble() * 2 * pi;
    velocity = Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Randomly change direction
    _directionTimer += dt;
    if (_directionTimer >= _nextDirectionChange) {
      _directionTimer = 0;
      _nextDirectionChange = 1.5 + rng.nextDouble() * 2.5;

      final angle = rng.nextDouble() * 2 * pi;
      velocity = Vector2(cos(angle), sin(angle)) * speed;
    }

    // Move
    position += velocity * dt;

    // Bounce
    bounceOffWalls();

    // Animation
    _animAngle += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    // Spider body
    final bodyPaint = Paint()
      ..color = GameConstants.enemyColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius * 0.7, bodyPaint);

    // Spider legs (8 legs, animated)
    final legPaint = Paint()
      ..color = GameConstants.enemyColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final baseAngle = (i * pi / 4) + sin(_animAngle + i * 0.5) * 0.3;
      final legLen = radius * 1.2;
      final endX = radius + cos(baseAngle) * legLen;
      final endY = radius + sin(baseAngle) * legLen;
      canvas.drawLine(
        Offset(radius, radius),
        Offset(endX, endY),
        legPaint,
      );
    }

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius - 3, radius - 2), 2.5, eyePaint);
    canvas.drawCircle(Offset(radius + 3, radius - 2), 2.5, eyePaint);

    final pupilPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius - 2.5, radius - 1.5), 1.5, pupilPaint);
    canvas.drawCircle(Offset(radius + 3.5, radius - 1.5), 1.5, pupilPaint);

    // Glow
    final glowPaint = Paint()
      ..color = GameConstants.enemyColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(radius, radius), radius, glowPaint);
  }
}
