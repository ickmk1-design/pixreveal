import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/territory_calculator.dart';

class Territory extends Component {
  final List<List<Offset>> capturedPolygons = [];
  final Rect gameBounds;
  double _capturedPercent = 0;

  Territory({required this.gameBounds});

  double get capturedPercent => _capturedPercent;

  double get totalArea => gameBounds.width * gameBounds.height;

  void addCapture(List<Offset> trailPoints) {
    if (trailPoints.length < 3) return;

    // Build the capture polygon using trail + border path
    final polygon = TerritoryCalculator.buildCapturePolygon(
      trailPoints,
      gameBounds,
      TerritoryCalculator.shorterBorderPath,
    );

    if (polygon.length >= 3) {
      capturedPolygons.add(polygon);
      _recalculatePercent();
    }
  }

  void _recalculatePercent() {
    _capturedPercent =
        TerritoryCalculator.capturedPercent(capturedPolygons, totalArea);
  }

  bool isPointCaptured(Offset point) {
    return TerritoryCalculator.isPointCaptured(point, capturedPolygons);
  }

  void reset() {
    capturedPolygons.clear();
    _capturedPercent = 0;
  }

  @override
  void render(Canvas canvas) {
    // Draw uncaptured area as dark overlay
    // The captured areas become transparent to reveal the image
    final overlayPaint = Paint()
      ..color = const Color(0xDD1A1A2E)
      ..style = PaintingStyle.fill;

    // Start with full rectangle
    final fullPath = Path()
      ..addRect(gameBounds);

    // Cut out captured areas
    for (final polygon in capturedPolygons) {
      if (polygon.length < 3) continue;
      final capturePath = Path()..moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        capturePath.lineTo(polygon[i].dx, polygon[i].dy);
      }
      capturePath.close();
      fullPath.addPath(capturePath, Offset.zero);
    }

    // Use evenOdd fill to cut out captured areas
    fullPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(fullPath, overlayPaint);

    // Draw border of captured areas
    final borderPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final polygon in capturedPolygons) {
      if (polygon.length < 3) continue;
      final path = Path()..moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        path.lineTo(polygon[i].dx, polygon[i].dy);
      }
      path.close();
      canvas.drawPath(path, borderPaint);
    }
  }
}
