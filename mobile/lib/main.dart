import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/ad_service.dart'
    if (dart.library.html) 'services/ad_service_stub.dart';
import 'screens/main_menu_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/image_select_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/legal_screen.dart';

// ── AdService provider (imported by game_screen.dart) ────────────────────────
final adServiceProvider = Provider<AdService>((ref) => AdService());

// ── Router ───────────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/menu',
  routes: [
    // Main menu
    GoRoute(path: '/menu', builder: (_, __) => const MainMenuScreen()),

    // Category / image select → navigates to /levels or /paywall internally
    GoRoute(path: '/image-select', builder: (_, __) => const ImageSelectScreen()),

    // Level select → navigates to /game?level=N internally
    GoRoute(path: '/levels', builder: (_, __) => const LevelSelectScreen()),
    GoRoute(path: '/level-select', builder: (_, __) => const LevelSelectScreen()),

    // Flame game engine — /game?level=N (from level_select) or /game/:id (legacy)
    GoRoute(
      path: '/game',
      builder: (_, state) {
        final levelId =
            int.tryParse(state.uri.queryParameters['level'] ?? '') ?? 1;
        final img = state.uri.queryParameters['img'] ?? 'cars_1.jpg';
        final cat = state.uri.queryParameters['cat'] ?? 'SUPER CARS';
        final catImgs = state.uri.queryParameters['imgs']?.split(',') ??
            const ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'];
        return GameScreen(
          levelId: levelId,
          imageFile: img,
          categoryName: cat,
          categoryImages: catImgs,
        );
      },
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (_, state) {
        final levelId =
            int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
        final img = state.uri.queryParameters['img'] ?? 'cars_1.jpg';
        final cat = state.uri.queryParameters['cat'] ?? 'SUPER CARS';
        final catImgs = state.uri.queryParameters['imgs']?.split(',') ??
            const ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'];
        return GameScreen(
          levelId: levelId,
          imageFile: img,
          categoryName: cat,
          categoryImages: catImgs,
        );
      },
    ),

    // Result — game_screen sends extras map
    GoRoute(
      path: '/result',
      builder: (_, state) {
        final e = state.extra as Map<String, dynamic>?;
        final stars = e?['stars'] as int? ?? 0;
        final captured = e?['captured'] as double? ?? 0.0;
        return ResultScreen(
          isVictory: stars > 0,
          score: (captured * 10000).toInt(),
          combo: stars,
          time: _fmtTime(e?['timeSeconds'] as int? ?? 0),
          previewAsset:
              e?['imageAsset'] as String? ?? 'assets/images/cars_1.jpg',
        );
      },
    ),

    // Shop / Settings / Paywall — self-routing ConsumerWidgets
    GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/paywall/:feature', builder: (_, __) => const PaywallScreen()),

    // Legal
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const LegalScreen(title: 'PRIVACY POLICY'),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, __) => const LegalScreen(title: 'TERMS OF SERVICE'),
    ),
  ],
);

String _fmtTime(int s) {
  final m = s ~/ 60;
  final r = s % 60;
  return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
}

// ── Entry point ───────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (skipped on web)
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // AdMob (skipped on web — stub handles no-ops)
  final adService = AdService();
  if (!kIsWeb) {
    await adService.init();
    adService.loadRewarded();
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [adServiceProvider.overrideWithValue(adService)],
      child: const PixRevealApp(),
    ),
  );
}

// ── App widget ────────────────────────────────────────────────────────────────
class PixRevealApp extends StatelessWidget {
  const PixRevealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PixReveal',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
