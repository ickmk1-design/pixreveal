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
      // BoxFit.cover: fill gameBounds completely, crop excess, preserve aspect ratio
      final imgW = _image!.width.toDouble();
      final imgH = _image!.height.toDouble();
      final imgAspect = imgW / imgH;
      final boundsAspect = gameBounds.width / gameBounds.height;

      ui.Rect src;
      if (imgAspect > boundsAspect) {
        // Image wider than bounds → crop sides
        final cropW = imgH * boundsAspect;
        final offsetX = (imgW - cropW) / 2;
        src = ui.Rect.fromLTWH(offsetX, 0, cropW, imgH);
      } else {
        // Image taller than bounds → crop top/bottom
        final cropH = imgW / boundsAspect;
        final offsetY = (imgH - cropH) / 2;
        src = ui.Rect.fromLTWH(0, offsetY, imgW, cropH);
      }

      canvas.drawImageRect(_image!, src, gameBounds, ui.Paint()
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
