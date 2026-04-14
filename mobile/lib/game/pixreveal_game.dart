import 'dart:math' show sin, cos, sqrt, pi;
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'game_grid.dart';
import 'components/player.dart';
import 'components/background_image.dart';
import 'components/hud.dart';
import 'components/powerups.dart';
import '../services/audio_service.dart';
import 'enemies/enemy_base.dart';
import 'enemies/spider.dart';
import 'levels/level_config.dart';
import 'utils/game_constants.dart';

enum PixGameState { playing, paused, won, lost, ready }

class PixRevealGame extends FlameGame with KeyboardEvents {
  late GameGrid grid;
  late Player player;
  late BackgroundImage backgroundImage;
  late Hud hud;
  late Rect gameBounds;

  final List<EnemyBase> enemies = [];
  final LevelConfig levelConfig;
  int lives;
  PixGameState gameState = PixGameState.ready;

  double _moveTimer = 0;
  // Base intervals (adjusted per-direction for uniform pixel speed)
  // Slower player = harder game
  static const double _baseBorderInterval = 1.0 / 25;
  static const double _baseDrawInterval = 1.0 / 35;
  double _clockTimer = 0;
  int _elapsedSeconds = 0;
  double _borderGlow = 0;
  int _score = 0;
  int _combo = 0;

  // Ordered trail path for thin-line rendering
  final List<(int, int)> _trailPath = [];

  // Power-ups
  final PowerUpManager powerUps = PowerUpManager();



  Function(double captured, int stars)? onWin;
  Function()? onLose;
  Function(int lives)? onLifeLost;

  double get capturedPercent => grid.percent;

  int _tokens;
  final String imageFile;
  PixRevealGame({required this.levelConfig, required this.lives, int tokens = 0,
    this.imageFile = 'level_1.jpg'}) : _tokens = tokens;

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final hudH = GameConstants.hudHeight;
    // Game area with padding — leaves room for border glow + safe area
    gameBounds = Rect.fromLTWH(
      4,
      hudH + 2,
      size.x - 8,
      size.y - hudH - 6,
    );

    backgroundImage = BackgroundImage(gameBounds: gameBounds, imageFile: imageFile);
    add(backgroundImage);

    grid = GameGrid(bounds: gameBounds);
    grid.levelId = levelConfig.id;
    add(grid);

    final startCol = GameGrid.gridCols ~/ 2;
    final startRow = GameGrid.gridRows - 1; // bottom border
    // Dynamic player size — scaled to ~4 cells, clamped 12-22
    final cellMin = grid.cellW < grid.cellH ? grid.cellW : grid.cellH;
    final playerSize = (cellMin * 4).clamp(12.0, 22.0);
    player = Player(col: startCol, row: startRow, size: playerSize);
    final sp = grid.center(startCol, startRow);
    player.position = Vector2(sp.dx, sp.dy);
    add(player);

    hud = Hud(gameWidth: size.x);
    hud.lives = lives;
    hud.level = levelConfig.id;
    hud.tokens = _tokens;
    add(hud);

    for (int i = 0; i < levelConfig.enemyCount; i++) {
      final spider = Spider(gameBounds: gameBounds, speedMultiplier: levelConfig.enemySpeedMultiplier);
      spider.gameGrid = grid; // pass grid reference for movement constraint
      enemies.add(spider);
      add(spider);
    }

    // Spawn 2-4 power-ups scattered in empty cells
    powerUps.spawnInitial(
      (c, r) => grid.get(c, r) == CellState.empty,
      GameGrid.gridCols,
      GameGrid.gridRows,
    );

