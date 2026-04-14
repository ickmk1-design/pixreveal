import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';
import '../screens/result_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/image_select_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/paywall_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/menu', builder: (_, __) => const MainMenuScreen()),
    GoRoute(path: '/levels', builder: (_, __) => const LevelSelectScreen()),
    GoRoute(
      path: '/image-select/:levelId',
      builder: (_, state) => ImageSelectScreen(
        levelId: int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1,
      ),
    ),
    GoRoute(path: '/image-select', builder: (_, __) => const ImageSelectScreen()),
    GoRoute(
      path: '/game/:levelId',
      builder: (_, state) {
        final levelId = int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
        final img = state.uri.queryParameters['img'] ?? 'cars_1.jpg';
        final cat = state.uri.queryParameters['cat'] ?? 'SUPER CARS';
        final catImgs = state.uri.queryParameters['imgs']?.split(',') ?? ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'];
        return GameScreen(levelId: levelId, imageFile: img, categoryName: cat, categoryImages: catImgs);
      },
    ),
    GoRoute(path: '/game', builder: (_, __) => const GameScreen(levelId: 1)),
    GoRoute(
      path: '/result',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra != null) {
          return ResultScreen(
            isVictory: (extra['stars'] as int? ?? 0) > 0,
            score: ((extra['captured'] as double? ?? 0) * 10000).toInt(),
            time: _fmtTime(extra['timeSeconds'] as int? ?? 0),
            imageAsset: extra['imageAsset'] as String? ?? 'assets/images/space_1.jpg',
            levelId: extra['levelId'] as int? ?? 1,
            imageFile: extra['imageFile'] as String? ?? 'cars_1.jpg',
            categoryName: extra['categoryName'] as String? ?? 'SUPER CARS',
            categoryImages: (extra['categoryImages'] as List<dynamic>?)
                ?.map((e) => e.toString()).toList() ?? ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'],
          );
        }
        return const ResultScreen(isVictory: true);
      },
    ),
    GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/privacy', builder: (_, __) => const LegalScreen(title: 'PRIVACY POLICY')),
    GoRoute(path: '/terms', builder: (_, __) => const LegalScreen(title: 'TERMS OF SERVICE')),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    GoRoute(
      path: '/paywall/:feature',
      builder: (_, __) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/level-select',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return LevelSelectScreen(
          categoryName: extra?['categoryName'] as String? ?? 'SUPER CARS',
          categoryImages: (extra?['categoryImages'] as List<dynamic>?)
              ?.map((e) => e.toString()).toList() ?? ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'],
        );
      },
    ),
  ],
);

String _fmtTime(int s) {
  final m = s ~/ 60;
  final r = s % 60;
  return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
}
