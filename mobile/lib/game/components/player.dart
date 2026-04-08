import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constants.dart';
import '../utils/collision_detector.dart';

enum PlayerState { onBorder, drawing }

enum MoveDirection { up, down, left, right, none }

class Player extends PositionComponent {
  PlayerState playerState = PlayerState.onBorder;
  MoveDirection moveDirection = MoveDirection.none;
  final double speed;
  late Rect gameBounds;

  Player({
    required Vector2 position,
    this.speed = GameConstants.playerSpeed,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.playerSize),
          anchor: Anchor.center,
        );

  Offset get centerOffset => Offset(position.x, position.y);

  bool get isDrawing => playerState == PlayerState.drawing;
  bool get isOnBorder =>
      CollisionDetector.isOnBorder(centerOffset, gameBounds, tolerance: 4);

  void setDirection(MoveDirection dir) {
    moveDirection = dir;
  }

  void stopMoving() {
    moveDirection = MoveDirection.none;
  }

  void startDrawing() {
    if (playerState == PlayerState.onBorder) {
      playerState = PlayerState.drawing;
    }
  }

  void finishDrawing() {
    playerState = PlayerState.onBorder;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (moveDirection == MoveDirection.none) return;

    double dx = 0, dy = 0;
    switch (moveDirection) {
      case MoveDirection.up:
        dy = -speed * dt;
      case MoveDirection.down:
        dy = speed * dt;
      case MoveDirection.left:
        dx = -speed * dt;
      case MoveDirection.right:
        dx = speed * dt;
      case MoveDirection.none:
        break;
    }

    final newX = (position.x + dx).clamp(gameBounds.left, gameBounds.right);
    final newY = (position.y + dy).clamp(gameBounds.top, gameBounds.bottom);
    position = Vector2(newX, newY);

    // If drawing and returned to border, signal capture
    if (playerState == PlayerState.drawing && isOnBorder) {
      // snap to border
      final snapped = _snapToBorder(Offset(newX, newY));
      position = Vector2(snapped.dx, snapped.dy);
    }
  }

  Offset _snapToBorder(Offset point) {
    final distTop = (point.dy - gameBounds.top).abs();
    final distRight = (point.dx - gameBounds.right).abs();
    final distBottom = (point.dy - gameBounds.bottom).abs();
    final distLeft = (point.dx - gameBounds.left).abs();

    final minDist = [distTop, distRight, distBottom, distLeft]
        .reduce((a, b) => a < b ? a : b);

    if (minDist == distTop) {
      return Offset(point.dx, gameBounds.top);
    } else if (minDist == distRight) {
      return Offset(gameBounds.right, point.dy);
    } else if (minDist == distBottom) {
      return Offset(point.dx, gameBounds.bottom);
    } else {
      return Offset(gameBounds.left, point.dy);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw diamond shape
    final paint = Paint()
      ..color = GameConstants.playerColor
      ..style = PaintingStyle.fill;

    final s = size.x / 2;
    final path = Path()
      ..moveTo(s, 0)
      ..lineTo(s * 2, s)
      ..lineTo(s, s * 2)
      ..lineTo(0, s)
      ..close();

    canvas.drawPath(path, paint);

    // Glow effect
    final glowPaint = Paint()
      ..color = GameConstants.playerColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }
}
