import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/hotspots.dart';
import 'screen_frame.dart';

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
        child: ScreenFrame(
          child: LayoutBuilder(
            builder: (context, c) {
              return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(widget.assetPath, fit: BoxFit.fill),
                    ),
                    // Önceki tıklama noktaları — küçük daire + numara
                    ..._taps.asMap().entries.map((e) {
                      final i = e.key;
                      final tap = e.value;
                      return Positioned(
                        left: tap.dx - 20,
                        top: tap.dy - 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow.withValues(alpha: 0.85),
                            border: Border.all(color: Colors.orange, width: 2.5),
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
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
                          final label = 'x=$xPct  y=$yPct';
                          setState(() {
                            _taps.add(Offset(lx, ly));
                            _labels.add(label);
                          });
                        },
                        child: const ColoredBox(color: Colors.transparent, child: SizedBox.expand()),
                      ),
                    ),
                    // Büyük koordinat kutusu — ekranın ortasında, 2 sn sonra kaybolmaz
                    if (_labels.isNotEmpty)
                      Positioned(
                        top: c.maxHeight * 0.38,
                        left: c.maxWidth * 0.05,
                        right: c.maxWidth * 0.05,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.yellow, width: 2.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#${_taps.length}  ${_labels.last}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tüm tıklamalar: ${_labels.join('  |  ')}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Temizle butonu
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => setState(() { _taps.clear(); _labels.clear(); }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('TEMIZLE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      );
    }

    // ── Normal mode ──────────────────────────────────────────────────
    final spots = kHotspots[widget.screen] ?? [];
    return Container(
      color: const Color(0xFF050510),
      child: ScreenFrame(
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
    );
  }
}
