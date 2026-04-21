import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../widgets/gameplay_overlay.dart';
import '../widgets/joystick_overlay.dart';

class HudScreen extends StatelessWidget {
  const HudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          MockupScreen(
            screen: 'hud',
            assetPath: 'assets/images/hud.png',
            onNavigate: (target, id) => _navigate(context, target, id),
          ),
          const GameplayOverlay(),
          JoystickOverlay(onMove: (_) {}),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    switch (target) {
      case 'victory':
        context.go('/victory');
      case 'gameover':
        context.go('/gameover');
    }
  }
}
