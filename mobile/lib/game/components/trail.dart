import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constants.dart';

class Trail extends Component {
  final List<Offset> points = [];
  bool isActive = false;

  // Particle effects along trail
  final List<_LaserParticle> _particles = [];
  final Random _rng = Random();
  double _pulsePhase = 0;

  void start(Offset startPoint) {
    points.clear();
    points.add(startPoint);
    isActive = true;
    _particles.clear();
  }

  void addPoint(Offset point) {
    if (!isActive) return;
    if (points.isEmpty || (points.last - point).distance > 2) {
      points.add(point);
      // Spawn particles along new segment
      _spawnParticlesAt(point);
    }
  }

  void _spawnParticlesAt(Offset point) {
    for (int i = 0; i < 2; i++) {
      _particles.add(_LaserParticle(
        x: point.dx + (_rng.nextDouble() - 0.5) * 8,
        y: point.dy + (_rng.nextDouble() - 0.5) * 8,
        vx: (_rng.nextDouble() - 0.5) * 20,
        vy: (_rng.nextDouble() - 0.5) * 20,
        life: 0.5 + _rng.nextDouble() * 0.5,
        size: 1.5 + _rng.nextDouble() * 2,
      ));
    }
  }

  List<Offset> finish(Offset endPoint) {
    if (!isActive) return [];
    points.add(endPoint);
    isActive = false;
    final result = List<Offset>.from(points);
    return result;
  }

  void cancel() {
    points.clear();
    isActive = false;
    _particles.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulsePhase += dt * 6;

    _particles.removeWhere((p) {
      p.life -= dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      return p.life <= 0;
    });
  }

  @override
  void render(Canvas canvas) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final pulse = 0.6 + sin(_pulsePhase) * 0.4;

    // Wide outer glow
    final outerGlow = Paint()
      ..color = GameConstants.trailGlowColor.withValues(alpha: 0.2 * pulse)
      ..strokeWidth = GameConstants.trailGlowWidth + 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, outerGlow);

    // Inner glow
    final innerGlow = Paint()
      ..color = GameConstants.trailColor.withValues(alpha: 0.5 * pulse)
      ..strokeWidth = GameConstants.trailGlowWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, innerGlow);

    // Core laser line
    final corePaint = Paint()
      ..color = GameConstants.trailColor
      ..strokeWidth = GameConstants.trailWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, corePaint);

    // Bright white center
    final whitePaint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, whitePaint);

    // Draw particles
    for (final p in _particles) {
      final alpha = (p.life / 1.0).clamp(0.0, 1.0);
      final pPaint = Paint()
        ..color = GameConstants.trailColor.withValues(alpha: alpha * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x, p.y), p.size * alpha, pPaint);
    }

    // Glowing dot at trail head (last point)
    if (isActive && points.isNotEmpty) {
      final head = points.last;
      final headGlow = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(head.dx, head.dy), 4, headGlow);
      canvas.drawCircle(
        Offset(head.dx, head.dy),
        2.5,
        Paint()..color = GameConstants.trailColor,
      );
    }
  }
}

class _LaserParticle {
  double x, y, vx, vy, life, size;
  _LaserParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
  });
}
