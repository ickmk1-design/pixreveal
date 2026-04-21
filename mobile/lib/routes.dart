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

final appRouter = GoRouter(
  initialLocation: '/menu',
  routes: [
    GoRoute(path: '/menu',       builder: (_, __) => const MenuScreen()),
    GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
    GoRoute(path: '/levels',     builder: (_, __) => const LevelsScreen()),
    GoRoute(path: '/countdown',  builder: (_, __) => const CountdownScreen()),
    GoRoute(path: '/hud',        builder: (_, __) => const HudScreen()),
    GoRoute(path: '/victory',    builder: (_, __) => const VictoryScreen()),
    GoRoute(path: '/gameover',   builder: (_, __) => const GameoverScreen()),
    GoRoute(path: '/shop',       builder: (_, __) => const ShopScreen()),
    GoRoute(path: '/paywall',    builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/settings',   builder: (_, __) => const SettingsScreen()),
  ],
);
