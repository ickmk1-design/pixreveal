import 'dart:ui' as ui;
import 'package:flame/components.dart';

class BackgroundImage extends Component {
  ui.Image? image;
  final ui.Rect gameBounds;

  BackgroundImage({required this.gameBounds});

  void setImage(ui.Image img) {
    image = img;
  }

  @override
  void render(ui.Canvas canvas) {
    if (image == null) {
      // Placeholder: draw a gradient
      final paint = ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(gameBounds.left, gameBounds.top),
          ui.Offset(gameBounds.right, gameBounds.bottom),
          [
            const ui.Color(0xFF6600CC),
            const ui.Color(0xFFFF00FF),
            const ui.Color(0xFF00FFFF),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRect(gameBounds, paint);
      return;
    }

    // Draw the hidden image, fitting to game bounds
    final src = ui.Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );
    canvas.drawImageRect(image!, src, gameBounds, ui.Paint());
  }
}
