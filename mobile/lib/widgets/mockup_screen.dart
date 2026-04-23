import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/hotspots.dart';

class MockupScreen extends StatefulWidget {
  final String screen;
  final String assetPath;
  final void Function(String target, String id)? onNavigate;
  final List<Widget> Function(Size imgSize)? overlayBuilder;
  final bool showDebug;
  final bool calibrateMode;
  final bool scrollable;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget> Function(Size imgSize)? topRightOverlay;

  const MockupScreen({
    super.key,
    required this.screen,
    required this.assetPath,
    this.onNavigate,
    this.overlayBuilder,
    this.showDebug = false,
    this.calibrateMode = false,
    this.scrollable = false,
    this.showBackButton = false,
    this.onBack,
    this.topRightOverlay,
  });

  @override
  State<MockupScreen> createState() => _MockupScreenState();
}

class _MockupScreenState extends State<MockupScreen> {
  final List<Offset> _taps = [];
  final List<String> _labels = [];

  @override
  Widget build(BuildContext context) {
    if (widget.calibrateMode) {
      return Container(
        color: const Color(0xFF050510),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1024 / 1536,
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(widget.assetPath, fit: BoxFit.fill),
                    ),
                    // Önceki tıklamaları göster
                    ..._taps.asMap().entries.map((e) {
                      final i = e.key;
                      final tap = e.value;
                      return Positioned(
                        left: tap.dx - 16,
                        top: tap.dy - 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow.withValues(alpha: 0.7),
                                border: Border.all(color: Colors.orange, width: 2),
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              color: Colors.black.withValues(alpha: 0.8),
                              child: Text(
                                _labels[i],
                                style: const TextStyle(fontSize: 8, color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Tıklama yakalayıcı
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final lx = details.localPosition.dx;
                          final ly = details.localPosition.dy;
                          final xPct = (lx / c.maxWidth * 100).toStringAsFixed(1);
                          final yPct = (ly / c.maxHeight * 100).toStringAsFixed(1);
                          final label = 'x=$xPct% y=$yPct%';
                          // ignore: avoid_print
                          print('🎯 CALIBRATE: x=$xPct%, y=$yPct%  (raw: ${lx.toInt()},${ly.toInt()})');
                          setState(() {
                            _taps.add(Offset(lx, ly));
                            _labels.add(label);
                          });
                        },
                        child: const ColoredBox(color: Colors.transparent, child: SizedBox.expand()),
                      ),
                    ),
                    // Son tıklama bilgisi üstte
                    if (_labels.isNotEmpty)
                      Positioned(
                        bottom: 12,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Son tık: ${_labels.last}\nToplam: ${_taps.length} tıklama',
                            style: const TextStyle(color: Colors.yellow, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    // Temizle butonu
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() { _taps.clear(); _labels.clear(); }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('TEMIZLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    // ── Normal mode ──────────────────────────────────────────────────
    final spots = kHotspots[widget.screen] ?? [];
    return Container(
      color: const Color(0xFF050510),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1024 / 1536,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final h = c.maxHeight;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(widget.assetPath, fit: BoxFit.fill),
                  ),
                  if (widget.overlayBuilder != null) ...widget.overlayBuilder!(Size(w, h)),
                  if (widget.showBackButton)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onBack ?? () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ...spots.map((s) {
                    return Positioned(
                      left: w * s.x / 100,
                      top: h * s.y / 100,
                      width: w * s.w / 100,
                      height: h * s.h / 100,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onNavigate?.call(s.target, s.id),
                        child: widget.showDebug
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
                                  color: const Color(0xFF00D4FF).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  s.id,
                                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              )
                            : const SizedBox.expand(),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
