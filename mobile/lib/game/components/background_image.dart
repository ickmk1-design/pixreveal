import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class BackgroundImage extends Component {
  ui.Image? _image;
  final ui.Rect gameBounds;
  final String imageFile;
  double _time = 0;

  BackgroundImage({required this.gameBounds, this.imageFile = 'level_1.jpg'});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _image = await Flame.images.load(imageFile);
      // ignore: avoid_print
      print('Loaded image: $imageFile ${_image!.width}x${_image!.height}');
    } catch (_) {
      try { _image = await Flame.images.load('level_1.jpg'); } catch (_) {}
    }
  }

  @override
  void update(double dt) { super.update(dt); _time += dt; }

  @override
  void render(ui.Canvas canvas) {
    if (_image != null) {
      // BoxFit.contain: show ENTIRE image inside gameBounds, no cropping
      final imgW = _image!.width.toDouble();
      final imgH = _image!.height.toDouble();
      final imgAspect = imgW / imgH;
      final boundsAspect = gameBounds.width / gameBounds.height;

      // BoxFit.cover: fill gameBounds completely, crop overflow
      double srcX, srcY, srcW, srcH;
      if (imgAspect > boundsAspect) {
        // Image wider than bounds → crop left/right, fill height
        srcH = imgH;
        srcW = imgH * boundsAspect;
        srcX = (imgW - srcW) / 2;
        srcY = 0;
      } else {
        // Image taller than bounds → crop top/bottom, fill width
        srcW = imgW;
        srcH = imgW / boundsAspect;
        srcX = 0;
        srcY = (imgH - srcH) / 2;
      }

      final src = ui.Rect.fromLTWH(srcX, srcY, srcW, srcH);
      final dst = ui.Rect.fromLTWH(
          gameBounds.left, gameBounds.top, gameBounds.width, gameBounds.height);

      canvas.drawImageRect(_image!, src, dst, ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..isAntiAlias = true);
    } else {
      // Colorful gradient fallback
      canvas.drawRect(gameBounds, ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(gameBounds.left, gameBounds.top),
          ui.Offset(gameBounds.right, gameBounds.bottom),
          [const ui.Color(0xFF0B001A), const ui.Color(0xFF1A0040),
           const ui.Color(0xFF4400AA), const ui.Color(0xFF00CCFF)],
          [0.0, 0.33, 0.66, 1.0],
        ));
      // Stars
      final rng = Random(42);
      for (int i = 0; i < 40; i++) {
        final x = gameBounds.left + rng.nextDouble() * gameBounds.width;
        final y = gameBounds.top + rng.nextDouble() * gameBounds.height;
        final tw = 0.3 + (sin(_time * (0.3 + rng.nextDouble()) + i) + 1) * 0.35;
        canvas.drawCircle(ui.Offset(x, y), 1 + rng.nextDouble(),
          ui.Paint()..color = ui.Color.fromARGB((tw * 200).toInt(), 255, 255, 255));
      }
    }
  }
}
