import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gameplay_overlay.dart';
import '../widgets/countdown_overlay.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _countdownDone = false;

  @override
  Widget build(BuildContext context) {
    if (_countdownDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/hud');
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // HUD PNG background
          Positioned.fill(
            child: Image.asset(
              'assets/images/hud.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          // Gameplay overlay
          const GameplayOverlay(),
          // Countdown overlay
          if (!_countdownDone)
            CountdownOverlay(
              onDone: () => setState(() => _countdownDone = true),
            ),
        ],
      ),
    );
  }
}
