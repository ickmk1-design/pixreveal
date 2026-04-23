import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'menu',
          assetPath: 'assets/images/menu.png',
          onNavigate: (target, id) => _navigate(context, target),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String target) {
    AudioService.play('button_click');
    switch (target) {
      case 'categories':
        context.go('/categories');
      case 'shop':
        context.go('/shop');
      case 'settings':
        context.go('/settings');
      default:
        break;
    }
  }
}
