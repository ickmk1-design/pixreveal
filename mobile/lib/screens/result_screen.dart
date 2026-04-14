import '../utils/localization.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../widgets/coin_badge.dart';
import '../widgets/gold_star.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class ResultScreen extends StatefulWidget {
  final bool isVictory;
  final int score;
  final int combo;
  final String time;
  final String imageAsset;
  final int levelId;
  final String imageFile;
  final String categoryName;
  final List<String> categoryImages;

  const ResultScreen({
    super.key,
    required this.isVictory,
    this.score = 12450,
    this.combo = 3,
    this.time = '01:23',
    this.imageAsset = 'assets/images/space_1.jpg',
    this.levelId = 1,
    this.imageFile = 'cars_1.jpg',
    this.categoryName = 'SUPER CARS',
    this.categoryImages = const ['cars_1.jpg', 'cars_2.jpg', 'cars_3.jpg'],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  RewardedAd? _rewardedAd;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();

    if (!widget.isVictory) {
      RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) => _rewardedAd = ad,
          onAdFailedToLoad: (_) {},
        ),
      );
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: Stack(
          children: [
            if (widget.isVictory) const Positioned.fill(child: _ConfettiLayer()),
            if (!widget.isVictory)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.red.withOpacity(0.18),
                        Colors.red.withOpacity(0.28),
                      ],
                      stops: const [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: widget.isVictory ? _victory(context) : _gameOver(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _victory(BuildContext context) {
    return Column(
      children: [
        Text(
          L.get('victory'),
          style: TextStyle(
            color: Color(0xFFFFD36A),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            shadows: [
              Shadow(color: Color(0xAAFFD36A), blurRadius: 24),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoldStar(size: 54),
            SizedBox(width: 6),
            GoldStar(size: 66),
            SizedBox(width: 6),
            GoldStar(size: 54),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x6687F5FF), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x5531D8FF), blurRadius: 24),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              widget.imageAsset,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 20),
        _statCard(
          children: [
            _statLine('SCORE', '${widget.score}'),
            _statLine(L.get('combo_bonus'), 'x${widget.combo}', accent: Color(0xFF66F0FF)),
            _statLine('TIME', widget.time),
          ],
        ),
        SizedBox(height: 22),
        PremiumButton(
          text: L.get('next_level').toUpperCase(),
          onPressed: () {
            final nextLevel = widget.levelId + 1;
            final imgs = widget.categoryImages;
            final img = imgs[(nextLevel - 1) % imgs.length];
            context.go('/game/$nextLevel?img=$img');
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: L.get('retry').toUpperCase(),
                outlined: true,
                onPressed: () => context.go('/game/${widget.levelId}?img=${widget.imageFile}'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PremiumButton(
                text: L.get('menu').toUpperCase(),
                outlined: true,
                onPressed: () => context.go('/menu'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _gameOver(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/spider.png',
          width: 260,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12),
        Text(
          L.get('game_over'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFF3E47),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: Color(0xAAFF3E47), blurRadius: 26),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          L.get('continue_question'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20),
        PremiumButton(
          text: '${L.get('use_token').toUpperCase()} 1',
          icon: Icons.monetization_on,
          gradient: const [Color(0xFFFFE18A), Color(0xFFFFB22E)],
          onPressed: () {},
        ),
        SizedBox(height: 12),
        PremiumButton(
          text: L.get('watch_ad').toUpperCase(),
          icon: Icons.play_arrow_rounded,
          gradient: const [Color(0xFF2D8DFF), Color(0xFF39D8FF)],
          onPressed: () {
            _rewardedAd?.show(onUserEarnedReward: (ad, reward) {});
          },
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () => context.go('/menu'),
          child: Text(
            L.get('quit'),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0x55141820),
        border: Border.all(color: const Color(0x33A8D8FF)),
      ),
      child: Column(children: children),
    );
  }

  Widget _statLine(String left, String right, {Color accent = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$left:',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            right,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
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
    final rnd = math.Random(12);
    final colors = [
      const Color(0xFFFFD36A),
      const Color(0xFFFF6AA2),
      const Color(0xFF58E8FF),
      const Color(0xFF91FF6A),
    ];

    for (int i = 0; i < 90; i++) {
      final p = Paint()..color = colors[i % colors.length];
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.6;
      final w = rnd.nextDouble() * 8 + 4;
      final h = rnd.nextDouble() * 14 + 5;
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