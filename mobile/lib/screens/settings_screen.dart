import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../state/settings_state.dart';
import '../services/audio_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'settings',
          assetPath: 'assets/images/settings.png',
          showBackButton: true,
          onBack: () {
            AudioService.play('button_click');
            context.go('/menu');
          },
          onNavigate: (target, id) => _navigate(context, ref, target, id),
          // Calibrated toggle positions from user tap data:
          // sfx y=24.4, music y=30.3, vibe y=35.8
          overlayBuilder: (size) => [
            if (!s.sfx) _toggleOffOverlay(size, yPercent: 24.4),
            if (!s.music) _toggleOffOverlay(size, yPercent: 30.3),
            if (!s.vibration) _toggleOffOverlay(size, yPercent: 35.8),
          ],
        ),
      ),
    );
  }

  Widget _toggleOffOverlay(Size size, {required double yPercent}) {
    return Positioned(
      left: size.width * 0.78,
      top: size.height * (yPercent - 2.2) / 100,
      width: size.width * 0.16,
      height: size.height * 0.042,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.black.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, WidgetRef ref, String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'menu':
        context.go('/menu');
      case 'toggle-sfx':
        ref.read(settingsProvider.notifier).toggleSfx();
        final newState = ref.read(settingsProvider);
        AudioService.instance.setSfxEnabled(newState.sfx);
      case 'toggle-music':
        ref.read(settingsProvider.notifier).toggleMusic();
        final newState = ref.read(settingsProvider);
        AudioService.instance.setMusicEnabled(newState.music);
      case 'toggle-vibration':
        ref.read(settingsProvider.notifier).toggleVibration();
      case 'none':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Bu özellik yakında',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: const Color(0xFF1A0F2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF00D4FF), width: 1),
            ),
            margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60),
          ),
        );
      default:
        break;
    }
  }
}
