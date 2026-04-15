import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/gold_star.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ResultScreen extends StatelessWidget {
  final bool isVictory;
  final int score;
  final int combo;
  final String time;
  final String previewAsset;

  const ResultScreen({
    super.key,
    required this.isVictory,
    this.score = 12450,
    this.combo = 3,
    this.time = '01:23',
    this.previewAsset = 'assets/images/cars_1.jpg',
  });

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 22,
        height: 1.4,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: Stack(
          children: [
            if (isVictory) const Positioned.fill(child: _ConfettiLayer()),
            if (!isVictory)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.red.withOpacity(0.10),
                        Colors.red.withOpacity(0.22),
                      ],
                      stops: const [0.4, 0.72, 1],
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                  child: isVictory ? _VictoryView(data: this) : _GameOverView(data: this),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VictoryView extends StatelessWidget {
  final ResultScreen data;

  const _VictoryView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(L.get('victory').toUpperCase(), textAlign: TextAlign.center, style: data._pixelTitle),
        const SizedBox(height: 18),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoldStar(size: 50),
            SizedBox(width: 6),
            GoldStar(size: 62),
            SizedBox(width: 6),
            GoldStar(size: 50),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x6636D8FF)),
            boxShadow: const [
              BoxShadow(color: Color(0x3336D8FF), blurRadius: 24),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              data.previewAsset,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xAA101725),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            children: [
              _StatRow(label: 'SCORE', value: '${data.score}'),
              _StatRow(label: 'COMBO BONUS', value: 'x${data.combo}', accent: const Color(0xFF72F3FF)),
              _StatRow(label: 'TIME', value: data.time),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PremiumButton(
          text: L.get('next_level').toUpperCase(),
          onTap: () => context.go('/levels'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: L.get('retry').toUpperCase(),
                outlined: true,
                onTap: () => context.go('/game'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumButton(
                text: L.get('menu').toUpperCase(),
                outlined: true,
                onTap: () => context.go('/menu'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GameOverView extends StatelessWidget {
  final ResultScreen data;

  const _GameOverView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/spider.png',
          width: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(L.get('game_over').toUpperCase(), textAlign: TextAlign.center, style: data._pixelTitle),
        const SizedBox(height: 12),
        Text(
          L.get('continue_question'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        PremiumButton(
          text: L.get('use_1_token').toUpperCase(),
          gold: true,
          icon: Icons.monetization_on_rounded,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        PremiumButton(
          text: L.get('watch_ad').toUpperCase(),
          blue: true,
          icon: Icons.play_arrow_rounded,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.go('/menu'),
          child: const Text(
            'QUIT',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatRow({
    required this.label,
    required this.value,
    this.accent = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiLayer extends StatelessWidget {
  const _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ConfettiPainter());
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final colors = [
      const Color(0xFFFFD36A),
      const Color(0xFFFF6DB0),
      const Color(0xFF65EDFF),
      const Color(0xFF89FF76),
    ];
    for (int i = 0; i < 85; i++) {
      final p = Paint()..color = colors[i % colors.length];
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.55;
      final w = rnd.nextDouble() * 8 + 4;
      final h = rnd.nextDouble() * 14 + 6;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(2)),
        p,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
