import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spiderCtrl;

  @override
  void initState() {
    super.initState();
    _spiderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spiderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 14,
                right: 16,
                child: CoinBadge(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 36),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _spiderCtrl,
                        builder: (context, child) {
                          final y = (_spiderCtrl.value - 0.5) * 12;
                          return Transform.translate(
                            offset: Offset(0, y),
                            child: child,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 320,
                              height: 320,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x22FF3A3A),
                                    blurRadius: 120,
                                    spreadRadius: 18,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/images/spider_hero.png',
                              width: 290,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              top: 104,
                              left: 112,
                              child: _eyeGlow(),
                            ),
                            Positioned(
                              top: 104,
                              right: 112,
                              child: _eyeGlow(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _GameLogo(),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        PremiumButton(
                          text: L.get('play').toUpperCase(),
                          onPressed: () => context.go('/image-select'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: PremiumButton(
                                text: L.get('shop').toUpperCase(),
                                outlined: true,
                                outlineColor: const Color(0x66B8DFFF),
                                onPressed: () => context.go('/shop'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: PremiumButton(
                                text: L.get('settings').toUpperCase(),
                                outlined: true,
                                outlineColor: const Color(0x66B8DFFF),
                                onPressed: () => context.go('/settings'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eyeGlow() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFF3232),
        boxShadow: [
          BoxShadow(
            color: Color(0xCCFF2A2A),
            blurRadius: 16,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _GameLogo extends StatelessWidget {
  const _GameLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'PIXREVEAL',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.2,
            color: const Color(0xFF49F1FF),
            shadows: const [
              Shadow(color: Color(0xAA0ECFFF), blurRadius: 22),
              Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
        ),
      ],
    );
  }
}