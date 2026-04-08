import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/iap_service.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String feature;

  const PaywallScreen({super.key, required this.feature});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<StoreProduct> _products = [];
  bool _loading = true;

  String get feature => widget.feature;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final iap = ref.read(iapServiceProvider);

    List<String> productIds;
    switch (feature) {
      case 'premium':
        productIds = [IAPProducts.premiumYearly, IAPProducts.premiumMonthly];
      case 'custom_image':
        productIds = [IAPProducts.customYearly, IAPProducts.customMonthly];
      case 'ad_free':
        productIds = [IAPProducts.removeAds];
      default:
        productIds = [];
    }

    final products = await iap.getProducts(productIds);
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _purchase(StoreProduct product) async {
    final iap = ref.read(iapServiceProvider);
    final info = await iap.purchase(product);
    if (info != null && mounted) {
      await ref.read(userProvider.notifier).refreshEntitlements();
      if (mounted) context.pop();
    }
  }

  Future<void> _restore() async {
    final iap = ref.read(iapServiceProvider);
    await iap.restorePurchases();
    await ref.read(userProvider.notifier).refreshEntitlements();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored')),
      );
    }
  }

  String get _title {
    switch (feature) {
      case 'custom_image':
        return 'CUSTOM IMAGE';
      case 'premium':
        return 'PREMIUM';
      case 'ad_free':
        return 'AD FREE';
      default:
        return 'UNLOCK';
    }
  }

  List<String> get _benefits {
    switch (feature) {
      case 'custom_image':
        return [
          'Use your own photos',
          'Unlimited custom levels',
          'Choose difficulty',
        ];
      case 'premium':
        return [
          'All theme packs unlocked',
          'Custom image included',
          'No ads',
          'Exclusive levels',
          '50 bonus tokens/month',
        ];
      case 'ad_free':
        return [
          'Remove all advertisements',
          'Cleaner experience',
          'One-time purchase',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonPink, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPink.withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_open,
                color: AppColors.neonPink,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'UNLOCK $_title',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: AppColors.neonPink,
                shadows: [Shadow(color: AppColors.neonPink, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 24),

            // Benefits
            ..._benefits.map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.neonGreen, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const Spacer(),

            // Dynamic purchase buttons from RevenueCat
            if (_loading)
              const CircularProgressIndicator(color: AppColors.neonPink)
            else if (_products.isEmpty)
              _fallbackButtons()
            else
              ..._products.asMap().entries.map((entry) {
                final i = entry.key;
                final product = entry.value;
                final isFirst = i == 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      NeonButton(
                        text: _formatProductTitle(product),
                        color: isFirst ? AppColors.neonPink : AppColors.neonBlue,
                        width: double.infinity,
                        fontSize: 9,
                        onPressed: () => _purchase(product),
                      ),
                      if (isFirst && _products.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _savingsLabel(),
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 7,
                              color: AppColors.neonGreen.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 4),

            // Restore purchases
            TextButton(
              onPressed: _restore,
              child: const Text(
                'RESTORE PURCHASES',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 7,
                  color: AppColors.neonBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatProductTitle(StoreProduct product) {
    final price = product.priceString;
    final id = product.identifier;
    if (id.contains('yearly')) return 'YEARLY $price/yr';
    if (id.contains('monthly')) return 'MONTHLY $price/mo';
    return '$price';
  }

  String _savingsLabel() {
    if (feature == 'premium') return 'Save 40%';
    if (feature == 'custom_image') return 'Save 44%';
    return '';
  }

  /// Fallback when RevenueCat offerings aren't loaded yet
  Widget _fallbackButtons() {
    final iap = ref.read(iapServiceProvider);

    switch (feature) {
      case 'premium':
        return Column(
          children: [
            NeonButton(
              text: 'YEARLY \$49.99/yr',
              color: AppColors.neonPink,
              width: double.infinity,
              fontSize: 9,
              onPressed: () async {
                final products =
                    await iap.getProducts([IAPProducts.premiumYearly]);
                if (products.isNotEmpty) _purchase(products.first);
              },
            ),
            const SizedBox(height: 12),
            NeonButton(
              text: 'MONTHLY \$6.99/mo',
              color: AppColors.neonBlue,
              width: double.infinity,
              fontSize: 9,
              onPressed: () async {
                final products =
                    await iap.getProducts([IAPProducts.premiumMonthly]);
                if (products.isNotEmpty) _purchase(products.first);
              },
            ),
          ],
        );
      case 'custom_image':
        return Column(
          children: [
            NeonButton(
              text: 'YEARLY \$19.99/yr',
              color: AppColors.neonPink,
              width: double.infinity,
              fontSize: 9,
              onPressed: () async {
                final products =
                    await iap.getProducts([IAPProducts.customYearly]);
                if (products.isNotEmpty) _purchase(products.first);
              },
            ),
            const SizedBox(height: 12),
            NeonButton(
              text: 'MONTHLY \$2.99/mo',
              color: AppColors.neonBlue,
              width: double.infinity,
              fontSize: 9,
              onPressed: () async {
                final products =
                    await iap.getProducts([IAPProducts.customMonthly]);
                if (products.isNotEmpty) _purchase(products.first);
              },
            ),
          ],
        );
      case 'ad_free':
        return NeonButton(
          text: 'REMOVE ADS \$3.99',
          color: AppColors.neonPink,
          width: double.infinity,
          fontSize: 9,
          onPressed: () async {
            final products =
                await iap.getProducts([IAPProducts.removeAds]);
            if (products.isNotEmpty) _purchase(products.first);
          },
        );
      default:
        return const SizedBox();
    }
  }
}
