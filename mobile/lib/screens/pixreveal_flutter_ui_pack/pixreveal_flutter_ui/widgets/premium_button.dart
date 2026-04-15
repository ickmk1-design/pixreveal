import 'package:flutter/material.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool outlined;
  final bool gold;
  final bool blue;
  final bool compact;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    this.outlined = false,
    this.gold = false,
    this.blue = false,
    this.compact = false,
    this.icon,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gold
        ? const [Color(0xFFFFE59C), Color(0xFFFFB933), Color(0xFFE28E11)]
        : widget.blue
            ? const [Color(0xFF3DB9FF), Color(0xFF1490FF), Color(0xFF0C67D7)]
            : const [Color(0xFFA94EFF), Color(0xFFFF4CB6), Color(0xFFC62B98)];

    final textColor = widget.gold ? const Color(0xFF5B3400) : Colors.white;
    final height = widget.compact ? 50.0 : 62.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        scale: _pressed ? 0.985 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
            color: widget.outlined ? const Color(0x22161A23) : null,
            gradient: widget.outlined
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradient,
                  ),
            border: Border.all(
              color: widget.outlined ? const Color(0xFF475B8A) : const Color(0x55FFFFFF),
              width: 1.2,
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
                      color: gradient.last.withOpacity(0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
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
                    height: height * 0.42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.compact ? 14 : 18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.30),
                          Colors.white.withOpacity(0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: textColor, size: widget.compact ? 18 : 22),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.outlined ? const Color(0xFFE7EEFF) : textColor,
                        fontSize: widget.compact ? 15 : 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
