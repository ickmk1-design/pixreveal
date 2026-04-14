import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart' if (dart.library.html) 'services/ad_service_stub.dart';
import 'services/audio_service.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'utils/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localization
  await L.init();

  // Audio (silent fallback if no files)
  await AudioService.init();

  // Firebase
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // AdMob — on web this uses the stub (no-op)
  final adService = AdService();
  if (!kIsWeb) {
    await adService.init();
    adService.loadInterstitial();
    adService.loadRewarded();

    // Force portrait mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(ProviderScope(
    overrides: [
      adServiceProvider.overrideWithValue(adService),
    ],
    child: const PixRevealApp(),
  ));
}

final adServiceProvider = Provider<AdService>((ref) => AdService());

class PixRevealApp extends StatelessWidget {
  const PixRevealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PixReveal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkArcade,
      routerConfig: router,
      builder: (context, child) {
        // Constrain to mobile-like width on web, center with black background
        return Container(
          color: Colors.black,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
