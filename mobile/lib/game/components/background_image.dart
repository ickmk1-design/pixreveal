import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class BackgroundImage extends Component {
  ui.Image? _image;
  final ui.Rect gameBounds;
  final String imageFile;
  double _time = 0;

  BackgroundImage({required this.gameBounds, this.imageFile = 'cars_1.jpg'});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Clear Flame's image cache so previous categories don't leak through
    // when the player switches between levels/categories.
    Flame.images.clear(imageFile);

    // Primary: the exact category-specific file (e.g. cars_1.jpg, space_3.jpg)
    try {
      _image = await Flame.images.load(imageFile);
      // ignore: avoid_print
      print('BG loaded: $imageFile  ${_image!.width}x${_image!.height}');
      return;
    } catch (e) {
      // ignore: avoid_print
      print('BG primary load failed for $imageFile: $e');
    }

    // Fallback 1: try same category with level 1
    final parts = imageFile.split('_');
    if (parts.length >= 2) {
      final category = parts[0];
      final fb1 = '${category}_1.jpg';
      try {
        Flame.images.clear(fb1);
        _image = await Flame.images.load(fb1);
        // ignore: avoid_print
        print('BG fallback 1: $fb1');
        return;
      } catch (_) {}
    }

    // Fallback 2: cars_1.jpg always exists
    try {
      Flame.images.clear('cars_1.jpg');
      _image = await Flame.images.load('cars_1.jpg');
      // ignore: avoid_print
      print('BG fallback 2: cars_1.jpg');
      return;
    } catch (_) {}

    // If we get here nothing loaded → gradient fallback will kick in.
    // ignore: avoid_print
    print('BG: no image loaded, using gradient fallback');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(ui.Canvas canvas) {
    if (_image != null) {
      final imgW = _image!.width.toDouble();
      final imgH = _image!.height.toDouble();
      final imgAspect = imgW / imgH;
      final boundsAspect = gameBounds.width / gameBounds.height;

      // BoxFit.cover: fill bounds completely, crop overflow edges
      double srcX, srcY, srcW, srcH;
      if (imgAspect > boundsAspect) {
        srcH = imgH;
        srcW = imgH * boundsAspect;
        srcX = (imgW - srcW) / 2;
        srcY = 0;
      } else {
        srcW = imgW;
        srcH = imgW / boundsAspect;
        srcX = 0;
        srcY = (imgH - srcH) / 2;
      }

      final src = ui.Rect.fromLTWH(srcX, srcY, srcW, srcH);
      final dst = ui.Rect.fromLTWH(
          gameBounds.left, gameBounds.top, gameBounds.width, gameBounds.height);

      canvas.drawImageRect(
        _image!,
        src,
        dst,
        ui.Paint()
          ..filterQuality = ui.FilterQuality.high
          ..isAntiAlias = true,
      );
    } else {
      // Colorful gradient fallback
      canvas.drawRect(
          gameBounds,
          ui.Paint()
            ..shader = ui.Gradient.linear(
              ui.Offset(gameBounds.left, gameBounds.top),
              ui.Offset(gameBounds.right, gameBounds.bottom),
              [
                const ui.Color(0xFF0B001A),
                const ui.Color(0xFF1A0040),
                const ui.Color(0xFF001A40),
                const ui.Color(0xFF00CCFF),
              ],
              [0.0, 0.33, 0.66, 1.0],
            ));
      // Stars
      final rng = Random(42);
      for (int i = 0; i < 40; i++) {
        final x = gameBounds.left + rng.nextDouble() * gameBounds.width;
        final y = gameBounds.top + rng.nextDouble() * gameBounds.height;
        final tw = 0.3 + (sin(_time * (0.3 + rng.nextDouble()) + i) + 1) * 0.35;
        canvas.drawCircle(
            ui.Offset(x, y),
            1 + rng.nextDouble(),
            ui.Paint()
              ..color = ui.Color.fromARGB((tw * 200).toInt(), 255, 255, 255));
      }
    }
  }
}
