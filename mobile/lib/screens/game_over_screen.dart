import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class GameOverScreen extends StatefulWidget {
  final int tokens;
  final VoidCallback? onUseToken;
  final VoidCallback? onWatchAd;
  final VoidCallback? onQuit;

  const GameOverScreen({
    super.key,
    this.tokens = 0,
    this.onUseToken,
    this.onWatchAd,
    this.onQuit,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Spider image
                  Image.asset(
                    'assets/images/spider_hero.png',
                    width: 220,
                    height: 220,
                    errorBuilder: (_, __, ___) => Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 50,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pest_control,
                        size: 140,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // GAME OVER text
                  const NeonText(
                    text: 'GAME OVER',
                    fontSize: 32,
                    color: Color(0xFFFF4444),
                    glowColor: Color(0xFFFF2222),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Continue?',
                    style: PixTheme.bodyStyle.copyWith(
                      color: Colors.white60,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // USE 1 TOKEN button
                  GlowButton(
                    text: 'USE 1 TOKEN',
                    gradient: PixTheme.goldButtonGradient,
                    glowColor: PixTheme.gold,
                    height: 56,
                    fontSize: 14,
                    icon: Icons.monetization_on,
                    onTap: widget.onUseToken,
                    enabled: widget.tokens > 0,
                  ),

                  const SizedBox(height: 12),

                  // WATCH AD button
                  GlowButton(
                    text: 'WATCH AD',
                    gradient: PixTheme.blueButtonGradient,
                    glowColor: const Color(0xFF2288FF),
                    height: 56,
                    fontSize: 14,
                    icon: Icons.play_arrow,
                    onTap: widget.onWatchAd,
                  ),

                  const SizedBox(height: 12),

                  // QUIT button
                  NeonOutlineButton(
                    text: 'QUIT',
                    borderColor: Colors.grey.shade700,
                    height: 48,
                    fontSize: 14,
                    onTap: widget.onQuit,
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
