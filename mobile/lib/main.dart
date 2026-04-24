import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/audio_service.dart';
import 'services/purchase_service.dart';
import 'services/token_service.dart';
import 'services/entitlement_service.dart';
import 'services/settings_service.dart';
import 'app.dart';

Future<void> _debugPngSizes() async {
  for (final name in [
    'menu', 'categories', 'shop', 'settings', 'paywall', 'victory', 'gameover'
  ]) {
    try {
      final data = await rootBundle.load('assets/images/$name.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      // ignore: avoid_print
      print('PNG $name: ${frame.image.width}x${frame.image.height}');
    } catch (e) {
      // ignore: avoid_print
      print('PNG $name: ERROR $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PurchaseService.instance.configure();
  await TokenService.instance.load();
  EntitlementService.instance.init();
  await EntitlementService.instance.refresh();

  await SettingsService.instance.load();

  // Preload audio files so first play has no delay.
  await AudioService.instance.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await _debugPngSizes();

  runApp(
    const ProviderScope(
      child: PixRevealApp(),
    ),
  );
}
