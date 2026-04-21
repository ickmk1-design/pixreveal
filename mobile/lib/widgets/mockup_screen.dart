import 'package:flutter/material.dart';
import '../constants/hotspots.dart';
import 'hotspot_button.dart';

class MockupScreen extends StatelessWidget {
  final String screen;
  final String assetPath;
  final void Function(String target, String id)? onNavigate;
  final List<Widget>? overlays;
  final bool showDebug;
  final bool scrollable;

  const MockupScreen({
    super.key,
    required this.screen,
    required this.assetPath,
    this.onNavigate,
    this.overlays,
    this.showDebug = false,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final spots = kHotspots[screen] ?? [];

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        return SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              // PNG background — contain, full screen
              Positioned.fill(
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              // Hotspot buttons
              ...spots.map((s) => HotspotButton(
                    x: s.x,
                    y: s.y,
                    w: s.w,
                    h: s.h,
                    showDebug: showDebug,
                    onTap: s.target == 'none'
                        ? null
                        : () => onNavigate?.call(s.target, s.id),
                  )),
              // Extra overlays
              if (overlays != null) ...overlays!,
            ],
          ),
        );
      },
    );

    if (scrollable) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: content,
      );
    }
    return content;
  }
}
