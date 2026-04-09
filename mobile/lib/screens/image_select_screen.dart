import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

class ImageSelectScreen extends StatefulWidget {
  final int levelId;
  const ImageSelectScreen({super.key, required this.levelId});

  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
}

class _ImageSelectScreenState extends State<ImageSelectScreen> {
  int _countdown = 0;
  Timer? _timer;
  String? _selectedImage;
  String? _selectedCategory;

  static const _categories = [
    _Category('Super Cars', ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'], false, Icons.directions_car, Color(0xFFCC3300)),
    _Category('Deep Space', ['space_1.jpg', 'space_2.jpg', 'space_3.jpg'], false, Icons.rocket, Color(0xFF0044CC)),
    _Category('Wild Animals', ['animal_1.jpg', 'animal_2.jpg', 'animal_3.jpg'], false, Icons.pets, Color(0xFF228B22)),
    _Category('Beach Glamour', ['glamour_1.jpg', 'glamour_2.jpg', 'glamour_3.jpg'], true, Icons.beach_access, Color(0xFFCC6699)),
    _Category('Fitness', ['fitness_1.jpg', 'fitness_2.jpg', 'fitness_3.jpg'], true, Icons.fitness_center, Color(0xFFFF6600)),
  ];

  void _selectCategory(int index) {
    final cat = _categories[index];
    if (cat.premium) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.darkCard,
        content: Text('${L.get('premium')} - ${cat.name}',
          style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 8, color: AppColors.neonYellow)),
      ));
      return;
    }

    // Random image from category (surprise!)
    final rng = Random();
    final img = cat.images[rng.nextInt(cat.images.length)];

    setState(() {
      _selectedCategory = cat.name;
      _selectedImage = img;
      _countdown = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _countdown--; });
      if (_countdown <= 0) {
        t.cancel();
        context.go('/game/${widget.levelId}?img=$_selectedImage');
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: _countdown > 0 ? _buildCountdown() : _buildCategorySelect(),
      ),
    );
  }

  // === COUNTDOWN: NO image shown, just overlay color + big number ===
  Widget _buildCountdown() {
    final overlayColors = [
      const Color(0xFF0022AA), const Color(0xFF6600AA),
      const Color(0xFF006633), const Color(0xFF994400), const Color(0xFF990022),
    ];
    final color = overlayColors[(widget.levelId - 1) % overlayColors.length];

    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedCategory ?? '', style: const TextStyle(
              fontFamily: 'PressStart2P', fontSize: 12, color: Colors.white70,
            )),
            const SizedBox(height: 8),
            const Text('?', style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 48, color: Colors.white24,
            )),
            const SizedBox(height: 20),
            Text(
              _countdown > 0 ? '$_countdown' : 'GO!',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 72,
                color: _countdown == 1 ? AppColors.neonYellow
                     : _countdown == 2 ? AppColors.neonOrange
                     : AppColors.neonGreen,
                shadows: [Shadow(
                  color: _countdown == 1 ? AppColors.neonYellow : AppColors.neonGreen,
                  blurRadius: 24,
                )],
              ),
            ),
            const SizedBox(height: 16),
            Text(L.get('start_in'), style: const TextStyle(
              fontFamily: 'PressStart2P', fontSize: 10, color: Colors.white38,
            )),
          ],
        ),
      ),
    );
  }

  // === CATEGORY SELECT ===
  Widget _buildCategorySelect() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(L.get('choose_image'), style: const TextStyle(
          fontFamily: 'PressStart2P', fontSize: 14, color: AppColors.neonPink,
          shadows: [Shadow(color: AppColors.neonPink, blurRadius: 10)],
        )),
        const SizedBox(height: 6),
        Text('Level ${widget.levelId}', style: const TextStyle(
          fontFamily: 'PressStart2P', fontSize: 10, color: AppColors.neonBlue,
        )),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return GestureDetector(
                onTap: () => _selectCategory(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: cat.premium
                          ? AppColors.gold.withValues(alpha: 0.5)
                          : cat.color.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(cat.icon, color: cat.premium ? AppColors.gold : cat.color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      // Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.name, style: TextStyle(
                              fontFamily: 'PressStart2P', fontSize: 9,
                              color: cat.premium ? AppColors.gold : Colors.white,
                            )),
                            const SizedBox(height: 4),
                            Text('${cat.images.length} ${L.isTr ? 'resim' : 'images'}',
                              style: const TextStyle(
                                fontFamily: 'PressStart2P', fontSize: 6, color: Colors.white38,
                              )),
                          ],
                        ),
                      ),
                      // Lock or arrow
                      if (cat.premium)
                        const Icon(Icons.lock, color: AppColors.gold, size: 20)
                      else
                        Icon(Icons.arrow_forward_ios, color: cat.color, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Category {
  final String name;
  final List<String> images;
  final bool premium;
  final IconData icon;
  final Color color;
  const _Category(this.name, this.images, this.premium, this.icon, this.color);
}
