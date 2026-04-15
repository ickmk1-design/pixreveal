import 'dart:math';
import 'package:flutter/material.dart';
import 'pix_theme.dart';

// ============================================================
// STAR BACKGROUND - animated twinkling stars over dark gradient
// ============================================================
class StarBackground extends StatefulWidget {
  final Widget child;
  const StarBackground({super.key, required this.child});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: PixTheme.bgGradient),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _StarPainter(_ctrl.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double t;
  _StarPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();

    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final baseR = 0.5 + rng.nextDouble() * 1.5;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble() * 2 * pi;
      final twinkle = 0.3 + (sin(t * 2 * pi * speed + phase) + 1) * 0.35;

      // Star color variation
      final colorSeed = rng.nextDouble();
      Color starColor;
      if (colorSeed < 0.1) {
        starColor = const Color(0xFFAADDFF); // blue-white
      } else if (colorSeed < 0.15) {
        starColor = const Color(0xFFFFDDAA); // warm
      } else if (colorSeed < 0.18) {
        starColor = const Color(0xFFFFAAAA); // red tint
      } else {
        starColor = Colors.white;
      }

      paint.color = starColor.withOpacity(twinkle);
      canvas.drawCircle(Offset(x, y), baseR * twinkle, paint);

      // Glow for bigger stars
      if (baseR > 1.2) {
        paint.color = starColor.withOpacity(twinkle * 0.2);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), baseR * 2, paint);
        paint.maskFilter = null;
      }
    }

    // A few colored nebula patches
    for (int i = 0; i < 3; i++) {
      final nx = rng.nextDouble() * size.width;
      final ny = rng.nextDouble() * size.height;
      final nr = 60 + rng.nextDouble() * 100;
      final nebulaColor = [
        const Color(0x08FF2266),
        const Color(0x082244FF),
        const Color(0x08AA22FF),
      ][i];
      paint.color = nebulaColor;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, nr);
      canvas.drawCircle(Offset(nx, ny), nr, paint);
      paint.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => true;
}

// ============================================================
// GLOW BUTTON - gradient button with glow effect
// ============================================================
class GlowButton extends StatefulWidget {
  final String text;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double fontSize;
  final Color glowColor;
  final IconData? icon;
  final bool enabled;

  const GlowButton({
    super.key,
    required this.text,
    required this.gradient,
    this.onTap,
    this.width = double.infinity,
    this.height = 56,
    this.fontSize = 18,
    this.glowColor = PixTheme.neonPink,
    this.icon,
    this.enabled = true,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final glowIntensity = 0.3 + _ctrl.value * 0.3;
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (widget.enabled) widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.enabled ? widget.gradient : null,
                color: widget.enabled ? null : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: widget.glowColor.withOpacity(glowIntensity),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: widget.glowColor.withOpacity(glowIntensity * 0.5),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: widget.fontSize + 2),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
      },
    );
  }
}

// ============================================================
// OUTLINED BUTTON - dark bg with neon border
// ============================================================
class NeonOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color borderColor;
  final double width;
  final double height;
  final double fontSize;

  const NeonOutlineButton({
    super.key,
    required this.text,
    this.onTap,
    this.borderColor = PixTheme.cardBorder,
    this.width = double.infinity,
    this.height = 52,
    this.fontSize = 16,
  });

  @override
  State<NeonOutlineButton> createState() => _NeonOutlineButtonState();
}

class _NeonOutlineButtonState extends State<NeonOutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: PixTheme.bgDeep.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.borderColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: PixTheme.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NEON TEXT - text with glow shadow
// ============================================================
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color glowColor;
  final TextAlign textAlign;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.color = Colors.white,
    this.glowColor = PixTheme.neonCyan,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
        shadows: [
          Shadow(color: glowColor, blurRadius: 15),
          Shadow(color: glowColor, blurRadius: 30),
          Shadow(color: glowColor.withOpacity(0.5), blurRadius: 60),
        ],
      ),
    );
  }
}

// ============================================================
// TOKEN DISPLAY - coin icon + count
// ============================================================
class TokenDisplay extends StatelessWidget {
  final int count;
  final double size;

  const TokenDisplay({super.key, required this.count, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PixTheme.gold.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: PixTheme.goldButtonGradient,
              boxShadow: [
                BoxShadow(color: PixTheme.gold.withOpacity(0.5), blurRadius: 6),
              ],
            ),
            child: Center(
              child: Text(
                '\$',
                style: TextStyle(
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF663300),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'x$count',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: size * 0.65,
              fontWeight: FontWeight.bold,
              color: PixTheme.gold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PREMIUM BADGE - gold lock icon
// ============================================================
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: PixTheme.premiumBadgeGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: PixTheme.gold.withOpacity(0.4), blurRadius: 8),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Color(0xFF663300), size: 14),
          SizedBox(width: 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF663300),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HEART LIVES - row of hearts
// ============================================================
class HeartLives extends StatelessWidget {
  final int lives;
  final int maxLives;
  final double size;

  const HeartLives({
    super.key,
    required this.lives,
    this.maxLives = 3,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final alive = i < lives;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.favorite,
            size: size,
            color: alive ? PixTheme.redHeart : Colors.grey.shade800,
            shadows: alive
                ? [Shadow(color: PixTheme.redHeart.withOpacity(0.6), blurRadius: 8)]
                : null,
          ),
        );
      }),
    );
  }
}

// ============================================================
// STAR RATING - row of stars
// ============================================================
class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star,
            size: size,
            color: filled ? PixTheme.gold : Colors.grey.shade700,
            shadows: filled
                ? [Shadow(color: PixTheme.gold.withOpacity(0.6), blurRadius: 10)]
                : null,
          ),
        );
      }),
    );
  }
}