    gameState = PixGameState.playing;
  }

  void handleDirection(MoveDirection dir) {
    if (gameState != PixGameState.playing || dir == MoveDirection.none) return;
    player.direction = dir;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (gameState != PixGameState.playing) return KeyEventResult.ignored;
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final k = event.logicalKey;
      MoveDirection? d;
      if (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.keyW) d = MoveDirection.up;
      if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.keyS) d = MoveDirection.down;
      if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) d = MoveDirection.left;
      if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.keyD) d = MoveDirection.right;
      if (d != null) handleDirection(d);
    }
    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    if (gameState != PixGameState.playing) return;
    super.update(dt);

    _borderGlow += dt * 3;
    _clockTimer += dt;
    if (_clockTimer >= 1.0) { _clockTimer -= 1.0; _elapsedSeconds++; hud.elapsedSeconds = _elapsedSeconds; }

    // Power-ups — update only (collect happens on capture)
    powerUps.update(dt);
    hud.activeEffects = List.from(powerUps.effects);
    hud.activePowerUp = powerUps.effects.isNotEmpty ? powerUps.effects.first : null;

    // Enemy AI — pass trail info for smart chasing (skip if frozen)
    final frozen = powerUps.hasEffect(PowerUpType.freeze);
    for (final e in enemies) {
      if (frozen) {
        e.velocity = Vector2.zero();
        continue;
      }
      e.isChasing = player.isDrawing;
      if (player.isDrawing) {
        e.chaseTarget = player.position.clone();
        final spider = e is Spider ? e : null;
        spider?.trailCells = List.from(_trailPath);
      } else {
        final spider = e is Spider ? e : null;
        spider?.trailCells = [];
      }
    }

    // Player movement (grid ticks, speed-corrected for non-square cells)
    if (player.direction != MoveDirection.none) {
      final baseInterval = player.isDrawing ? _baseDrawInterval : _baseBorderInterval;
      // Adjust for cell aspect ratio: horizontal cells are wider → need more time
      final isHorizontal = player.direction == MoveDirection.left ||
                           player.direction == MoveDirection.right;
      final ratio = isHorizontal ? grid.cellW / grid.cellH : 1.0;
      final interval = baseInterval * ratio;
      _moveTimer += dt;
      while (_moveTimer >= interval) {
        _moveTimer -= interval;
        _tick();
        if (gameState != PixGameState.playing) return;
      }
    }

    // Enemy vs trail/player collision (only while drawing)
    if (player.isDrawing) {
      for (final e in enemies) {
        final (ec, er) = grid.toGrid(e.position.x, e.position.y);
        if (grid.touchesTrail(ec, er)) { _die(); return; }
        final dx = e.position.x - player.position.x;
        final dy = e.position.y - player.position.y;
        if (sqrt(dx * dx + dy * dy) < e.radius + GameConstants.playerSize / 2) {
          _die(); return;
        }
      }
    }
  }

  void _unstickPlayer() {
    // Teleport to nearest BORDER cell
    double bestDist = double.infinity;
    int bestC = GameGrid.gridCols ~/ 2, bestR = GameGrid.gridRows - 1;
    for (int r = 0; r < GameGrid.gridRows; r++) {
      for (int c = 0; c < GameGrid.gridCols; c++) {
        if (grid.get(c, r) == CellState.border) {
          final dx = (c - player.col).toDouble();
          final dy = (r - player.row).toDouble();
          final d = dx * dx + dy * dy;
          if (d < bestDist) { bestDist = d; bestC = c; bestR = r; }
        }
      }
    }
    _movePlayer(bestC, bestR);
  }

  // ---- TICK: one grid step ----

  void _tick() {
    final dir = player.direction;
    if (dir == MoveDirection.none) return;

    int nc = player.col, nr = player.row;
    switch (dir) {
      case MoveDirection.up: nr--;
      case MoveDirection.down: nr++;
      case MoveDirection.left: nc--;
      case MoveDirection.right: nc++;
      case MoveDirection.none: return;
    }

    if (nc < 0 || nc >= GameGrid.gridCols || nr < 0 || nr >= GameGrid.gridRows) return;

    final target = grid.get(nc, nr);

    // Check if player can move to target — if not in drawing mode and target is invalid,
    // verify that player isn't truly stuck before just blocking.
    if (!player.isDrawing) {
      final canGoTarget = target == CellState.border ||
          (target == CellState.claimed && grid.isWalkable(nc, nr)) ||
          target == CellState.empty;

      if (!canGoTarget) {
        // Check if player has ANY valid move from current cell
        bool hasAnyMove = false;
        for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
          final tc = player.col + dc, tr = player.row + dr;
          if (tc < 0 || tc >= GameGrid.gridCols || tr < 0 || tr >= GameGrid.gridRows) continue;
          final ts = grid.get(tc, tr);
          if (ts == CellState.border || ts == CellState.empty ||
              (ts == CellState.claimed && grid.isWalkable(tc, tr))) {
            hasAnyMove = true;
            break;
          }
        }
        if (!hasAnyMove) {
          // Truly stuck — teleport to nearest border
          _unstickPlayer();
          return;
        }
        // Has other moves, just can't go this direction — wait for new input
        return;
      }
    }

    if (!player.isDrawing) {
      // === SAFE MODE: walk on borders and claimed EDGES ===
      if (target == CellState.border) {
        _movePlayer(nc, nr);
      } else if (target == CellState.claimed && grid.isWalkable(nc, nr)) {
        _movePlayer(nc, nr);
      } else if (target == CellState.empty) {
        // Enter unclaimed territory → START DRAWING
        player.isDrawing = true;
        _trailPath.clear();
        _trailPath.add((player.col, player.row));
        _movePlayer(nc, nr);
        grid.set(nc, nr, CellState.trail);
        _trailPath.add((nc, nr));
      }
      // Interior claimed: BLOCKED
    } else {
      // === DRAWING MODE ===

      // FIRST: check if player is backtracking along their own trail
      if (_trailPath.length >= 2) {
        final prev = _trailPath[_trailPath.length - 2];
        if (prev.$1 == nc && prev.$2 == nr) {
          // BACKTRACK: erase current trail cell, move back
          final cur = _trailPath.removeLast();
          grid.set(cur.$1, cur.$2, CellState.empty);
          _movePlayer(nc, nr);
          // If backtracked to start (safe cell), cancel trail entirely
          if (_trailPath.length <= 1) {
            _trailPath.clear();
            player.isDrawing = false;
          }
          return;
        }
      }

      // THEN: normal movement
      if (target == CellState.trail) {
        // Can't cross own trail at non-previous points
        return;
      } else if (target == CellState.empty) {
        _movePlayer(nc, nr);
        grid.set(nc, nr, CellState.trail);
        _trailPath.add((nc, nr));
      } else if (target == CellState.border || target == CellState.claimed) {
        // Reached safe ground → CAPTURE
        _movePlayer(nc, nr);
        player.isDrawing = false;
        player.direction = MoveDirection.none; // STOP after capture
        _moveTimer = 0;
        _capture();
        _trailPath.clear();
      }
    }
  }

  void _movePlayer(int c, int r) {
    player.moveTo(c, r, grid.center(c, r));
  }

  void _capture() {
    final prevPct = grid.percent;
    final ePos = <(int, int)>[];
    for (final e in enemies) {
      ePos.add(grid.toGrid(e.position.x, e.position.y));
    }
    grid.capture(ePos);

    AudioService.play('capture');

    // Auto-collect power-ups that fall inside the newly claimed area
    final collected = powerUps.collectInClaimedRegion(grid.lastClaimed);
    for (final pu in collected) {
      final sec = pu.duration.toInt();
      switch (pu.type) {
        case PowerUpType.freeze:
          hud.showPowerUpAnnouncement(
            'FREEZE!',
            'Enemies frozen for ${sec}s',
            const Color(0xFF00DDFF),
          );
        case PowerUpType.speed:
          hud.showPowerUpAnnouncement(
            'SPEED BOOST!',
            'Super speed for ${sec}s',
            const Color(0xFFFFDD00),
          );
        case PowerUpType.shield:
          hud.showPowerUpAnnouncement(
            'SHIELD!',
            'Saves you from 1 death',
            const Color(0xFF00FF88),
          );
      }
    }

    final pct = grid.percent;
    hud.capturedPercent = pct;

    final areaCaptured = pct - prevPct;
    _combo++;
    final areaPoints = (areaCaptured * 10000).toInt();
    final comboBonus = _combo > 1 ? (areaPoints * 0.5 * (_combo - 1)).toInt() : 0;
    _score += areaPoints + comboBonus;
    hud.score = _score;

    // Score + text popup
    final totalPoints = areaPoints + comboBonus;
    if (_combo > 1) {
      hud.showPopup('x$_combo COMBO! +$totalPoints');
    } else if (areaCaptured > 0.20) {
      hud.showPopup('EXCELLENT! +$totalPoints');
    } else if (areaCaptured > 0.10) {
      hud.showPopup('GREAT! +$totalPoints');
    } else {
      hud.showPopup('+$totalPoints');
    }

    if (pct >= GameConstants.winThreshold) {
      gameState = PixGameState.won;
      final stars = pct >= 0.95 ? 3 : pct >= 0.90 ? 2 : 1;
      onWin?.call(pct, stars);
    } else {
      _checkAccessibility();
    }
  }

  /// After capture, verify player can still reach EMPTY cells.
  /// If not, teleport to nearest walkable cell that borders EMPTY.
  void _checkAccessibility() {
    final visited = <int>{};
    final queue = <int>[];
    final startKey = player.row * GameGrid.gridCols + player.col;
    visited.add(startKey);
    queue.add(startKey);
    bool canReach = false;

    while (queue.isNotEmpty) {
      final k = queue.removeAt(0);
      final r = k ~/ GameGrid.gridCols;
      final c = k % GameGrid.gridCols;
      for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
        final nc = c + dc, nr = r + dr;
        if (nc < 0 || nc >= GameGrid.gridCols || nr < 0 || nr >= GameGrid.gridRows) continue;
        final nk = nr * GameGrid.gridCols + nc;
        if (visited.contains(nk)) continue;
        final s = grid.get(nc, nr);
        if (s == CellState.empty) { canReach = true; break; }
        if (s == CellState.border || (s == CellState.claimed && grid.isWalkable(nc, nr))) {
          visited.add(nk);
          queue.add(nk);
        }
      }
      if (canReach) break;
    }

    if (!canReach) {
      // Find nearest walkable cell that has an EMPTY neighbor
      double bestD = double.infinity;
      int bestC = player.col, bestR = player.row;
      for (int r = 0; r < GameGrid.gridRows; r++) {
        for (int c = 0; c < GameGrid.gridCols; c++) {
          final s = grid.get(c, r);
          if (s != CellState.border && !(s == CellState.claimed && grid.isWalkable(c, r))) continue;
          bool hasEmpty = false;
          for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
            if (grid.get(c + dc, r + dr) == CellState.empty) { hasEmpty = true; break; }
          }
          if (!hasEmpty) continue;
          final dx = (c - player.col).toDouble();
          final dy = (r - player.row).toDouble();
          final d = dx * dx + dy * dy;
          if (d < bestD) { bestD = d; bestC = c; bestR = r; }
        }
      }
      _movePlayer(bestC, bestR);
      hud.showPopup('TELEPORT!');
    }
  }

  void _die() {
    // Shield protects from one death
    if (powerUps.consumeShield()) {
      grid.clearTrail();
      _trailPath.clear();
      player.isDrawing = false;
      hud.showPopup('SHIELD!');
      return;
    }

    AudioService.play('die');

    grid.clearTrail();
    _trailPath.clear();
    player.isDrawing = false;
    player.direction = MoveDirection.none;
    _moveTimer = 0;
    _combo = 0;

    final sc = GameGrid.gridCols ~/ 2;
    _movePlayer(sc, GameGrid.gridRows - 1);

    lives--;
    hud.lives = lives;
    onLifeLost?.call(lives);
    if (lives <= 0) { gameState = PixGameState.lost; onLose?.call(); }
  }

  // ---- POWER-UP ICONS ----
  void _drawPowerUpIcon(Canvas canvas, double cx, double cy, double radius,
      PowerUpType type, Color color) {
    // Outer glow
    canvas.drawCircle(Offset(cx, cy), radius * 1.6, Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Dark background circle
    canvas.drawCircle(Offset(cx, cy), radius, Paint()
      ..color = const Color(0xDD000018));
    canvas.drawCircle(Offset(cx, cy), radius, Paint()
      ..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Draw icon based on type
    switch (type) {
      case PowerUpType.freeze: _drawSnowflake(canvas, cx, cy, radius * 0.7, color);
      case PowerUpType.speed: _drawLightning(canvas, cx, cy, radius * 0.7, color);
      case PowerUpType.shield: _drawShield(canvas, cx, cy, radius * 0.7, color);
    }
  }

  void _drawSnowflake(Canvas canvas, double cx, double cy, double r, Color color) {
    final paint = Paint()
      ..color = color..strokeWidth = 1.8..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // 6 arms
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final ex = cx + cos(a) * r;
      final ey = cy + sin(a) * r;
      canvas.drawLine(Offset(cx, cy), Offset(ex, ey), paint);
      // Branches
      final b1x = cx + cos(a) * r * 0.6;
      final b1y = cy + sin(a) * r * 0.6;
      final ba1 = a + 0.6, ba2 = a - 0.6;
      canvas.drawLine(Offset(b1x, b1y),
        Offset(b1x + cos(ba1) * r * 0.3, b1y + sin(ba1) * r * 0.3), paint);
      canvas.drawLine(Offset(b1x, b1y),
        Offset(b1x + cos(ba2) * r * 0.3, b1y + sin(ba2) * r * 0.3), paint);
    }
    canvas.drawCircle(Offset(cx, cy), 1.8, Paint()..color = const Color(0xFFFFFFFF));
  }

  void _drawLightning(Canvas canvas, double cx, double cy, double r, Color color) {
    final path = Path()
      ..moveTo(cx - r * 0.3, cy - r)
      ..lineTo(cx + r * 0.4, cy - r * 0.15)
      ..lineTo(cx - r * 0.1, cy - r * 0.15)
      ..lineTo(cx + r * 0.4, cy + r)
      ..lineTo(cx - r * 0.4, cy + r * 0.1)
      ..lineTo(cx + r * 0.1, cy + r * 0.1)
      ..close();
    canvas.drawPath(path, Paint()
      ..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(path, Paint()
      ..color = color..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  void _drawShield(Canvas canvas, double cx, double cy, double r, Color color) {
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.75, cy - r * 0.6)
      ..lineTo(cx + r * 0.75, cy + r * 0.2)
      ..quadraticBezierTo(cx + r * 0.75, cy + r * 0.8, cx, cy + r)
      ..quadraticBezierTo(cx - r * 0.75, cy + r * 0.8, cx - r * 0.75, cy + r * 0.2)
      ..lineTo(cx - r * 0.75, cy - r * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawPath(path, Paint()
      ..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    // Inner checkmark
    final check = Path()
      ..moveTo(cx - r * 0.3, cy)
      ..lineTo(cx - r * 0.05, cy + r * 0.25)
      ..lineTo(cx + r * 0.35, cy - r * 0.25);
    canvas.drawPath(check, Paint()
      ..color = const Color(0xFFFFFFFF)..style = PaintingStyle.stroke..strokeWidth = 2
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  // ---- RENDERING ----

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Trail: thin neon line with danger warning
    if (_trailPath.length >= 2) {
      // Check if any enemy is close to trail → warning mode
      bool danger = false;
      if (player.isDrawing) {
        for (final e in enemies) {
          for (final (tc, tr) in _trailPath) {
            final tp = grid.center(tc, tr);
            final dx = e.position.x - tp.dx;
            final dy = e.position.y - tp.dy;
            if (dx * dx + dy * dy < 80 * 80) { danger = true; break; }
          }
          if (danger) break;
        }
      }

      final path = Path();
      final first = grid.center(_trailPath[0].$1, _trailPath[0].$2);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < _trailPath.length; i++) {
        final p = grid.center(_trailPath[i].$1, _trailPath[i].$2);
        path.lineTo(p.dx, p.dy);
      }

      // Trail color matches level (complementary to overlay)
      final baseTrail = grid.trailColor;
      final trailCol = danger
          ? Color.lerp(baseTrail, const Color(0xFFFF0000),
              (sin(_borderGlow * 6) + 1) * 0.5)!
          : baseTrail;
      final glowCol = danger
          ? const Color(0x66FF0000)
          : baseTrail.withValues(alpha: 0.4);

      canvas.drawPath(path, Paint()
        ..color = glowCol
        ..style = PaintingStyle.stroke..strokeWidth = 5
        ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawPath(path, Paint()
        ..color = trailCol
        ..style = PaintingStyle.stroke..strokeWidth = 2
        ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    }

    // Power-ups (visible icons in claimed area)
    for (final pu in powerUps.active) {
      final pos = grid.center(pu.col, pu.row);
      final pulse = 1.0 + sin(pu.pulse) * 0.12;
      _drawPowerUpIcon(canvas, pos.dx, pos.dy, 16 * pulse, pu.type, pu.color);
    }

    // Neon border
    final gi = 0.3 + sin(_borderGlow) * 0.15;
    final br = gameBounds.inflate(3);
    canvas.drawRect(br, Paint()
      ..color = GameConstants.borderGlowColor.withValues(alpha: gi)
      ..style = PaintingStyle.stroke..strokeWidth = GameConstants.borderGlowWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRect(br, Paint()
      ..color = GameConstants.borderColor
      ..style = PaintingStyle.stroke..strokeWidth = GameConstants.borderWidth);

    for (final c in [br.topLeft, br.topRight, br.bottomLeft, br.bottomRight]) {
      final dx = c.dx < br.center.dx ? 1.0 : -1.0;
      final dy = c.dy < br.center.dy ? 1.0 : -1.0;
      final cp = Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawLine(c, Offset(c.dx + 12 * dx, c.dy), cp);
      canvas.drawLine(c, Offset(c.dx, c.dy + 12 * dy), cp);
    }

  }

  void pauseGame() { if (gameState == PixGameState.playing) gameState = PixGameState.paused; }
  void resumeGame() { if (gameState == PixGameState.paused) gameState = PixGameState.playing; }
  int get elapsedSeconds => _elapsedSeconds;
}
