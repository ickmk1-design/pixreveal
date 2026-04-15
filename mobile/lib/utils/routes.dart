import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/image_select_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/game_screen.dart';
import '../screens/result_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/legal_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Splash / Auth ────────────────────────────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // ── Main Menu ────────────────────────────────────────────────────────
    // Navigates to /image-select, /shop, /settings internally
    GoRoute(path: '/menu', builder: (_, __) => const MainMenuScreen()),

    // ── Category / Image Select ──────────────────────────────────────────
    // Navigates to /levels or /paywall internally
    GoRoute(path: '/image-select', builder: (_, __) => const ImageSelectScreen()),

    // ── Level Select ─────────────────────────────────────────────────────
    // Navigates to /game?level=N internally
    GoRoute(path: '/levels', builder: (_, __) => const LevelSelectScreen()),
    GoRoute(path: '/level-select', builder: (_, __) => const LevelSelectScreen()),

    // ── Game (Flame engine — unchanged) ──────────────────────────────────
    // /game?level=N  — from level_select (query param)
    // /game/:levelId — legacy path param
    GoRoute(
      path: '/game',
      builder: (_, state) {
        final levelId =
            int.tryParse(state.uri.queryParameters['level'] ?? '') ?? 1;
        final img = state.uri.queryParameters['img'] ?? 'cars_1.jpg';
        final cat = state.uri.queryParameters['cat'] ?? 'SUPER CARS';
        final catImgs = state.uri.queryParameters['imgs']?.split(',') ??
            ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'];
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
            ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'];
        return GameScreen(
          levelId: levelId,
          imageFile: img,
          categoryName: cat,
          categoryImages: catImgs,
        );
      },
    ),

    // ── Result ───────────────────────────────────────────────────────────
    // game_screen sends extras; navigates to /levels, /game, /menu internally
    GoRoute(
      path: '/result',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final stars = extra?['stars'] as int? ?? 0;
        final captured = extra?['captured'] as double? ?? 0.0;
        return ResultScreen(
          isVictory: stars > 0,
          score: (captured * 10000).toInt(),
          combo: stars,
          time: _fmtTime(extra?['timeSeconds'] as int? ?? 0),
          previewAsset: extra?['imageAsset'] as String? ??
              'assets/images/cars_1.jpg',
        );
      },
    ),

    // ── Shop / Settings / Paywall ────────────────────────────────────────
    // All self-routing ConsumerWidgets — navigate back to /menu internally
    GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/paywall/:feature', builder: (_, __) => const PaywallScreen()),

    // ── Legal ────────────────────────────────────────────────────────────
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
