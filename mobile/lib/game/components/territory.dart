import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/territory_calculator.dart';
import '../utils/game_constants.dart';

class Territory extends Component {
  final List<List<Offset>> capturedPolygons = [];
  final Rect gameBounds;
  double _capturedPercent = 0;

  // Flash animation
  double _flashAlpha = 0;
  List<Offset>? _lastPoly;

  // Capture particles
  final List<_CaptureParticle> _captureParticles = [];
  final Random _rng = Random();

  double _glowPhase = 0;

  Territory({required this.gameBounds});

  double get capturedPercent => _capturedPercent;
  double get totalArea => gameBounds.width * gameBounds.height;

  void addCapture(List<Offset> trailPoints) {
    if (trailPoints.length < 3) return;

    final polygon = TerritoryCalculator.buildCapturePolygon(
      trailPoints, gameBounds, TerritoryCalculator.shorterBorderPath,
    );

    if (polygon.length >= 3) {
      capturedPolygons.add(polygon);
      _recalculatePercent();
      _flashAlpha = 1.0;
      _lastPoly = polygon;

      // Spawn celebration particles along captured polygon edges
      for (int i = 0; i < polygon.length; i++) {
        final p = polygon[i];
        for (int j = 0; j < 3; j++) {
          _captureParticles.add(_CaptureParticle(
            x: p.dx, y: p.dy,
            vx: (_rng.nextDouble() - 0.5) * 60,
            vy: (_rng.nextDouble() - 0.5) * 60,
            life: 0.5 + _rng.nextDouble() * 0.5,
            size: 2 + _rng.nextDouble() * 3,
          ));
        }
      }
    }
  }

  void _recalculatePercent() {
    _capturedPercent = TerritoryCalculator.capturedPercent(capturedPolygons, totalArea);
  }

  bool isPointCaptured(Offset point) {
    return TerritoryCalculator.isPointCaptured(point, capturedPolygons);
  }

  void reset() {
    capturedPolygons.clear();
    _capturedPercent = 0;
    _flashAlpha = 0;
    _lastPoly = null;
    _captureParticles.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _glowPhase += dt * 2;

    if (_flashAlpha > 0) {
      _flashAlpha = (_flashAlpha - dt * 2.0).clamp(0.0, 1.0);
    }

    _captureParticles.removeWhere((p) {
      p.life -= dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 40 * dt; // gravity
      return p.life <= 0;
    });
  }

  @override
  void render(Canvas canvas) {
    // OVERLAY: Dark opaque layer covers the entire game area.
    // Captured polygons are CUT OUT (transparent) → revealing the background image.
    final overlayPaint = Paint()
      ..color = GameConstants.uncapturedColor
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(gameBounds);

    for (final polygon in capturedPolygons) {
      if (polygon.length < 3) continue;
      final cutout = Path()..moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        cutout.lineTo(polygon[i].dx, polygon[i].dy);
      }
      cutout.close();
      fullPath.addPath(cutout, Offset.zero);
    }

    fullPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(fullPath, overlayPaint);

    // Subtle neon border on captured areas (NO trail lines — they're gone)
    final gi = 0.25 + sin(_glowPhase) * 0.1;
    for (final polygon in capturedPolygons) {
      if (polygon.length < 3) continue;
      final path = Path()..moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        path.lineTo(polygon[i].dx, polygon[i].dy);
      }
      path.close();

      canvas.drawPath(path, Paint()
        ..color = GameConstants.borderColor.withValues(alpha: gi * 0.6)
        ..style = PaintingStyle.stroke..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Flash animation
    if (_flashAlpha > 0 && _lastPoly != null) {
      final fp = Path()..moveTo(_lastPoly!.first.dx, _lastPoly!.first.dy);
      for (int i = 1; i < _lastPoly!.length; i++) {
        fp.lineTo(_lastPoly![i].dx, _lastPoly![i].dy);
      }
      fp.close();

      canvas.drawPath(fp, Paint()
        ..color = Color.fromARGB((_flashAlpha * 150).toInt(), 255, 255, 255));

      canvas.drawPath(fp, Paint()
        ..color = Color.fromARGB((_flashAlpha * 255).toInt(), 200, 255, 220)
        ..style = PaintingStyle.stroke..strokeWidth = 3
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * _flashAlpha));
    }

    // Capture particles
    for (final p in _captureParticles) {
      final a = (p.life / 1.0).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(p.x, p.y), p.size * a,
        Paint()..color = Color.fromARGB((a * 200).toInt(), 100, 255, 180)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }
  }
}

class _CaptureParticle {
  double x, y, vx, vy, life, size;
  _CaptureParticle({required this.x, required this.y, required this.vx,
    required this.vy, required this.life, required this.size});
}
