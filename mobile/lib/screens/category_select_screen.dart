import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class CategoryItem {
  final String name;
  final String imageAsset;
  final bool isPremium;
  final bool isCustom;

  const CategoryItem({
    required this.name,
    required this.imageAsset,
    this.isPremium = false,
    this.isCustom = false,
  });
}

class CategorySelectScreen extends StatefulWidget {
  final int level;
  final int tokens;
  final List<CategoryItem> categories;
  final Function(CategoryItem)? onCategorySelect;
  final VoidCallback? onBack;

  const CategorySelectScreen({
    super.key,
    this.level = 1,
    this.tokens = 121,
    this.categories = const [],
    this.onCategorySelect,
    this.onBack,
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(name: 'SUPER CARS', imageAsset: 'assets/images/cat_cars.jpg'),
    CategoryItem(name: 'DEEP SPACE', imageAsset: 'assets/images/cat_space.jpg'),
    CategoryItem(name: 'WILD ANIMALS', imageAsset: 'assets/images/cat_animals.jpg', isPremium: true),
    CategoryItem(name: 'BEACH GLAMOUR', imageAsset: 'assets/images/cat_beach.jpg', isPremium: true),
    CategoryItem(name: 'FITNESS', imageAsset: 'assets/images/cat_fitness.jpg'),
  ];

  @override
  State<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<CategorySelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  List<CategoryItem> get _categories =>
      widget.categories.isNotEmpty ? widget.categories : CategorySelectScreen.defaultCategories;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'SELECT CATEGORY',
                        fontSize: 14,
                        glowColor: PixTheme.neonCyan,
                      ),
                    ),
                    TokenDisplay(count: widget.tokens),
                  ],
                ),
              ),

              // Level subtitle
              Text(
                'LEVEL ${widget.level}',
                style: PixTheme.captionStyle.copyWith(
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // Category list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length + 1, // +1 for "Your Own Image"
                  itemBuilder: (context, index) {
                    if (index == _categories.length) {
                      return _buildCustomImageButton();
                    }

                    final cat = _categories[index];
                    final delay = index * 0.1;

                    return AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) {
                        final progress = ((_ctrl.value - delay) / 0.5).clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - progress)),
                          child: Opacity(
                            opacity: progress,
                            child: child,
                          ),
                        );
                      },
                      child: _buildCategoryTile(cat),
                    );
                  },
                ),
              ),

              // Version
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'v1.0',
                  style: PixTheme.captionStyle.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryItem cat) {
    return GestureDetector(
      onTap: cat.isPremium ? null : () => widget.onCategorySelect?.call(cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 72,
        decoration: BoxDecoration(
          color: PixTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cat.isPremium
                ? PixTheme.gold.withOpacity(0.3)
                : PixTheme.neonCyan.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (cat.isPremium ? PixTheme.gold : PixTheme.neonCyan)
                  .withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Category thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 100,
                height: 72,
                child: Image.asset(
                  cat.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: PixTheme.bgDeep,
                    child: const Icon(Icons.image, color: Colors.white24, size: 32),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Category name
            Expanded(
              child: Text(
                cat.name,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),

            // Premium badge
            if (cat.isPremium) ...[
              const PremiumBadge(),
              const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomImageButton() {
    return GestureDetector(
      onTap: () {
        // Handle custom image upload
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        height: 56,
        decoration: BoxDecoration(
          color: PixTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PixTheme.gold.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: PixTheme.gold.withOpacity(0.15), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: PixTheme.gold, size: 20,
              shadows: [Shadow(color: PixTheme.gold.withOpacity(0.5), blurRadius: 8)]),
            const SizedBox(width: 10),
            const Text(
              'YOUR OWN IMAGE',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
