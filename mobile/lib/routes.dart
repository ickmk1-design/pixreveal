import 'package:go_router/go_router.dart';
import 'screens/menu_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/levels_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/game_screen.dart';
import 'screens/victory_screen.dart';
import 'screens/gameover_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/settings_screen.dart';

int _levelFrom(GoRouterState state) {
  final raw = state.uri.queryParameters['level'];
  return int.tryParse(raw ?? '') ?? 1;
}

final appRouter = GoRouter(
  initialLocation: '/menu',
  routes: [
    GoRoute(path: '/menu',       builder: (_, __) => const MenuScreen()),
    GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
    GoRoute(path: '/levels',     builder: (_, __) => const LevelsScreen()),
    GoRoute(
      path: '/countdown',
      builder: (_, state) => CountdownScreen(levelId: _levelFrom(state)),
    ),
    GoRoute(
      path: '/hud',
      builder: (_, state) => HudScreen(levelId: _levelFrom(state)),
    ),
    GoRoute(
      path: '/victory',
      builder: (_, state) {
        final p = state.uri.queryParameters;
        return VictoryScreen(
          levelId:     int.tryParse(p['level'] ?? '1') ?? 1,
          score:       int.tryParse(p['score']  ?? '0') ?? 0,
          combo:       int.tryParse(p['combo']  ?? '1') ?? 1,
          timeSeconds: int.tryParse(p['time']   ?? '0') ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/gameover',
      builder: (_, state) => GameoverScreen(levelId: _levelFrom(state)),
    ),
    GoRoute(path: '/shop',       builder: (_, __) => const ShopScreen()),
    GoRoute(path: '/paywall',    builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/settings',   builder: (_, __) => const SettingsScreen()),
  ],
);
