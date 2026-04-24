import 'package:flutter/material.dart';

class ScreenFrame extends StatelessWidget {
  final Widget child;

  const ScreenFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;
        const targetRatio = 9 / 16;
        double width = screenW;
        double height = width / targetRatio;

        if (height > screenH) {
          height = screenH;
          width = height * targetRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        );
      },
    );
  }
}
