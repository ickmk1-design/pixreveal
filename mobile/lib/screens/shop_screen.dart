import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'shop',
        assetPath: 'assets/images/shop.png',
        scrollable: true,
        onNavigate: (target, id) => _navigate(context, target, id),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    switch (target) {
      case 'paywall':
        context.go('/paywall');
      case 'menu':
        context.go('/menu');
    }
  }
}
