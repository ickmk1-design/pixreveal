import 'dart:math';
import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class InsertTokenScreen extends StatefulWidget {
  final int lives;
  final int tokens;
  final VoidCallback? onInsertToken;
  final VoidCallback? onWatchAd;

  const InsertTokenScreen({
    super.key,
    this.lives = 3,
    this.tokens = 50,
    this.onInsertToken,
    this.onWatchAd,
  });

  @override
  State<InsertTokenScreen> createState() => _InsertTokenScreenState();
}

class _InsertTokenScreenState extends State<InsertTokenScreen>
    with TickerProviderStateMixin {
  late AnimationController _coinCtrl;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _coinCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Coin slot
                AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (context, _) {
                    return Container(
                      width: 180,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222233),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade600, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: PixTheme.gold.withOpacity(0.2 + _glowCtrl.value * 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Slot opening
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade500, width: 2),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Animated coin
                          AnimatedBuilder(
                            animation: _coinCtrl,
                            builder: (context, _) {
                              final bounce = sin(_coinCtrl.value * 2 * pi) * 8;
                              return Transform.translate(
                                offset: Offset(0, bounce - 20),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: PixTheme.goldButtonGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: PixTheme.gold.withOpacity(0.6),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFFFFE866), width: 2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF663300),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // INSERT TOKEN text
                const NeonText(
                  text: 'INSERT TOKEN',
                  fontSize: 20,
                  color: PixTheme.gold,
                  glowColor: PixTheme.gold,
                ),

                const SizedBox(height: 24),

                // Hearts
                HeartLives(lives: widget.lives, size: 40),

                const Spacer(flex: 3),

                // Insert token button
                GlowButton(
                  text: 'INSERT TOKEN',
                  gradient: PixTheme.goldButtonGradient,
                  glowColor: PixTheme.gold,
                  height: 56,
                  fontSize: 14,
                  icon: Icons.monetization_on,
                  onTap: widget.onInsertToken,
                  enabled: widget.tokens > 0,
                ),

                const SizedBox(height: 12),

                // Watch ad for free token
                GlowButton(
                  text: 'WATCH AD',
                  gradient: PixTheme.blueButtonGradient,
                  glowColor: const Color(0xFF2288FF),
                  height: 48,
                  fontSize: 12,
                  icon: Icons.play_arrow,
                  onTap: widget.onWatchAd,
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
