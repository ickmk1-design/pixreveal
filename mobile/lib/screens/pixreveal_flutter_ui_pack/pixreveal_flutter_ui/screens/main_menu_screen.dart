import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 26,
        height: 1.3,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [CoinBadge()],
                ),
                const Spacer(),
                Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33FF4D4D),
                        blurRadius: 80,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/spider_hero.png',
                        width: 260,
                        fit: BoxFit.contain,
                      ),
                      const Positioned(
                        top: 95,
                        left: 96,
                        child: _EyeGlow(),
                      ),
                      const Positioned(
                        top: 95,
                        right: 96,
                        child: _EyeGlow(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'PIXREVEAL',
                  textAlign: TextAlign.center,
                  style: _pixelTitle,
                ),
                const SizedBox(height: 14),
                Text(
                  L.get('main_menu_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFBFC8D8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 34),
                PremiumButton(
                  text: L.get('play').toUpperCase(),
                  onTap: () => context.go('/image-select'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: L.get('shop').toUpperCase(),
                        outlined: true,
                        onTap: () => context.go('/shop'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PremiumButton(
                        text: L.get('settings').toUpperCase(),
                        outlined: true,
                        onTap: () => context.go('/settings'),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EyeGlow extends StatelessWidget {
  const _EyeGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFF3B3B),
        boxShadow: [
          BoxShadow(
            color: Color(0xCCFF3B3B),
            blurRadius: 16,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
