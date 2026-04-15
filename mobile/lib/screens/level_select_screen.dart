import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/coin_badge.dart';
import '../widgets/gold_star.dart';
import '../widgets/space_background.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 17,
        height: 1.35,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    const levels = [
      _LevelItem(number: 1, stars: 3, unlocked: true),
      _LevelItem(number: 2, stars: 2, unlocked: true),
      _LevelItem(number: 3, stars: 1, unlocked: true),
      _LevelItem(number: 4, stars: 0, unlocked: false),
      _LevelItem(number: 5, stars: 0, unlocked: false),
      _LevelItem(number: 6, stars: 0, unlocked: false),
      _LevelItem(number: 7, stars: 0, unlocked: false),
      _LevelItem(number: 8, stars: 0, unlocked: false),
      _LevelItem(number: 9, stars: 0, unlocked: false),
      _LevelItem(number: 10, stars: 0, unlocked: false),
      _LevelItem(number: 11, stars: 0, unlocked: false),
      _LevelItem(number: 12, stars: 0, unlocked: false),
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
                      onTap: () => context.go('/image-select'),
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
                    Text('SUPER CARS', style: _pixelTitle),
                    const Spacer(),
                    const CoinBadge(),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  itemCount: levels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return GestureDetector(
                      onTap: () => level.unlocked
                          ? context.go('/game?level=${level.number}')
                          : null,
                      child: _LevelCard(item: level),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelItem {
  final int number;
  final int stars;
  final bool unlocked;

  const _LevelItem({
    required this.number,
    required this.stars,
    required this.unlocked,
  });
}

class _LevelCard extends StatelessWidget {
  final _LevelItem item;

  const _LevelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.unlocked
              ? const [Color(0xFF15223A), Color(0xFF0D1526)]
              : const [Color(0xFF121721), Color(0xFF0B0E14)],
        ),
        border: Border.all(
          color: item.unlocked ? const Color(0xFF3CD8FF) : const Color(0x55D8B263),
          width: 1.4,
        ),
        boxShadow: item.unlocked
            ? const [
                BoxShadow(
                  color: Color(0x223CD8FF),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (!item.unlocked)
            const Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.lock, color: Color(0xFFFFD36A)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
            child: Column(
              children: [
                Text(
                  '${item.number}',
                  style: TextStyle(
                    color: item.unlocked ? Colors.white : Colors.white54,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'LEVEL ${item.number}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: item.unlocked ? const Color(0xFFA9F2FF) : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: GoldStar(
                        size: 22,
                        filled: index < item.stars,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
