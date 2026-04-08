import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';
import '../widgets/token_display.dart';
import '../providers/token_provider.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    // Load banner ad (only if not ad-free)
    final userState = ref.read(userProvider);
    if (!userState.isAdFree) {
      _bannerAd = ref.read(adServiceProvider).createBanner();
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Try claim daily login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final claimed = ref.read(tokenProvider.notifier).claimDailyLogin();
      if (claimed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkCard,
            content: Row(
              children: [
                Icon(Icons.card_giftcard, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(
                  'Daily Bonus: +${GameConfig.dailyLoginTokens} Tokens!',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Grid background
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _GridPainter(),
            ),

            // Content
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Token display top-right
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const TokenDisplay(),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Title
                  AnimatedBuilder(
                    listenable: _pulseController,
                    builder: (context, _) {
                      final glow = 8.0 + _pulseController.value * 12;
                      return Text(
                        'PIXREVEAL',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 28,
                          color: AppColors.neonPink,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: AppColors.neonPink,
                              blurRadius: glow,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'REVEAL THE HIDDEN',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 9,
                      color: AppColors.neonBlue.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Menu buttons
                  NeonButton(
                    text: 'PLAY',
                    onPressed: () => context.go('/levels'),
                    color: AppColors.neonGreen,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    text: 'SHOP',
                    onPressed: () => context.go('/shop'),
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    text: 'SETTINGS',
                    onPressed: () => context.go('/settings'),
                    color: AppColors.neonBlue,
                  ),

                  const Spacer(flex: 3),

                  // Banner ad
                  if (_bannerAd != null)
                    SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  const SizedBox(height: 8),

                  // Version
                  Text(
                    'v1.0.0 - CYT Bilisim',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 7,
                      color: AppColors.gridLine,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
