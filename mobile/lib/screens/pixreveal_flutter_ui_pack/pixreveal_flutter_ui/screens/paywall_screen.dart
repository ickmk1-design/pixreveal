import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

final paywallSelectionProvider = StateProvider<int>((ref) => 1);

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 20,
        height: 1.4,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paywallSelectionProvider);

    return Scaffold(
      body: Stack(
        children: [
          SpaceBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFE8A1), Color(0xFFFFBC37)],
                        ),
                        boxShadow: [BoxShadow(color: Color(0x55FFD36A), blurRadius: 22)],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Color(0xFF684000),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(L.get('go_premium').toUpperCase(), textAlign: TextAlign.center, style: _pixelTitle),
                    const SizedBox(height: 18),
                    _BenefitCard(
                      benefits: [
                        L.get('unlimited_tokens'),
                        L.get('all_theme_packs'),
                        L.get('custom_images'),
                        L.get('no_ads'),
                        L.get('exclusive_powerups'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PlanCard(
                            selected: selected == 0,
                            title: 'MONTHLY',
                            price: '\$6.99/mo',
                            borderColor: const Color(0xFF4FBFFF),
                            onTap: () => ref.read(paywallSelectionProvider.notifier).state = 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlanCard(
                            selected: selected == 1,
                            title: 'YEARLY',
                            price: '\$49.99/yr',
                            borderColor: const Color(0xFFFFD36A),
                            recommended: true,
                            onTap: () => ref.read(paywallSelectionProvider.notifier).state = 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PremiumButton(
                      text: L.get('subscribe').toUpperCase(),
                      gold: true,
                      icon: Icons.workspace_premium_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        L.get('restore_purchases'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      L.get('paywall_legal_small'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => context.go('/menu'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x22161A23),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final List<String> benefits;

  const _BenefitCard({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xAA101725),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        children: benefits
            .map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFFFFD36A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final Color borderColor;
  final bool recommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.borderColor,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected ? const Color(0xFF151C2C) : const Color(0xAA101725),
          border: Border.all(color: borderColor, width: selected ? 2 : 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (recommended)
              Positioned(
                top: -6,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE59C), Color(0xFFFFB933)],
                    ),
                  ),
                  child: const Text(
                    'SAVE 40%',
                    style: TextStyle(
                      color: Color(0xFF5B3400),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: TextStyle(
                    color: recommended ? const Color(0xFFFFD36A) : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
