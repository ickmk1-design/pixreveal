import 'package:flutter/material.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color> gradient;
  final double height;
  final bool outlined;
  final Color outlineColor;
  final bool fullWidth;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient = const [Color(0xFF9B4DFF), Color(0xFFFF4FB2)],
    this.height = 62,
    this.outlined = false,
    this.outlineColor = const Color(0x33FFFFFF),
    this.fullWidth = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      duration: const Duration(milliseconds: 90),
      scale: _pressed ? 0.97 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: widget.height,
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.outlined
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
          color: widget.outlined ? const Color(0x14171D2A) : null,
          border: Border.all(
            color: widget.outlined ? widget.outlineColor : Colors.white24,
            width: widget.outlined ? 1.4 : 1.0,
          ),
          boxShadow: widget.outlined
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.gradient.last.withOpacity(0.34),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  const BoxShadow(
                    color: Color(0x55FFFFFF),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (!widget.outlined)
              Positioned(
                top: 2,
                left: 2,
                right: 2,
                child: Container(
                  height: widget.height * 0.42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.28),
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: child,
    );
  }
}