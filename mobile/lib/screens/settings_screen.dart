import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../state/settings_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final size = MediaQuery.of(context).size;

    // Toggle OFF overlays — cover the green toggle with a grey one
    final toggleRows = [
      (key: 'sfx', y: 14.8, on: settings.sfx),
      (key: 'music', y: 21.4, on: settings.music),
      (key: 'vibe', y: 27.9, on: settings.vibration),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'settings',
        assetPath: 'assets/images/settings.png',
        scrollable: true,
        onNavigate: (target, id) => _navigate(context, ref, target, id),
        overlays: [
          for (final row in toggleRows)
            if (!row.on)
              Positioned(
                left: size.width * 0.78,
                top: size.height * row.y / 100,
                width: size.width * 0.17,
                height: size.height * 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xEB3C1E32), Color(0xEB502846)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FF006E),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.centerLeft,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.35, -0.3),
                          colors: [Colors.white, Color(0xFFCCCCCC), Color(0xFF888888)],
                          stops: [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, WidgetRef ref, String target, String id) {
    switch (id) {
      case 'sfx':
        ref.read(settingsProvider.notifier).toggleSfx();
        return;
      case 'music':
        ref.read(settingsProvider.notifier).toggleMusic();
        return;
      case 'vibe':
        ref.read(settingsProvider.notifier).toggleVibration();
        return;
    }
    switch (target) {
      case 'menu':
        context.go('/menu');
    }
  }
}
