import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ImageSelectScreen extends StatelessWidget {
  const ImageSelectScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 18,
        height: 1.35,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    const items = [
      _CategoryItem(title: 'SUPER CARS', asset: 'assets/images/cars_1.jpg'),
      _CategoryItem(title: 'DEEP SPACE', asset: 'assets/images/space_1.jpg'),
      _CategoryItem(title: 'WILD ANIMALS', asset: 'assets/images/animal_1.jpg'),
      _CategoryItem(
        title: 'BEACH GLAMOUR',
        asset: 'assets/images/beach_1.jpg',
        premium: true,
      ),
      _CategoryItem(
        title: 'FITNESS',
        asset: 'assets/images/fitness_1.jpg',
        premium: true,
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
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x22161A23),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Text(L.get('select_category').toUpperCase(), style: _pixelTitle),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L.get('level_1').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => item.premium ? context.go('/paywall') : context.go('/levels'),
                          child: _CategoryTile(item: item),
                        ),
                      ),
                    ),
                    PremiumButton(
                      text: L.get('your_own_image').toUpperCase(),
                      gold: true,
                      onTap: () => context.go('/paywall'),
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

class _CategoryItem {
  final String title;
  final String asset;
  final bool premium;

  const _CategoryItem({
    required this.title,
    required this.asset,
    this.premium = false,
  });
}

class _CategoryTile extends StatelessWidget {
  final _CategoryItem item;

  const _CategoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xAA101725),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                child: Image.asset(
                  item.asset,
                  width: 120,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ),
            ],
          ),
          if (item.premium)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
