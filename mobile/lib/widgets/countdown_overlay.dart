import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownOverlay extends StatefulWidget {
  final Rect imgRect;
  final VoidCallback onDone;

  const CountdownOverlay({super.key, required this.imgRect, required this.onDone});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  int _n = 3;
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 2.4, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 20),
    ]).animate(_ctrl);
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_ctrl);

    _runTick();
  }

  void _runTick() {
    _ctrl.reset();
    _ctrl.forward().then((_) {
      if (!mounted) return;
      if (_n > 0) {
        setState(() => _n--);
        _runTick();
      } else {
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGo = _n == 0;
    final label = isGo ? 'BAŞLA' : '$_n';
    final color = isGo ? const Color(0xFFFFD700) : const Color(0xFF00D4FF);
    final shadows = isGo
        ? const [
            Shadow(color: Color(0xFFFFD700), blurRadius: 20),
            Shadow(color: Color(0xFFFF9500), blurRadius: 40),
            Shadow(color: Color(0xFFFF006E), blurRadius: 80),
          ]
        : const [
            Shadow(color: Color(0xFF00D4FF), blurRadius: 20),
            Shadow(color: Color(0xFF00D4FF), blurRadius: 40),
            Shadow(color: Color(0xFF0088FF), blurRadius: 80),
          ];

    final r = widget.imgRect;
    return Positioned(
      left: r.left, top: r.top, width: r.width, height: r.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1,
            colors: [Color(0x4D0A0E27), Color(0xD0000000)],
            stops: [0.0, 0.7],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: isGo ? 80 : 180,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: isGo ? 4 : 0,
                    shadows: shadows,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
