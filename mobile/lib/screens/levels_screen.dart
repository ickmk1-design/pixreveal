import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/level_card.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  static const _levels = [
    (n: 1, stars: 3, state: LevelState.done),
    (n: 2, stars: 2, state: LevelState.done),
    (n: 3, stars: 3, state: LevelState.done),
    (n: 4, stars: 0, state: LevelState.next),
    (n: 5, stars: 0, state: LevelState.locked),
    (n: 6, stars: 0, state: LevelState.locked),
    (n: 7, stars: 0, state: LevelState.locked),
    (n: 8, stars: 0, state: LevelState.locked),
    (n: 9, stars: 0, state: LevelState.locked),
    (n: 10, stars: 0, state: LevelState.locked),
    (n: 11, stars: 0, state: LevelState.locked),
    (n: 12, stars: 0, state: LevelState.locked),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E27), Color(0xFF1A0F2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              _buildHeader(),
              const SizedBox(height: 24),
              // Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1 / 1.05,
                    children: _levels.map((lv) => LevelCard(
                      levelNumber: lv.n,
                      stars: lv.stars,
                      state: lv.state,
                      onTap: () => _onTap(context, lv.n, lv.state),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
          width: 2,
        ),
        color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Text(
        'SUPER CARS',
        style: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: const Color(0xFF00D4FF),
          shadows: const [
            Shadow(color: Color(0xFF00D4FF), blurRadius: 20),
            Shadow(color: Color(0x80005078), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int n, LevelState state) {
    switch (state) {
      case LevelState.done:
      case LevelState.next:
        context.go('/countdown');
      case LevelState.locked:
        context.go('/paywall');
    }
  }
}
