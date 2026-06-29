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
  Offset? _center; // local coords within bottom-half widget

  static const double _maxR = 42.0;

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
    final scale = dist > _maxR ? _maxR / dist : 1.0;
    setState(() => _knobOffset = Offset(dx * scale, dy * scale));
    if (dist > 0) widget.onMove?.call(Offset(dx / dist, dy / dist));
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
    final halfH = r.height * 0.50;
    final baseSize = r.width * 0.30;
    final knobSize = r.width * 0.13;

    // Boşta: sağ altta ipucu olarak durur (bottom-half local coords)
    final hintCx = r.width * 0.78;
    final hintCy = halfH * 0.72;

    final cx = _active ? _center!.dx : hintCx;
    final cy = _active ? _center!.dy : hintCy;

    return Positioned(
      left: r.left,
      top: r.top + halfH,
      width: r.width,
      height: halfH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Base ring
            Positioned(
              left: cx - baseSize / 2,
              top: cy - baseSize / 2,
              width: baseSize,
              height: baseSize,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00D4FF)
                        .withValues(alpha: _active ? 0.85 : 0.35),
                    width: 2,
                  ),
                  color: Colors.black.withValues(alpha: _active ? 0.35 : 0.18),
                  boxShadow: _active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              ),
            ),
            // Knob
            Positioned(
              left: cx + _knobOffset.dx - knobSize / 2,
              top: cy + _knobOffset.dy - knobSize / 2,
              width: knobSize,
              height: knobSize,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.white.withValues(alpha: _active ? 0.90 : 0.50),
                      const Color(0xFF00D4FF).withValues(alpha: _active ? 0.80 : 0.40),
                      const Color(0xFF0A2050).withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF)
                          .withValues(alpha: _active ? 0.90 : 0.30),
                      blurRadius: _active ? 20 : 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
