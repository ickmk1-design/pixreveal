import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'components/player.dart';
import 'components/trail.dart';
import 'components/territory.dart';
import 'components/background_image.dart';
import 'components/hud.dart';
import 'enemies/enemy_base.dart';
import 'enemies/spider.dart';
import 'levels/level_config.dart';
import 'utils/game_constants.dart';
import 'utils/collision_detector.dart';

enum PixGameState { playing, paused, won, lost, ready }

class PixRevealGame extends FlameGame with PanDetector, TapCallbacks {
  late Player player;
  late Trail trail;
  late Territory territory;
  late BackgroundImage backgroundImage;
  late Hud hud;
  late Rect gameBounds;

  final List<EnemyBase> enemies = [];
  final LevelConfig levelConfig;
  int lives;
  PixGameState gameState = PixGameState.ready;
  double _timer = 0;
  int _elapsedSeconds = 0;

  // Callbacks to Flutter layer
  Function(double captured, int stars)? onWin;
  Function()? onLose;
  Function(int lives)? onLifeLost;

  // Swipe tracking
  Offset? _panStart;

  PixRevealGame({
    required this.levelConfig,
    required this.lives,
  });

  @override
  Color backgroundColor() => const Color(0xFF0A0A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Game bounds (with HUD offset)
    final hudH = 50.0;
    gameBounds = Rect.fromLTWH(
      GameConstants.borderWidth,
      hudH + GameConstants.borderWidth,
      size.x - GameConstants.borderWidth * 2,
      size.y - hudH - GameConstants.borderWidth * 2,
    );

    // Background image (hidden image to reveal)
    backgroundImage = BackgroundImage(gameBounds: gameBounds);
    add(backgroundImage);

    // Territory manager
    territory = Territory(gameBounds: gameBounds);
    add(territory);

    // Trail
    trail = Trail();
    add(trail);

    // Player starts at top-center of border
    player = Player(
      position: Vector2(gameBounds.center.dx, gameBounds.top),
    );
    player.gameBounds = gameBounds;
    add(player);

    // HUD
    hud = Hud(gameWidth: size.x);
    hud.lives = lives;
    hud.level = levelConfig.id;
    add(hud);

    // Spawn enemies
    _spawnEnemies();

    gameState = PixGameState.playing;
  }

  void _spawnEnemies() {
    for (int i = 0; i < levelConfig.enemyCount; i++) {
      final spider = Spider(
        gameBounds: gameBounds,
        speedMultiplier: levelConfig.enemySpeedMultiplier,
      );
      enemies.add(spider);
      add(spider);
    }
  }

  @override
  void update(double dt) {
    if (gameState != PixGameState.playing) return;
    super.update(dt);

    // Timer
    _timer += dt;
    if (_timer >= 1.0) {
      _timer -= 1.0;
      _elapsedSeconds++;
      hud.elapsedSeconds = _elapsedSeconds;
    }

    // Update trail points while drawing
    if (player.isDrawing && trail.isActive) {
      trail.addPoint(player.centerOffset);

      // Check if player returned to border
      if (trail.points.length > 5 &&
          CollisionDetector.isOnBorder(player.centerOffset, gameBounds, tolerance: 4)) {
        _completeCapture();
      }
    }

    // Check enemy collisions with trail
    if (trail.isActive) {
      for (final enemy in enemies) {
        if (CollisionDetector.circleIntersectsTrail(
          enemy.centerOffset,
          enemy.radius,
          trail.points,
        )) {
          _playerHit();
          break;
        }
      }
    }

    // Check enemy collision with player while drawing
    if (player.isDrawing) {
      for (final enemy in enemies) {
        if (CollisionDetector.playerHitByEnemy(
          player.centerOffset,
          GameConstants.playerSize / 2,
          enemy.centerOffset,
          enemy.radius,
        )) {
          _playerHit();
          break;
        }
      }
    }
  }

  void _completeCapture() {
    final trailPoints = trail.finish(player.centerOffset);
    player.finishDrawing();

    if (trailPoints.length >= 3) {
      territory.addCapture(trailPoints);
      final percent = territory.capturedPercent;
      hud.capturedPercent = percent;

      if (percent >= GameConstants.winThreshold) {
        _win(percent);
      }
    }
  }

  void _playerHit() {
    trail.cancel();
    player.finishDrawing();

    // Reset player to top-center border
    player.position = Vector2(gameBounds.center.dx, gameBounds.top);
    player.stopMoving();

    lives--;
    hud.lives = lives;
    onLifeLost?.call(lives);

    if (lives <= 0) {
      _lose();
    }
  }

  void _win(double captured) {
    gameState = PixGameState.won;
    int stars = 0;
    if (captured >= 0.95) {
      stars = 3;
    } else if (captured >= 0.90) {
      stars = 2;
    } else {
      stars = 1;
    }
    onWin?.call(captured, stars);
  }

  void _lose() {
    gameState = PixGameState.lost;
    onLose?.call();
  }

  // --- Input handling ---

  @override
  void onPanStart(DragStartInfo info) {
    if (gameState != PixGameState.playing) return;
    _panStart = Offset(info.eventPosition.global.x, info.eventPosition.global.y);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (gameState != PixGameState.playing || _panStart == null) return;

    final current = Offset(
      info.eventPosition.global.x,
      info.eventPosition.global.y,
    );
    final delta = current - _panStart!;
    final threshold = 10.0;

    MoveDirection dir;
    if (delta.dx.abs() > delta.dy.abs()) {
      dir = delta.dx > threshold
          ? MoveDirection.right
          : delta.dx < -threshold
              ? MoveDirection.left
              : MoveDirection.none;
    } else {
      dir = delta.dy > threshold
          ? MoveDirection.down
          : delta.dy < -threshold
              ? MoveDirection.up
              : MoveDirection.none;
    }

    if (dir != MoveDirection.none) {
      player.setDirection(dir);

      // Start drawing if moving away from border
      if (player.playerState == PlayerState.onBorder &&
          !CollisionDetector.isOnBorder(
            _predictPosition(dir),
            gameBounds,
            tolerance: 6,
          )) {
        player.startDrawing();
        trail.start(player.centerOffset);
      }
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // Don't stop - player continues in last direction (arcade style)
    // Only stop if on border and not drawing
    if (!player.isDrawing) {
      // Keep moving along border
    }
  }

  void onTapDownEvent(TapDownEvent event) {
    if (gameState != PixGameState.playing) return;
    // Stop movement on tap
    player.stopMoving();
  }

  Offset _predictPosition(MoveDirection dir) {
    final pos = player.centerOffset;
    const step = 8.0;
    switch (dir) {
      case MoveDirection.up:
        return Offset(pos.dx, pos.dy - step);
      case MoveDirection.down:
        return Offset(pos.dx, pos.dy + step);
      case MoveDirection.left:
        return Offset(pos.dx - step, pos.dy);
      case MoveDirection.right:
        return Offset(pos.dx + step, pos.dy);
      case MoveDirection.none:
        return pos;
    }
  }

  void pauseGame() {
    if (gameState == PixGameState.playing) {
      gameState = PixGameState.paused;
    }
  }

  void resumeGame() {
    if (gameState == PixGameState.paused) {
      gameState = PixGameState.playing;
    }
  }

  int get elapsedSeconds => _elapsedSeconds;
}
