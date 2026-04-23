import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/countdown_overlay.dart';

class CountdownScreen extends StatefulWidget {
  final int levelId;
  const CountdownScreen({super.key, this.levelId = 1});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _done = false;

  void _onDone() {
    if (_done || !mounted) return;
    _done = true;
    context.go('/hud?level=${widget.levelId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1024 / 1536,
            child: LayoutBuilder(
              builder: (context, c) {
                final rect = Rect.fromLTWH(0, 0, c.maxWidth, c.maxHeight);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xFF1A0F2E), Color(0xFF050510)],
                            radius: 1.2,
                          ),
                        ),
                      ),
                    ),
                    CountdownOverlay(imgRect: rect, onDone: _onDone),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
