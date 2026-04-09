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
import 'constants.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/image-select/:levelId',
      builder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        return ImageSelectScreen(levelId: levelId);
      },
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        final imgFile = state.uri.queryParameters['img'] ?? 'level_${((levelId - 1) % 5) + 1}.jpg';
        return GameScreen(levelId: levelId, imageFile: imgFile);
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResultScreen(
          levelId: extra['levelId'] as int,
          captured: extra['captured'] as double,
          stars: extra['stars'] as int,
          timeSeconds: extra['timeSeconds'] as int,
        );
      },
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const LegalScreen(
        title: 'PRIVACY POLICY',
        url: AppConstants.privacyUrl,
      ),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const LegalScreen(
        title: 'TERMS OF SERVICE',
        url: AppConstants.termsUrl,
      ),
    ),
    GoRoute(
      path: '/paywall/:feature',
      builder: (context, state) {
        final feature = state.pathParameters['feature'] ?? 'premium';
        return PaywallScreen(feature: feature);
      },
    ),
  ],
);
