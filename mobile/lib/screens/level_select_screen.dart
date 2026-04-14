import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/localization.dart';
import '../widgets/coin_badge.dart';
import '../widgets/gold_star.dart';
import '../widgets/space_background.dart';

class LevelSelectScreen extends StatefulWidget {
  final String categoryName;
  final List<String> categoryImages;
  const LevelSelectScreen({
    super.key,
    this.categoryName = 'SUPER CARS',
    this.categoryImages = const ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'],
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadUnlocked();
  }

  Future<void> _loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'unlocked_${widget.categoryName}';
    final u = prefs.getInt(key) ?? 1;
    if (mounted) setState(() => _unlockedLevel = u);
  }

  String get _categoryTitle => widget.categoryName;

  List<_LevelData> get levels {
    return List.generate(11, (i) {
      final id = i + 1;
      return _LevelData(id, 'LEVEL $id', id <= _unlockedLevel, 0);
    });
  }

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
                    const Spacer(),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _categoryTitle,
                            style: const TextStyle(
                              color: Color(0xFF99F2FF),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              shadows: [Shadow(color: Color(0xAA12DBFF), blurRadius: 18)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const CoinBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: levels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.82,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return _levelCard(level);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _levelCard(_LevelData level) {
    final bright = level.unlocked ? 1.0 : 0.7;

    return GestureDetector(
      onTap: level.unlocked ? () {
        final images = widget.categoryImages;
        final img = images[(level.number - 1) % images.length];
        final cat = Uri.encodeComponent(widget.categoryName);
        final imgs = images.join(',');
        // ignore: avoid_print
        print('Category: ${widget.categoryName}, Level: ${level.number}, Image: $img');
        context.go('/game/${level.number}?img=$img&cat=$cat&imgs=$imgs');
      } : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(const Color(0xFF162235), Colors.white, 0.02 * bright)!,
              Color.lerp(const Color(0xFF0D1422), Colors.white, 0.01 * bright)!,
            ],
          ),
          border: Border.all(
            color: level.unlocked ? const Color(0xFF39D5FF) : const Color(0x33D6B56A),
            width: 1.4,
          ),
          boxShadow: [
            if (level.unlocked)
              const BoxShadow(
                color: Color(0x5538D9FF),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
          ],
        ),
        child: Stack(
          children: [
            if (!level.unlocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE58E), Color(0xFFE0A72E)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55FFD36A), blurRadius: 12),
                    ],
                  ),
                  child: const Icon(Icons.lock, color: Color(0xFF5E3600), size: 18),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${level.number}',
                    style: TextStyle(
                      color: level.unlocked ? Colors.white : Colors.white70,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    level.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: level.unlocked ? const Color(0xFFAEEFFF) : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: GoldStar(
                          size: 22,
                          filled: i < level.stars,
                          glow: i < level.stars,
                        ),
                      ),
                    ),
                  ),
                ],
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

class _LevelData {
  final int number;
  final String name;
  final bool unlocked;
  final int stars;

  const _LevelData(this.number, this.name, this.unlocked, this.stars);
}