import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int selectedIndex = 1;
  Offerings? _offerings;
  bool _loading = true;

  final benefits = const [
    'Unlimited Tokens',
    'All Theme Packs',
    'Custom Images',
    'No Ads',
    'Exclusive Power-ups',
  ];

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _subscribe() async {
    final offering = _offerings?.current;
    if (offering == null || offering.availablePackages.isEmpty) return;
    final index = selectedIndex.clamp(0, offering.availablePackages.length - 1);
    try {
      await Purchases.purchasePackage(offering.availablePackages[index]);
    } catch (_) {}
  }

  Future<void> _restore() async {
    try {
      await Purchases.restorePurchases();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SpaceBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE18A), Color(0xFFFFB22E)],
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x66FFD36A), blurRadius: 22),
                        ],
                      ),
                      child: Icon(Icons.workspace_premium, size: 46, color: Color(0xFF6D4200)),
                    ),
                    SizedBox(height: 18),
                    Text(
                      L.get('go_premium'),
                      style: TextStyle(
                        color: Color(0xFFFFD36A),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Color(0xAAFFD36A), blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: benefits
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _priceCard(
                            index: 0,
                            title: 'MONTHLY',
                            price: '\$6.99/mo',
                            border: const Color(0xFF4EBBFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _priceCard(
                            index: 1,
                            title: 'YEARLY',
                            price: '\$49.99/yr',
                            border: const Color(0xFFFFD36A),
                            recommended: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PremiumButton(
                      text: _loading ? 'LOADING...' : 'SUBSCRIBE',
                      icon: Icons.workspace_premium,
                      gradient: const [Color(0xFFFFE18A), Color(0xFFFFB22E)],
                      onPressed: _loading ? null : _subscribe,
                    ),
                    SizedBox(height: 14),
                    TextButton(
                      onPressed: _restore,
                      child: Text(
                        L.get('restore_purchases'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Payment will be charged to your account. Subscription renews automatically unless canceled at least 24 hours before the end of the current period.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                      border: Border.all(color: const Color(0x44A8D8FF)),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard({
    required int index,
    required String title,
    required String price,
    required Color border,
    bool recommended = false,
  }) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected ? const Color(0x441A1D26) : const Color(0x22161A23),
          border: Border.all(color: border, width: selected ? 2 : 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: border.withOpacity(0.24),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (recommended)
              Positioned(
                top: -8,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE18A), Color(0xFFFFB22E)],
                    ),
                  ),
                  child: const Text(
                    'SAVE 40%',
                    style: TextStyle(
                      color: Color(0xFF5D3600),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: TextStyle(
                    color: recommended ? const Color(0xFFFFD36A) : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: const Color(0x22161A23),
      border: Border.all(color: const Color(0x33D7B15C)),
      boxShadow: const [
        BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
      ],
    );
  }
}