import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'victory',
        assetPath: 'assets/images/victory.png',
        onNavigate: (target, id) => _navigate(context, target, id),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    switch (target) {
      case 'levels':
        context.go('/levels');
      case 'hud':
        context.go('/countdown');
      case 'menu':
        context.go('/menu');
    }
  }
}
