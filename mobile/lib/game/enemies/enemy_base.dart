import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

abstract class EnemyBase extends PositionComponent {
  double speed;
  double radius;
  final Rect gameBounds;
  final double speedMultiplier;
  Vector2 velocity = Vector2.zero();
  final Random rng = Random();

  EnemyBase({
    required this.gameBounds,
    required this.speed,
    this.radius = 10,
    this.speedMultiplier = 1.0,
  }) : super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        ) {
    speed *= speedMultiplier;
  }

  Offset get centerOffset => Offset(position.x, position.y);

  /// Spawn at a random position inside the game bounds
  void spawnRandom() {
    final margin = 40.0;
    position = Vector2(
      gameBounds.left + margin + rng.nextDouble() * (gameBounds.width - margin * 2),
      gameBounds.top + margin + rng.nextDouble() * (gameBounds.height - margin * 2),
    );
  }

  /// Bounce off game bounds
  void bounceOffWalls() {
    if (position.x - radius <= gameBounds.left) {
      position.x = gameBounds.left + radius;
      velocity.x = velocity.x.abs();
    }
    if (position.x + radius >= gameBounds.right) {
      position.x = gameBounds.right - radius;
      velocity.x = -velocity.x.abs();
    }
    if (position.y - radius <= gameBounds.top) {
      position.y = gameBounds.top + radius;
      velocity.y = velocity.y.abs();
    }
    if (position.y + radius >= gameBounds.bottom) {
      position.y = gameBounds.bottom - radius;
      velocity.y = -velocity.y.abs();
    }
  }
}
