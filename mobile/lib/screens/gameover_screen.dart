import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';

class GameoverScreen extends StatelessWidget {
  final int levelId;
  const GameoverScreen({super.key, this.levelId = 1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'gameover',
          assetPath: 'assets/images/gameover.png',
          showBackButton: true,
          onBack: () {
            AudioService.play('button_click');
            context.go('/menu');
          },
          onNavigate: (target, id) => _navigate(context, target, id),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'retry':
        // Use token / Watch ad → both retry for now (real IAP/ad hook later)
        if (id == 'use-token') AudioService.play('token_insert');
        context.go('/countdown?level=$levelId');
      case 'menu':
        context.go('/menu');
      default:
        break;
    }
  }
}
