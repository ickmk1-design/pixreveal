import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 18,
        height: 1.35,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = const [
      _TokenPack(tokens: 20, price: '\$0.99'),
      _TokenPack(tokens: 50, price: '\$1.99'),
      _TokenPack(tokens: 120, price: '\$3.99'),
      _TokenPack(tokens: 300, price: '\$8.99'),
      _TokenPack(tokens: 750, price: '\$19.99'),
    ];

    final themes = const [
      _ThemePack(title: 'SUPER CARS', asset: 'assets/images/cars_1.jpg'),
      _ThemePack(title: 'DEEP SPACE', asset: 'assets/images/space_1.jpg'),
      _ThemePack(title: 'WILD ANIMALS', asset: 'assets/images/animal_1.jpg'),
      _ThemePack(
        title: 'BEACH GLAMOUR',
        asset: 'assets/images/beach_1.jpg',
        locked: true,
      ),
    ];

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.go('/menu'),
                    ),
                    const Spacer(),
                    Text(L.get('shop_title').toUpperCase(), style: _pixelTitle),
                    const Spacer(),
                    const CoinBadge(),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _SectionCard(
                      title: L.get('free_tokens'),
                      child: Row(
                        children: [
                          const _GoldCoinIcon(size: 46),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L.get('watch_ad_for_free_tokens'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 130,
                            child: PremiumButton(
                              text: L.get('watch_ad').toUpperCase(),
                              compact: true,
                              blue: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: L.get('token_packs'),
                      child: Column(
                        children: packs
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: _PackTile(pack: p),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: L.get('premium_themes'),
                      child: Column(
                        children: themes
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => t.locked ? context.go('/paywall') : null,
                                  child: _ThemeTile(theme: t),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: L.get('subscription'),
                      child: Column(
                        children: [
                          Text(
                            L.get('unlock_everything'),
                            style: const TextStyle(
                              color: Color(0xFFFFD68A),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PremiumButton(
                            text: L.get('go_premium').toUpperCase(),
                            gold: true,
                            onTap: () => context.go('/paywall'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenPack {
  final int tokens;
  final String price;

  const _TokenPack({required this.tokens, required this.price});
}

class _ThemePack {
  final String title;
  final String asset;
  final bool locked;

  const _ThemePack({
    required this.title,
    required this.asset,
    this.locked = false,
  });
}

class _PackTile extends StatelessWidget {
  final _TokenPack pack;

  const _PackTile({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF141C2C),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          const _GoldCoinIcon(size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${pack.tokens} TOKENS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            pack.price,
            style: const TextStyle(
              color: Color(0xFFFFD36A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final _ThemePack theme;

  const _ThemeTile({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF141C2C),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                child: Image.asset(
                  theme.asset,
                  width: 120,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    theme.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (theme.locked)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE59C), Color(0xFFFFB933)],
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Color(0xFF5B3400)),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Color(0xFF5B3400),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xAA101725),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFA7F5FF),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GoldCoinIcon extends StatelessWidget {
  final double size;

  const _GoldCoinIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFEEA2), Color(0xFFFFC944), Color(0xFFC57A09)],
        ),
      ),
      child: Icon(
        Icons.monetization_on_rounded,
        color: const Color(0xFF6B4300),
        size: size * 0.58,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x22161A23),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
