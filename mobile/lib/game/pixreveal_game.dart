import 'dart:math' show sin, sqrt;
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'game_grid.dart';
import 'components/player.dart';
import 'components/background_image.dart';
import 'components/hud.dart';
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
  static const double _borderSpeed = 1.0 / 35; // 35 cells/sec on border
  static const double _drawSpeed = 1.0 / 55;  // 55 cells/sec while drawing
  double _clockTimer = 0;
  int _elapsedSeconds = 0;
  double _borderGlow = 0;
  int _score = 0;
  int _combo = 0;

  // Ordered trail path for thin-line rendering
  final List<(int, int)> _trailPath = [];



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
    // Game area fills entire width, starts right below HUD
    gameBounds = Rect.fromLTWH(
      0,
      hudH,
      size.x,
      size.y - hudH,
    );

    backgroundImage = BackgroundImage(gameBounds: gameBounds, imageFile: imageFile);
    add(backgroundImage);

    grid = GameGrid(bounds: gameBounds);
    grid.levelId = levelConfig.id;
    add(grid);

    final startCol = GameGrid.gridCols ~/ 2;
    final startRow = GameGrid.gridRows - 1; // bottom border
    player = Player(col: startCol, row: startRow);
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

    // Enemy AI — pass trail info for smart chasing
    for (final e in enemies) {
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

    // Player movement (grid ticks)
    if (player.direction != MoveDirection.none) {
      final interval = player.isDrawing ? _drawSpeed : _borderSpeed;
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

  // Check if player is stuck (no valid moves in any direction)
  bool _isPlayerStuck() {
    final c = player.col, r = player.row;
    for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
      final nc = c + dc, nr = r + dr;
      if (nc < 0 || nc >= GameGrid.gridCols || nr < 0 || nr >= GameGrid.gridRows) continue;
      final s = grid.get(nc, nr);
      if (s == CellState.border) return false;
      if (s == CellState.empty) return false;
      if (s == CellState.claimed && grid.isWalkable(nc, nr)) return false;
    }
    return true;
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

    // Anti-stuck: if player has no valid moves, teleport to border
    if (_isPlayerStuck()) {
      _unstickPlayer();
      player.direction = MoveDirection.none;
      return;
    }

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
    }
  }

  void _die() {
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

      // Colors: normal = magenta, danger = red flashing
      final trailCol = danger
          ? Color.lerp(GameConstants.trailColor, const Color(0xFFFF0000),
              (sin(_borderGlow * 6) + 1) * 0.5)!
          : GameConstants.trailColor;
      final glowCol = danger
          ? const Color(0x66FF0000)
          : GameConstants.trailGlowColor;

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
