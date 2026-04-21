import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'menu',
        assetPath: 'assets/images/menu.png',
        onNavigate: (target, id) => _navigate(context, target, id),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    switch (target) {
      case 'categories':
        context.go('/categories');
      case 'shop':
        context.go('/shop');
      case 'settings':
        context.go('/settings');
    }
  }
}
