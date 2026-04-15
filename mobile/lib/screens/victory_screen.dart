import 'dart:math';
import 'package:flutter/material.dart';
import 'pix_theme.dart';
import 'shared_widgets.dart';

class VictoryScreen extends StatefulWidget {
  final int stars;
  final int score;
  final int combo;
  final String time;
  final String? imageAsset;
  final VoidCallback? onNextLevel;
  final VoidCallback? onRetry;
  final VoidCallback? onMenu;

  const VictoryScreen({
    super.key,
    this.stars = 3,
    this.score = 12450,
    this.combo = 3,
    this.time = '01:23',
    this.imageAsset,
    this.onNextLevel,
    this.onRetry,
    this.onMenu,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _starCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _confettiCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(_confettiCtrl.value),
                );
              },
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // VICTORY! title
                      const NeonText(
                        text: 'VICTORY!',
                        fontSize: 36,
                        color: PixTheme.gold,
                        glowColor: PixTheme.gold,
                      ),

                      const SizedBox(height: 16),

                      // Stars with animation
                      AnimatedBuilder(
                        animation: _starCtrl,
                        builder: (context, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final delay = i * 0.25;
                              final progress = ((_starCtrl.value - delay) / 0.4).clamp(0.0, 1.0);
                              final filled = i < widget.stars;
                              return Transform.scale(
                                scale: filled ? (0.3 + 0.7 * Curves.elasticOut.transform(progress)) : 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.star,
                                    size: 48,
                                    color: filled && progress > 0 ? PixTheme.gold : Colors.grey.shade700,
                                    shadows: filled && progress > 0
                                        ? [Shadow(color: PixTheme.gold.withOpacity(0.8), blurRadius: 15)]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Revealed image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PixTheme.neonCyan.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(color: PixTheme.neonCyan.withOpacity(0.2), blurRadius: 15),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.imageAsset != null
                              ? Image.asset(widget.imageAsset!, fit: BoxFit.cover)
                              : Container(
                                  color: PixTheme.bgDeep,
                                  child: const Icon(Icons.image, color: Colors.white24, size: 60),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Score
                      Text(
                        'SCORE: ${widget.score.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Combo
                      Text(
                        'COMBO BONUS: x${widget.combo}',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: PixTheme.neonCyan,
                          shadows: [
                            Shadow(color: PixTheme.neonCyan.withOpacity(0.5), blurRadius: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Time
                      Text(
                        'TIME: ${widget.time}',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Next Level button
                      GlowButton(
                        text: 'NEXT LEVEL',
                        gradient: PixTheme.playButtonGradient,
                        glowColor: PixTheme.neonPink,
                        height: 56,
                        fontSize: 16,
                        onTap: widget.onNextLevel,
                      ),

                      const SizedBox(height: 12),

                      // Retry + Menu row
                      Row(
                        children: [
                          Expanded(
                            child: NeonOutlineButton(
                              text: 'RETRY',
                              height: 48,
                              fontSize: 12,
                              onTap: widget.onRetry,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeonOutlineButton(
                              text: 'MENU',
                              height: 48,
                              fontSize: 12,
                              onTap: widget.onMenu,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(99);
    final paint = Paint();

    final colors = [
      PixTheme.gold,
      PixTheme.neonPink,
      PixTheme.neonCyan,
      PixTheme.neonPurple,
      Colors.white,
      const Color(0xFFFF6600),
    ];

    for (int i = 0; i < 60; i++) {
      final startX = rng.nextDouble() * size.width;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble() * 2 * pi;

      final x = startX + sin(t * 2 * pi * 0.5 + phase) * 30;
      final y = ((t * speed + rng.nextDouble()) % 1.2) * size.height;
      final rotation = t * 2 * pi * speed;

      paint.color = colors[i % colors.length].withOpacity(0.7);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 4 + rng.nextDouble() * 4, height: 2 + rng.nextDouble() * 3),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
