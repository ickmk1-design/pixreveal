import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'enemy_base.dart';

class Spider extends EnemyBase {
  double _dirTimer = 0;
  double _nextDir = 2.0;
  double _wobble = 0;

  List<(int, int)> trailCells = [];
  ui.Offset? _trailTarget;
  ui.Image? _sprite;

  Spider({required super.gameBounds, super.speedMultiplier})
      : super(speed: 400, radius: 40, chaseIntensity: 0.95);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spawnRandom();
    final a = rng.nextDouble() * 2 * pi;
    velocity = Vector2(cos(a), sin(a)) * speed;
    try {
      _sprite = await Flame.images.load('spider.png');
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    _wobble += dt * 6;

    if (isChasing) {
      final cs = speed * 1.5; // chase = 600 px/sec
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
  void render(ui.Canvas canvas) {
    final cx = radius, cy = radius;
    final wobble = sin(_wobble) * 1.5;
    final chasing = isChasing;

    if (_sprite != null) {
      // Aura glow
      final auraR = chasing ? radius * 1.4 : radius * 1.1;
      final auraA = chasing ? 0.5 : 0.25;
      canvas.drawCircle(ui.Offset(cx, cy + wobble), auraR, ui.Paint()
        ..color = ui.Color.fromARGB((auraA * 255).toInt(), 255, 0, 68)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, chasing ? 16.0 : 8.0));

      // Sprite
      final spriteSize = radius * 2.4;
      final src = ui.Rect.fromLTWH(0, 0,
          _sprite!.width.toDouble(), _sprite!.height.toDouble());
      final dst = ui.Rect.fromCenter(
        center: ui.Offset(cx, cy + wobble),
        width: spriteSize, height: spriteSize,
      );
      final paint = ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..isAntiAlias = true;
      canvas.drawImageRect(_sprite!, src, dst, paint);

      // Chase indicator
      if (chasing) {
        final flash = (sin(_wobble * 4) + 1) * 0.5;
        canvas.drawCircle(ui.Offset(cx, cy - radius * 1.1), 6, ui.Paint()
          ..color = ui.Color.fromARGB((flash * 220).toInt(), 255, 30, 30)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6));
      }
    } else {
      // Fallback red circle
      canvas.drawCircle(ui.Offset(cx, cy + wobble), radius * 0.8, ui.Paint()
        ..color = const ui.Color(0xFFCC0033));
    }
  }
}
