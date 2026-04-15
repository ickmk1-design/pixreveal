import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  final int tokens;
  final VoidCallback? onPlay;
  final VoidCallback? onShop;
  final VoidCallback? onSettings;

  const HomeScreen({
    super.key,
    this.tokens = 1250,
    this.onPlay,
    this.onShop,
    this.onSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Token display top-right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TokenDisplay(count: widget.tokens),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Spider image
                  Image.asset(
                    'assets/images/spider_hero.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pest_control,
                        size: 120,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PIXREVEAL title with glow
                  const NeonText(
                    text: 'PIXREVEAL',
                    fontSize: 32,
                    glowColor: PixTheme.neonCyan,
                  ),

                  const Spacer(flex: 2),

                  // PLAY button - big, pink/purple gradient, pulsing glow
                  GlowButton(
                    text: 'PLAY',
                    gradient: PixTheme.playButtonGradient,
                    glowColor: PixTheme.neonPink,
                    height: 64,
                    fontSize: 22,
                    onTap: widget.onPlay,
                  ),

                  const SizedBox(height: 16),

                  // SHOP button
                  NeonOutlineButton(
                    text: 'SHOP',
                    onTap: widget.onShop,
                  ),

                  const SizedBox(height: 12),

                  // SETTINGS button
                  NeonOutlineButton(
                    text: 'SETTINGS',
                    onTap: widget.onSettings,
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
