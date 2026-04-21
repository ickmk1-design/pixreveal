import 'package:flutter/material.dart';

class HotspotButton extends StatelessWidget {
  final double x, y, w, h;
  final VoidCallback? onTap;
  final bool showDebug;

  const HotspotButton({
    super.key,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.onTap,
    this.showDebug = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: size.width * x / 100,
      top: size.height * y / 100,
      width: size.width * w / 100,
      height: size.height * h / 100,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: showDebug
              ? BoxDecoration(
                  border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
        ),
      ),
    );
  }
}
