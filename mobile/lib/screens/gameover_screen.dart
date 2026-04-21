import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';

class GameoverScreen extends StatelessWidget {
  const GameoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'gameover',
        assetPath: 'assets/images/gameover.png',
        onNavigate: (target, id) => _navigate(context, target, id),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    switch (target) {
      case 'hud':
        context.go('/countdown');
      case 'menu':
        context.go('/menu');
    }
  }
}
