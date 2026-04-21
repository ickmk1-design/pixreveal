import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../game_grid.dart';

abstract class EnemyBase extends PositionComponent {
  double speed;
  double radius;
  final Rect gameBounds;
  final double speedMultiplier;
  Vector2 velocity = Vector2.zero();
  final Random rng = Random();

  bool isChasing = false;
  Vector2 chaseTarget = Vector2.zero();
  double chaseIntensity;

  /// Grid reference — enemies can only move in EMPTY cells
  GameGrid? gameGrid;

  EnemyBase({
    required this.gameBounds,
    required this.speed,
    this.radius = 10,
    this.speedMultiplier = 1.0,
    this.chaseIntensity = 0.6,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center) {
    speed *= speedMultiplier;
  }

  Offset get centerOffset => Offset(position.x, position.y);

  void spawnRandom() {
    const margin = 50.0;
    position = Vector2(
      gameBounds.left + margin + rng.nextDouble() * (gameBounds.width - margin * 2),
      gameBounds.top + margin + rng.nextDouble() * (gameBounds.height - margin * 2),
    );
  }

  void bounceOffWalls() {
    if (position.x - radius <= gameBounds.left) {
      position.x = gameBounds.left + radius; velocity.x = velocity.x.abs();
    }
    if (position.x + radius >= gameBounds.right) {
      position.x = gameBounds.right - radius; velocity.x = -velocity.x.abs();
    }
    if (position.y - radius <= gameBounds.top) {
      position.y = gameBounds.top + radius; velocity.y = velocity.y.abs();
    }
    if (position.y + radius >= gameBounds.bottom) {
      position.y = gameBounds.bottom - radius; velocity.y = -velocity.y.abs();
    }
  }

  /// Bounce off non-EMPTY cells (claimed territory is a wall for enemies).
  /// If stuck in claimed area, teleport to nearest EMPTY cell.
  void bounceOffClaimed() {
    if (gameGrid == null) return;
    final g = gameGrid!;
    final (gc, gr) = g.toGrid(position.x, position.y);

    if (g.isEmpty(gc, gr)) return; // all good

    // In a non-EMPTY cell — try to find nearest EMPTY cell and teleport
    for (int radius = 1; radius <= 10; radius++) {
      for (int dr = -radius; dr <= radius; dr++) {
        for (int dc = -radius; dc <= radius; dc++) {
          if (dr.abs() != radius && dc.abs() != radius) continue;
          final nc = gc + dc, nr = gr + dr;
          if (g.isEmpty(nc, nr)) {
            final target = g.center(nc, nr);
            position = Vector2(target.dx, target.dy);
            // New random direction away from claimed
            final angle = rng.nextDouble() * 2 * pi;
            velocity = Vector2(cos(angle), sin(angle)) * speed;
            return;
          }
        }
      }
    }
  }
}
