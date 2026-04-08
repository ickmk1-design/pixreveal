import 'dart:math';
import 'dart:ui';

class TerritoryCalculator {
  /// Calculate the area of a polygon using the Shoelace formula
  static double polygonArea(List<Offset> polygon) {
    if (polygon.length < 3) return 0;
    double area = 0;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      area +=
          (polygon[j].dx + polygon[i].dx) * (polygon[j].dy - polygon[i].dy);
      j = i;
    }
    return area.abs() / 2;
  }

  /// Calculate total captured percentage from list of captured polygons
  static double capturedPercent(
    List<List<Offset>> capturedPolygons,
    double totalArea,
  ) {
    if (totalArea <= 0) return 0;
    double captured = 0;
    for (final poly in capturedPolygons) {
      captured += polygonArea(poly);
    }
    return (captured / totalArea).clamp(0.0, 1.0);
  }

  /// Check if a point is inside a polygon (ray casting)
  static bool isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy) &&
          point.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  /// Check if a point is in any captured territory
  static bool isPointCaptured(Offset point, List<List<Offset>> territories) {
    for (final poly in territories) {
      if (isPointInPolygon(point, poly)) return true;
    }
    return false;
  }

  /// Build capture polygon from trail + border connection
  /// The trail starts/ends on the border; we close it via the shorter border path
  static List<Offset> buildCapturePolygon(
    List<Offset> trail,
    Rect bounds,
    List<Offset> Function(Offset, Offset, Rect) borderPath,
  ) {
    if (trail.length < 2) return [];
    final start = trail.first;
    final end = trail.last;
    final border = borderPath(end, start, bounds);
    return [...trail, ...border];
  }

  /// Get the shorter border path between two points on the rectangle border
  static List<Offset> shorterBorderPath(Offset from, Offset to, Rect bounds) {
    final clockwise = _borderPathDirection(from, to, bounds, true);
    final counterClockwise = _borderPathDirection(from, to, bounds, false);

    final cwLen = _pathLength(clockwise);
    final ccwLen = _pathLength(counterClockwise);

    return cwLen <= ccwLen ? clockwise : counterClockwise;
  }

  static double _pathLength(List<Offset> path) {
    double len = 0;
    for (int i = 1; i < path.length; i++) {
      len += (path[i] - path[i - 1]).distance;
    }
    return len;
  }

  static List<Offset> _borderPathDirection(
    Offset from,
    Offset to,
    Rect bounds,
    bool clockwise,
  ) {
    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomLeft,
    ];

    final fromSeg = _borderSegment(from, bounds);
    final toSeg = _borderSegment(to, bounds);

    List<Offset> path = [from];
    int seg = fromSeg;
    int maxIter = 8;

    while (maxIter-- > 0) {
      int nextCornerIdx = clockwise ? seg : (seg + 3) % 4;
      // But corner after from on seg
      if (clockwise) {
        nextCornerIdx = (seg + 1) % 4;
      }
      final nextCorner = corners[nextCornerIdx];

      if (seg == toSeg) {
        path.add(to);
        break;
      }

      path.add(nextCorner);
      seg = clockwise ? (seg + 1) % 4 : (seg + 3) % 4;
    }

    return path;
  }

  /// 0=top, 1=right, 2=bottom, 3=left
  static int _borderSegment(Offset point, Rect bounds) {
    const eps = 2.0;
    if ((point.dy - bounds.top).abs() < eps) return 0;
    if ((point.dx - bounds.right).abs() < eps) return 1;
    if ((point.dy - bounds.bottom).abs() < eps) return 2;
    return 3;
  }

  /// Snap a point to the nearest border edge
  static Offset snapToBorder(Offset point, Rect bounds) {
    final distTop = (point.dy - bounds.top).abs();
    final distRight = (point.dx - bounds.right).abs();
    final distBottom = (point.dy - bounds.bottom).abs();
    final distLeft = (point.dx - bounds.left).abs();

    final minDist = [distTop, distRight, distBottom, distLeft].reduce(min);

    if (minDist == distTop) {
      return Offset(point.dx.clamp(bounds.left, bounds.right), bounds.top);
    } else if (minDist == distRight) {
      return Offset(bounds.right, point.dy.clamp(bounds.top, bounds.bottom));
    } else if (minDist == distBottom) {
      return Offset(point.dx.clamp(bounds.left, bounds.right), bounds.bottom);
    } else {
      return Offset(bounds.left, point.dy.clamp(bounds.top, bounds.bottom));
    }
  }
}
