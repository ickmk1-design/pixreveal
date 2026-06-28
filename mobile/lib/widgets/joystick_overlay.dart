import 'package:flutter/material.dart';
import 'dart:math' show sqrt;

class JoystickOverlay extends StatefulWidget {
  final Rect imgRect;
  final void Function(Offset direction)? onMove;

  const JoystickOverlay({super.key, required this.imgRect, this.onMove});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay> {
  Offset _knobOffset = Offset.zero;
  bool _active = false;
  Offset? _center;

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _active = true;
      _center = d.localPosition;
      _knobOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_center == null) return;
    final dx = d.localPosition.dx - _center!.dx;
    final dy = d.localPosition.dy - _center!.dy;
    final dist = sqrt(dx * dx + dy * dy);
    const maxR = 30.0;
    final scale = dist > maxR ? maxR / dist : 1.0;
    final clamped = Offset(dx * scale, dy * scale);
    setState(() => _knobOffset = clamped);
    if (dist > 0) {
      widget.onMove?.call(Offset(dx / dist, dy / dist));
    }
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      _active = false;
      _knobOffset = Offset.zero;
      _center = null;
    });
    widget.onMove?.call(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.imgRect;
    final joystickSize = r.width * 0.28;
    final knobSize = r.width * 0.12;

    return Positioned(
      left: r.left + r.width * 0.08,
      top: r.top + r.height * (1.0 - 0.09) - joystickSize,
      width: joystickSize,
      height: joystickSize,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Static base ring — always visible
            Container(
              width: joystickSize,
              height: joystickSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: _active ? 0.85 : 0.45),
                  width: 2,
                ),
                color: Colors.black.withValues(alpha: 0.30),
                boxShadow: _active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
            // Knob
            AnimatedContainer(
              duration: _active ? Duration.zero : const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: knobSize,
              height: knobSize,
              transform: Matrix4.translationValues(
                _knobOffset.dx,
                _knobOffset.dy,
                0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    Colors.white.withValues(alpha: _active ? 0.9 : 0.6),
                    const Color(0xFF00D4FF).withValues(alpha: _active ? 0.8 : 0.5),
                    const Color(0xFF0A2050).withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withValues(alpha: _active ? 0.9 : 0.4),
                    blurRadius: _active ? 20 : 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
