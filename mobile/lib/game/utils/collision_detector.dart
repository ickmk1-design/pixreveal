import 'dart:ui';

class CollisionDetector {
  /// Check if a circle (enemy) intersects with any line segment in the trail
  static bool circleIntersectsTrail(
    Offset center,
    double radius,
    List<Offset> trail,
  ) {
    for (int i = 0; i < trail.length - 1; i++) {
      if (circleIntersectsSegment(center, radius, trail[i], trail[i + 1])) {
        return true;
      }
    }
    return false;
  }

  /// Check if a circle intersects with a line segment
  static bool circleIntersectsSegment(
    Offset center,
    double radius,
    Offset a,
    Offset b,
  ) {
    final ab = b - a;
    final ac = center - a;
    final abLenSq = ab.dx * ab.dx + ab.dy * ab.dy;

    if (abLenSq == 0) {
      return (center - a).distance <= radius;
    }

    double t = (ac.dx * ab.dx + ac.dy * ab.dy) / abLenSq;
    t = t.clamp(0.0, 1.0);

    final closest = Offset(a.dx + t * ab.dx, a.dy + t * ab.dy);
    return (center - closest).distance <= radius;
  }

  /// Check if a point is on the border (within tolerance)
  static bool isOnBorder(Offset point, Rect bounds, {double tolerance = 3.0}) {
    return (point.dx - bounds.left).abs() < tolerance ||
        (point.dx - bounds.right).abs() < tolerance ||
        (point.dy - bounds.top).abs() < tolerance ||
        (point.dy - bounds.bottom).abs() < tolerance;
  }

  /// Check if two circles overlap
  static bool circlesOverlap(
    Offset c1,
    double r1,
    Offset c2,
    double r2,
  ) {
    return (c1 - c2).distance < r1 + r2;
  }

  /// Check if player (on border or captured territory) collides with enemy
  static bool playerHitByEnemy(
    Offset playerPos,
    double playerRadius,
    Offset enemyPos,
    double enemyRadius,
  ) {
    return circlesOverlap(playerPos, playerRadius, enemyPos, enemyRadius);
  }
}
