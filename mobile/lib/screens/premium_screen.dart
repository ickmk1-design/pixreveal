import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class PremiumScreen extends StatefulWidget {
  final String monthlyPrice;
  final String yearlyPrice;
  final String yearlyDiscount;
  final VoidCallback? onClose;
  final VoidCallback? onSubscribeMonthly;
  final VoidCallback? onSubscribeYearly;
  final VoidCallback? onRestorePurchases;

  const PremiumScreen({
    super.key,
    this.monthlyPrice = '\$6.99/mo',
    this.yearlyPrice = '\$49.99/yr',
    this.yearlyDiscount = 'SAVE 40%',
    this.onClose,
    this.onSubscribeMonthly,
    this.onSubscribeYearly,
    this.onRestorePurchases,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _yearlySelected = true;

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
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
            child: Stack(
              children: [
                // Close button
                Positioned(
                  top: 8,
                  right: 16,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Crown icon
                      Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: PixTheme.gold,
                        shadows: [
                          Shadow(color: PixTheme.gold.withOpacity(0.6), blurRadius: 20),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // GO PREMIUM
                      const NeonText(
                        text: 'GO PREMIUM',
                        fontSize: 28,
                        color: PixTheme.gold,
                        glowColor: PixTheme.gold,
                      ),

                      const SizedBox(height: 32),

                      // Features list
                      _buildFeatureRow(Icons.all_inclusive, 'Unlimited Tokens'),
                      _buildFeatureRow(Icons.palette, 'All Theme Packs'),
                      _buildFeatureRow(Icons.add_photo_alternate, 'Custom Images'),
                      _buildFeatureRow(Icons.block, 'No Ads'),
                      _buildFeatureRow(Icons.bolt, 'Exclusive Power-ups'),

                      const SizedBox(height: 32),

                      // Pricing options
                      Row(
                        children: [
                          // Monthly
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _yearlySelected = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: !_yearlySelected
                                      ? PixTheme.neonCyan.withOpacity(0.1)
                                      : PixTheme.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !_yearlySelected
                                        ? PixTheme.neonCyan.withOpacity(0.6)
                                        : PixTheme.cardBorder,
                                    width: !_yearlySelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'MONTHLY',
                                      style: TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: 9,
                                        color: Colors.white60,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.monthlyPrice,
                                      style: const TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Yearly
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _yearlySelected = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _yearlySelected
                                      ? PixTheme.gold.withOpacity(0.1)
                                      : PixTheme.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _yearlySelected
                                        ? PixTheme.gold.withOpacity(0.6)
                                        : PixTheme.cardBorder,
                                    width: _yearlySelected ? 2 : 1,
                                  ),
                                  boxShadow: _yearlySelected
                                      ? [BoxShadow(color: PixTheme.gold.withOpacity(0.2), blurRadius: 15)]
                                      : [],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'RECOMMENDED',
                                          style: TextStyle(
                                            fontFamily: 'PressStart2P',
                                            fontSize: 7,
                                            color: PixTheme.gold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.yearlyPrice,
                                          style: const TextStyle(
                                            fontFamily: 'PressStart2P',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Save badge
                                    Positioned(
                                      top: -8,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          gradient: PixTheme.goldButtonGradient,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          widget.yearlyDiscount,
                                          style: const TextStyle(
                                            fontFamily: 'PressStart2P',
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF663300),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Restore purchases
                      GestureDetector(
                        onTap: widget.onRestorePurchases,
                        child: const Text(
                          'Restore Purchases',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SUBSCRIBE button
                      GlowButton(
                        text: 'SUBSCRIBE',
                        gradient: PixTheme.goldButtonGradient,
                        glowColor: PixTheme.gold,
                        height: 56,
                        fontSize: 16,
                        onTap: _yearlySelected
                            ? widget.onSubscribeYearly
                            : widget.onSubscribeMonthly,
                      ),

                      const Spacer(),

                      // Legal text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Cancel at any time. By subscribing you will pay the stated price for your region. Subscriptions automatically renew unless canceled at least one day before the renewal. By subscribing, you agree with our Terms of Service and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.3),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check, color: PixTheme.emerald, size: 22),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
