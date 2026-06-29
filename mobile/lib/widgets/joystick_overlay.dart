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

  static const double _maxR = 42.0;
  static const double _dotR = 20.0; // görsel nokta yarıçapı

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
        child: _active
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  // Parmağın altında minik neon nokta
                  Positioned(
                    left: _center!.dx + _knobOffset.dx - _dotR,
                    top: _center!.dy + _knobOffset.dy - _dotR,
                    width: _dotR * 2,
                    height: _dotR * 2,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.55),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF00D4FF),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.expand(), // boşta hiçbir şey yok
      ),
    );
  }
}
