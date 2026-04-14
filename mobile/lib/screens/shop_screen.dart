import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final packs = const [
    (20, '\$0.99'),
    (50, '\$1.99'),
    (120, '\$3.99'),
    (300, '\$8.99'),
    (750, '\$19.99'),
  ];

  // Only PREMIUM themes in shop (free ones are already available)
  final themes = const [
    ('BEACH GLAMOUR', 'assets/images/glamour_1.jpg', true),
    ('FITNESS', 'assets/images/fitness_1.jpg', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    _sectionTitle(L.get('free_tokens')),
                    const SizedBox(height: 10),
                    _glassCard(
                      child: Row(
                        children: [
                          const Icon(Icons.ondemand_video, color: Color(0xFFFFD76A), size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L.get('watch_ad_for_tokens'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: PremiumButton(
                              text: L.get('watch_ad'),
                              height: 50,
                              gradient: const [Color(0xFF1EA0FF), Color(0xFF39D0FF)],
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _sectionTitle(L.get('token_packs')),
                    const SizedBox(height: 10),
                    ...packs.map(_packCard),
                    const SizedBox(height: 22),
                    _sectionTitle(L.isTr ? 'REKLAM KALDIRMA' : 'REMOVE ADS'),
                    const SizedBox(height: 10),
                    _packCard((0, '\$3.99'), label: L.isTr ? 'Reklamları Kaldır (Tek Sefer)' : 'Remove All Ads (One-time)'),
                    const SizedBox(height: 22),
                    _sectionTitle(L.isTr ? 'PREMIUM TEMALAR' : 'PREMIUM THEMES'),
                    const SizedBox(height: 10),
                    ...themes.map(_themeCard),
                    const SizedBox(height: 22),
                    _sectionTitle(L.isTr ? 'PREMIUM ABONELİK' : 'PREMIUM SUBSCRIPTION'),
                    const SizedBox(height: 10),
                    _packCard((0, '\$6.99/mo'), label: L.isTr ? 'Tüm Temalar + Sınırsız Jeton + Reklamsız' : 'All Themes + Unlimited Tokens + No Ads'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _circleButton(Icons.arrow_back_ios_new, () => context.go('/menu')),
          const Spacer(),
          const CoinBadge(),
        ],
      ),
    );
  }

  Widget _packCard((int, String) item, {String? label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBA2), Color(0xFFFFC842), Color(0xFFC67D09)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x55FFD36A),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.monetization_on, color: Color(0xFF7E4600), size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label ?? '${item.$1} TOKENS',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              item.$2,
              style: const TextStyle(
                color: Color(0xFFFFD36A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeCard((String, String, bool) item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _glassCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                  child: Image.asset(
                    item.$2,
                    width: 120,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (item.$3)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE58E), Color(0xFFFFB52E)],
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock, size: 14, color: Color(0xFF5F3800)),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Color(0xFF5F3800),
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

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0x22161A23),
        border: Border.all(color: const Color(0x33A8D8FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFA7F7FF),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
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