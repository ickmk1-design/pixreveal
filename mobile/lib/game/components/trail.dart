import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constants.dart';

class Trail extends Component {
  final List<Offset> points = [];
  bool isActive = false;

  void start(Offset startPoint) {
    points.clear();
    points.add(startPoint);
    isActive = true;
  }

  void addPoint(Offset point) {
    if (!isActive) return;
    // Only add if moved enough distance
    if (points.isEmpty || (points.last - point).distance > 2) {
      points.add(point);
    }
  }

  List<Offset> finish(Offset endPoint) {
    if (!isActive) return [];
    points.add(endPoint);
    isActive = false;
    return List.from(points);
  }

  void cancel() {
    points.clear();
    isActive = false;
  }

  @override
  void render(Canvas canvas) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = GameConstants.trailColor
      ..strokeWidth = GameConstants.trailWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Neon glow
    final glowPaint = Paint()
      ..color = GameConstants.trailColor.withValues(alpha: 0.4)
      ..strokeWidth = GameConstants.trailWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);
  }
}
