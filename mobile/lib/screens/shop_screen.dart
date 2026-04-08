import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../widgets/token_display.dart';
import '../widgets/retro_card.dart';
import '../providers/token_provider.dart';
import '../providers/auth_provider.dart';
import '../services/iap_service.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);
    final iap = ref.read(iapServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonBlue),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text(
          'SHOP',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TokenDisplay(),
            const SizedBox(height: 24),

            // Free tokens section
            RetroCard(
              borderColor: AppColors.neonGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FREE TOKENS',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.neonGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _shopItem(
                    'Watch Ad',
                    '+1 Token',
                    '${tokenState.adsWatchedToday}/10 today',
                    tokenState.canWatchAd,
                    () {
                      final adService = ref.read(adServiceProvider);
                      adService.showRewarded(
                        onRewarded: () {
                          ref.read(tokenProvider.notifier).claimAdReward();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Token packs
            RetroCard(
              borderColor: AppColors.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOKEN PACKS',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _tokenPackItem('20 Tokens', '\$0.99', IAPProducts.tokenPack20, iap, ref),
                  const SizedBox(height: 8),
                  _tokenPackItem('50 Tokens', '\$1.99', IAPProducts.tokenPack50, iap, ref),
                  const SizedBox(height: 8),
                  _tokenPackItem('120 Tokens', '\$4.99', IAPProducts.tokenPack120, iap, ref),
                  const SizedBox(height: 8),
                  _tokenPackItem('300 Tokens', '\$9.99', IAPProducts.tokenPack300, iap, ref),
                  const SizedBox(height: 8),
                  _tokenPackItem('750 Tokens', '\$19.99', IAPProducts.tokenPack750, iap, ref),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Theme packs
            RetroCard(
              borderColor: AppColors.neonPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THEME PACKS',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.neonPink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _iapItem('Art Collection', '\$2.99', IAPProducts.themeArt, iap, ref),
                  const SizedBox(height: 8),
                  _iapItem('Cars & Speed', '\$2.99', IAPProducts.themeCars, iap, ref),
                  const SizedBox(height: 8),
                  _iapItem('Fantasy World', '\$2.99', IAPProducts.themeFantasy, iap, ref),
                  const SizedBox(height: 8),
                  _iapItem('Neon City', '\$2.99', IAPProducts.themeNeon, iap, ref),
                  const SizedBox(height: 8),
                  _iapItem('Legends', '\$3.99', IAPProducts.themeLegend, iap, ref),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subscriptions & one-time
            RetroCard(
              borderColor: AppColors.neonBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.neonBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _premiumItem(
                    context,
                    'Remove Ads',
                    '\$3.99 once',
                    'ad_free',
                    AppColors.neonGreen,
                  ),
                  const SizedBox(height: 8),
                  _premiumItem(
                    context,
                    'Custom Image',
                    'from \$2.99/mo',
                    'custom_image',
                    AppColors.neonPink,
                  ),
                  const SizedBox(height: 8),
                  _premiumItem(
                    context,
                    'Premium All-in-One',
                    'from \$6.99/mo',
                    'premium',
                    AppColors.gold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Restore purchases
            TextButton(
              onPressed: () async {
                await iap.restorePurchases();
                ref.read(userProvider.notifier).refreshEntitlements();
              },
              child: const Text(
                'RESTORE PURCHASES',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
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

  Widget _shopItem(
    String title,
    String reward,
    String subtitle,
    bool enabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.neonGreen.withValues(alpha: 0.1)
              : AppColors.gridLine.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled ? AppColors.neonGreen : AppColors.gridLine,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill,
                color: enabled ? AppColors.neonGreen : AppColors.gridLine,
                size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 9,
                        color: enabled ? AppColors.white : AppColors.gridLine,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 7,
                        color: AppColors.gridLine,
                      )),
                ],
              ),
            ),
            Text(reward,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 9,
                  color: enabled ? AppColors.gold : AppColors.gridLine,
                )),
          ],
        ),
      ),
    );
  }

  Widget _tokenPackItem(
    String name,
    String price,
    String productId,
    IAPService iap,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () async {
        final products = await iap.getProducts([productId]);
        if (products.isNotEmpty) {
          final info = await iap.purchase(products.first);
          if (info != null) {
            // Token count would be granted server-side via webhook
          }
        }
      },
      child: _iapRow(name, price, AppColors.gold),
    );
  }

  Widget _iapItem(
    String name,
    String price,
    String productId,
    IAPService iap,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () async {
        final products = await iap.getProducts([productId]);
        if (products.isNotEmpty) {
          await iap.purchase(products.first);
          await ref.read(userProvider.notifier).refreshEntitlements();
        }
      },
      child: _iapRow(name, price, AppColors.neonPink),
    );
  }

  Widget _premiumItem(
    BuildContext context,
    String name,
    String price,
    String feature,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => context.push('/paywall/$feature'),
      child: _iapRow(name, price, color),
    );
  }

  Widget _iapRow(String name, String price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
                  color: AppColors.white,
                )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(price,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 7,
                  color: AppColors.darkBg,
                )),
          ),
        ],
      ),
    );
  }
}
