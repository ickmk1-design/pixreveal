import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'enemy_base.dart';

class Spider extends EnemyBase {
  double _dirTimer = 0;
  double _nextDir = 2.0;
  double _walk = 0;
  double _eyeBlink = 0;

  List<(int, int)> trailCells = [];
  Offset? _trailTarget;

  Spider({required super.gameBounds, super.speedMultiplier})
      : super(speed: 350, radius: 28, chaseIntensity: 0.9);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spawnRandom();
    final a = rng.nextDouble() * 2 * pi;
    velocity = Vector2(cos(a), sin(a)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _walk += dt * velocity.length * 0.06;
    _eyeBlink += dt * 3;

    if (isChasing) {
      final cs = speed * 2.0;
      _updateTrailTarget();
      final t = (_trailTarget != null && rng.nextDouble() < 0.5)
          ? Vector2(_trailTarget!.dx, _trailTarget!.dy) : chaseTarget;
      final d = t - position;
      if (d.length > 1) {
        velocity = velocity + (d.normalized() * cs - velocity) * (chaseIntensity * dt * 4);
        if (velocity.length > cs) velocity = velocity.normalized() * cs;
      }
    } else {
      _dirTimer += dt;
      if (_dirTimer >= _nextDir) {
        _dirTimer = 0;
        _nextDir = 1.0 + rng.nextDouble() * 2.0;
        final a = rng.nextDouble() * 2 * pi;
        velocity = Vector2(cos(a), sin(a)) * speed;
      }
    }
    position += velocity * dt;
    bounceOffWalls();
  }

  void _updateTrailTarget() {
    if (trailCells.isEmpty || gameGrid == null) { _trailTarget = null; return; }
    double best = double.infinity;
    (int, int)? bp;
    for (final (tc, tr) in trailCells) {
      final tp = gameGrid!.center(tc, tr);
      final dx = tp.dx - position.x, dy = tp.dy - position.y;
      final d = dx * dx + dy * dy;
      if (d < best) { best = d; bp = (tc, tr); }
    }
    _trailTarget = bp != null ? gameGrid!.center(bp.$1, bp.$2) : null;
  }

  @override
  void render(Canvas canvas) {
    final cx = radius, cy = radius;
    final chasing = this.isChasing;

    // --- SHADOW ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 22), width: 36, height: 8),
      Paint()..color = const Color(0x33000000));

    // --- 8 LEGS (4 per side, 3-segment bezier curves, animated) ---
    for (int side = 0; side < 2; side++) {
      final s = side == 0 ? -1.0 : 1.0;
      for (int i = 0; i < 4; i++) {
        final phase = _walk + i * 0.8 + side * 1.5;
        final lift = sin(phase) * 3;
        final swing = sin(phase) * 0.2;

        // Leg angles spread from body
        final baseA = (-0.7 + i * 0.45) + swing;

        // Segment 1: body → knee
        final k1x = cx + s * cos(baseA) * 16;
        final k1y = cy + sin(baseA) * 10 + i * 1.5 - 2 + lift * 0.3;

        // Segment 2: knee → ankle
        final k2a = baseA + s * 0.7;
        final k2x = k1x + s * cos(k2a) * 14;
        final k2y = k1y + sin(k2a) * 8 + 4 - lift;

        // Segment 3: ankle → foot (touches ground)
        final footX = k2x + s * 4;
        final footY = k2y + 5;

        final legP = Paint()
          ..color = const Color(0xFF2A1A10)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        // Draw 3 segments
        canvas.drawLine(Offset(cx + s * 5, cy + i * 2 - 1), Offset(k1x, k1y), legP);
        canvas.drawLine(Offset(k1x, k1y), Offset(k2x, k2y), legP);
        canvas.drawLine(Offset(k2x, k2y), Offset(footX, footY),
          legP..strokeWidth = 1.8);

        // Joint dots
        canvas.drawCircle(Offset(k1x, k1y), 1.8,
          Paint()..color = const Color(0xFF3A2818));
        canvas.drawCircle(Offset(k2x, k2y), 1.5,
          Paint()..color = const Color(0xFF3A2818));
      }
    }

    // --- ABDOMEN (large oval, black) ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 5), width: 30, height: 24),
      Paint()..color = const Color(0xFF1A1010));
    // Abdomen highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 3, cy + 2), width: 12, height: 10),
      Paint()..color = const Color(0xFF2A2018));
    // Abdomen markings (2 lines)
    canvas.drawLine(Offset(cx - 5, cy + 2), Offset(cx + 5, cy + 2),
      Paint()..color = const Color(0xFF332818)..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx - 4, cy + 6), Offset(cx + 4, cy + 6),
      Paint()..color = const Color(0xFF332818)..strokeWidth = 1.2);

    // --- HEAD (smaller oval, dark grey) ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 8), width: 16, height: 13),
      Paint()..color = const Color(0xFF2A1E15));
    // Head highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy - 10), width: 6, height: 5),
      Paint()..color = const Color(0xFF3A2E22));

    // --- EYES (2 red circles with white glint) ---
    final eyeGlow = 0.6 + sin(_eyeBlink) * 0.4;
    final eyeColor = chasing
        ? Color.fromARGB(255, 255, (30 * (1 - eyeGlow)).toInt(), 0)
        : Color.fromARGB(255, (200 * eyeGlow).toInt(), 0, 0);

    // Left eye
    canvas.drawCircle(Offset(cx - 4, cy - 9), 3.5, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(cx - 5, cy - 10), 1.2,
      Paint()..color = Color.fromARGB((eyeGlow * 255).toInt(), 255, 255, 255));

    // Right eye
    canvas.drawCircle(Offset(cx + 4, cy - 9), 3.5, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(cx + 3, cy - 10), 1.2,
      Paint()..color = Color.fromARGB((eyeGlow * 255).toInt(), 255, 255, 255));

    // Eye glow effect
    if (chasing) {
      canvas.drawCircle(Offset(cx - 4, cy - 9), 6, Paint()
        ..color = Color.fromARGB((eyeGlow * 60).toInt(), 255, 0, 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(cx + 4, cy - 9), 6, Paint()
        ..color = Color.fromARGB((eyeGlow * 60).toInt(), 255, 0, 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    // --- CHELICERAE (V-shaped fangs) ---
    canvas.drawLine(Offset(cx - 2, cy - 3), Offset(cx - 4, cy + 1),
      Paint()..color = const Color(0xFFCCBB99)..strokeWidth = 2
        ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + 2, cy - 3), Offset(cx + 4, cy + 1),
      Paint()..color = const Color(0xFFCCBB99)..strokeWidth = 2
        ..strokeCap = StrokeCap.round);

    // --- CHASE INDICATOR ---
    if (chasing) {
      final f = (sin(_eyeBlink * 4) + 1) * 0.5;
      canvas.drawCircle(Offset(cx, cy - 22), 5, Paint()
        ..color = Color.fromARGB((f * 180).toInt(), 255, 30, 30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }
}
