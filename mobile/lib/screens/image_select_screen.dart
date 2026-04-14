import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ImageSelectScreen extends StatefulWidget {
  final int levelId;
  const ImageSelectScreen({super.key, this.levelId = 1});

  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
}

class _ImageSelectScreenState extends State<ImageSelectScreen> {
  final List<_CategoryData> categories = const [
    _CategoryData('SUPER CARS', 'assets/images/cars_1.jpg', false),
    _CategoryData('DEEP SPACE', 'assets/images/space_1.jpg', false),
    _CategoryData('WILD ANIMALS', 'assets/images/animal_1.jpg', false),
    _CategoryData('BEACH GLAMOUR', 'assets/images/glamour_1.jpg', true),
    _CategoryData('FITNESS', 'assets/images/fitness_1.jpg', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _circleButton(Icons.arrow_back_ios_new, () => context.go('/menu')),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              L.get('select_category'),
                              style: TextStyle(
                                color: Color(0xFF9AF5FF),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                shadows: [Shadow(color: Color(0xAA12DBFF), blurRadius: 18)],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'LEVEL 1',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    ...categories.map(_categoryCard),
                    SizedBox(height: 10),
                    PremiumButton(
                      text: L.get('your_own_image'),
                      icon: Icons.auto_awesome,
                      gradient: const [Color(0xFFFFD36A), Color(0xFFFFA53A)],
                      onPressed: () => context.go('/paywall'),
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

  Widget _categoryCard(_CategoryData item) {
    return GestureDetector(
      onTap: () {
        if (item.premium) {
          context.go('/paywall');
        } else {
          final imgs = _imagesForCategory(item.title);
          // ignore: avoid_print
          print('CATEGORY SELECTED: ${item.title}, IMAGES: $imgs');
          context.go('/level-select', extra: {
            'categoryName': item.title,
            'categoryImages': imgs,
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0x22161A23),
          border: Border.all(color: const Color(0x3363CCFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                  child: Image.asset(
                    item.asset,
                    width: 118,
                    height: 88,
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
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                const SizedBox(width: 12),
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
                      colors: [Color(0xFFFFE18A), Color(0xFFFFB22E)],
                    ),
                    boxShadow: const [BoxShadow(color: Color(0x55FFD36A), blurRadius: 12)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: Color(0xFF5C3600), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Color(0xFF5C3600),
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
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x22161A23),
          border: Border.all(color: const Color(0x44A8D8FF)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

List<String> _imagesForCategory(String title) {
  final map = {
    'SUPER CARS': ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg', 'cars_4.jpg', 'cars_5.jpg'],
    'DEEP SPACE': ['space_1.jpg', 'space_2.jpg', 'space_3.jpg', 'space_4.jpg', 'space_5.jpg'],
    'WILD ANIMALS': ['animal_1.jpg', 'animal_2.jpg', 'animal_3.jpg', 'animal_4.jpg', 'animal_5.jpg'],
    'BEACH GLAMOUR': ['glamour_1.jpg', 'glamour_2.jpg', 'glamour_3.jpg', 'glamour_4.jpg', 'glamour_5.jpg'],
    'FITNESS': ['fitness_1.jpg', 'fitness_2.jpg', 'fitness_3.jpg', 'fitness_4.jpg', 'fitness_5.jpg'],
  };
  return map[title] ?? ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg', 'cars_4.jpg', 'cars_5.jpg'];
}

class _CategoryData {
  final String title;
  final String asset;
  final bool premium;

  const _CategoryData(this.title, this.asset, this.premium);
}