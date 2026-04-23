import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/level_progress.dart';
import '../services/audio_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'categories',
          assetPath: 'assets/images/categories.png',
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
    if (target == 'menu') {
      context.go('/menu');
      return;
    }
    if (target == 'paywall') {
      context.go('/paywall');
      return;
    }
    if (target.startsWith('cat:')) {
      final key = target.substring(4);
      final cat = switch (key) {
        'cars' => GameCategory.cars,
        'space' => GameCategory.space,
        'animals' => GameCategory.animals,
        'fitness' => GameCategory.fitness,
        'beach' => GameCategory.beach,
        _ => GameCategory.cars,
      };
      CurrentCategory.set(cat);
      context.go('/levels');
      return;
    }
  }
}
