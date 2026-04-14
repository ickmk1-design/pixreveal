import 'package:flutter/material.dart';

import 'space_background.dart';

class TokenInsertOverlay extends StatefulWidget {
  final VoidCallback? onCompleted;

  const TokenInsertOverlay({super.key, this.onCompleted});

  @override
  State<TokenInsertOverlay> createState() => _TokenInsertOverlayState();
}

class _TokenInsertOverlayState extends State<TokenInsertOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _coinCtrl;
  late final AnimationController _heartCtrl;

  @override
  void initState() {
    super.initState();

    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) widget.onCompleted?.call();
    });
  }

  @override
  void dispose() {
    _coinCtrl.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coinY = Tween<double>(begin: -160, end: 58).animate(
      CurvedAnimation(parent: _coinCtrl, curve: Curves.easeIn),
    );

    return Material(
      color: Colors.transparent,
      child: SpaceBackground(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x33FFD36A), blurRadius: 70, spreadRadius: 10),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 320,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 34,
                          child: AnimatedBuilder(
                            animation: coinY,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, coinY.value),
                                child: child,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Color(0x55FFD36A), blurRadius: 28),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 78,
                                  height: 78,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFEE9C),
                                        Color(0xFFFFC53A),
                                        Color(0xFFC67D09),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.monetization_on,
                                    size: 38,
                                    color: Color(0xFF6A4000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 98,
                          child: Container(
                            width: 220,
                            height: 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF7C7F87), Color(0xFF353B46), Color(0xFF9095A0)],
                              ),
                              border: Border.all(color: Colors.white24, width: 1.2),
                              boxShadow: const [
                                BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12)),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF090909), Color(0xFF2A2A2A)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'INSERT TOKEN',
                    style: TextStyle(
                      color: Color(0xFFFFD36A),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      shadows: [Shadow(color: Color(0xAAFFD36A), blurRadius: 16)],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _heartCtrl,
                    builder: (context, _) {
                      final progress = _heartCtrl.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final threshold = (index + 1) / 3;
                          final active = progress >= threshold - 0.16;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.favorite,
                              size: 38,
                              color: active ? const Color(0xFFFF425D) : const Color(0x44FFFFFF),
                              shadows: active
                                  ? const [
                                      Shadow(color: Color(0xAAFF425D), blurRadius: 16),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}