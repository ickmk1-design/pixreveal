import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' show pi;

class GameplayOverlay extends StatefulWidget {
  const GameplayOverlay({super.key});

  @override
  State<GameplayOverlay> createState() => _GameplayOverlayState();
}

class _GameplayOverlayState extends State<GameplayOverlay>
    with TickerProviderStateMixin {
  late AnimationController _tarantulaCtrl;
  late AnimationController _cursorCtrl;
  late AnimationController _dashCtrl;
  late Animation<double> _tarantulaY;
  late Animation<double> _tarantulaR;
  late Animation<double> _cursorGlow;
  late Animation<double> _dashOffset;

  @override
  void initState() {
    super.initState();
    _tarantulaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _tarantulaY = Tween(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _tarantulaCtrl, curve: Curves.easeInOut),
    );
    _tarantulaR = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _tarantulaCtrl, curve: Curves.easeInOut),
    );

    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _cursorGlow = Tween(begin: 12.0, end: 18.0).animate(
      CurvedAnimation(parent: _cursorCtrl, curve: Curves.easeInOut),
    );

    _dashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
    _dashOffset = Tween(begin: 0.0, end: -7.0).animate(_dashCtrl);
  }

  @override
  void dispose() {
    _tarantulaCtrl.dispose();
    _cursorCtrl.dispose();
    _dashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final overlayLeft = size.width * 0.02;
    final overlayTop = size.height * 0.07;
    final overlayWidth = size.width * 0.96;
    final overlayHeight = size.height * 0.86;

    return Positioned(
      left: overlayLeft,
      top: overlayTop,
      width: overlayWidth,
      height: overlayHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Blurred dark background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1428), Color(0xFF050A14)],
                ),
              ),
            ),
            // Radial vignette
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1,
                  colors: [Colors.transparent, Color(0x66000000)],
                ),
              ),
            ),
            // Territory + trail — animated painter
            AnimatedBuilder(
              animation: Listenable.merge([_dashOffset]),
              builder: (_, __) => CustomPaint(
                size: Size(overlayWidth, overlayHeight),
                painter: _TerritoryPainter(dashOffset: _dashOffset.value),
              ),
            ),
            // Progress label
            Positioned(
              left: overlayWidth * 0.10,
              top: overlayHeight * 0.10,
              child: Text(
                '45.2%',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: const Color(0xFF00D4FF),
                  shadows: const [
                    Shadow(color: Color(0xFF00D4FF), blurRadius: 8),
                    Shadow(color: Colors.black, blurRadius: 2),
                  ],
                ),
              ),
            ),
            // Tarantula
            AnimatedBuilder(
              animation: _tarantulaCtrl,
              builder: (_, child) => Positioned(
                left: overlayWidth * 0.32,
                top: overlayHeight * 0.30 + _tarantulaY.value,
                width: overlayWidth * 0.30,
                child: Transform.rotate(
                  angle: _tarantulaR.value * pi / 180,
                  child: child,
                ),
              ),
              child: Image.asset(
                'assets/images/tarantula.png',
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            // Cursor
            AnimatedBuilder(
              animation: _cursorCtrl,
              builder: (_, __) => Positioned(
                left: overlayWidth * 0.48 - 7,
                top: overlayHeight * 0.72 - 7,
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFF00D4FF), Color(0xFF0088FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF),
                          blurRadius: _cursorGlow.value,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerritoryPainter extends CustomPainter {
  final double dashOffset;
  _TerritoryPainter({required this.dashOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Captured territory polygon: 0,0 100,0 100,28 62,28 62,54 26,54 26,100 0,100
    final poly = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.28)
      ..lineTo(w * 0.62, h * 0.28)
      ..lineTo(w * 0.62, h * 0.54)
      ..lineTo(w * 0.26, h * 0.54)
      ..lineTo(w * 0.26, h)
      ..lineTo(0, h)
      ..close();

    // Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x4700D4FF), Color(0x59FF006E)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(poly, fillPaint);

    // Stroke with glow
    canvas.drawPath(
      poly,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = const Color(0xFF00D4FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      poly,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = const Color(0xFF00D4FF),
    );

    // Trail L-shape: 84,92 → 84,72 → 54,72
    final trailPoints = [
      Offset(w * 0.84, h * 0.92),
      Offset(w * 0.84, h * 0.72),
      Offset(w * 0.54, h * 0.72),
    ];
    final trailPath = Path()
      ..moveTo(trailPoints[0].dx, trailPoints[0].dy)
      ..lineTo(trailPoints[1].dx, trailPoints[1].dy)
      ..lineTo(trailPoints[2].dx, trailPoints[2].dy);

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [Color(0xE6FF006E), Color(0xFFFF006E), Color(0xFF00D4FF)],
      ).createShader(
        Rect.fromPoints(trailPoints[0], trailPoints[2]),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(trailPath, trailPaint);

    // Solid trail on top
    canvas.drawPath(
      trailPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: [Color(0xE6FF006E), Color(0xFF00D4FF)],
        ).createShader(Rect.fromPoints(trailPoints[0], trailPoints[2])),
    );

    // Animated dash tip
    final tipPath = Path()
      ..moveTo(w * 0.54, h * 0.72)
      ..lineTo(w * 0.48, h * 0.72);
    canvas.drawPath(
      tipPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF00D4FF)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TerritoryPainter old) => old.dashOffset != dashOffset;
}
