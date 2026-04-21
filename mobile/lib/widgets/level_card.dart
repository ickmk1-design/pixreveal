import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'star_icon.dart';
import 'lock_icon.dart';
import 'play_arrow_icon.dart';

enum LevelState { done, next, locked }

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final LevelState state;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = state == LevelState.done;
    final isNext = state == LevelState.next;
    final isLocked = state == LevelState.locked;

    final borderColor = isNext
        ? const Color(0xFFFF006E)
        : isDone
            ? const Color(0xFF00D4FF).withValues(alpha: 0.7)
            : const Color(0xFF6478B4).withValues(alpha: 0.3);

    final glow = isNext
        ? [
            BoxShadow(color: const Color(0xFFFF006E).withValues(alpha: 0.5), blurRadius: 20),
            BoxShadow(color: const Color(0xFFFF006E).withValues(alpha: 0.15), blurRadius: 20, spreadRadius: -5),
          ]
        : isDone
            ? [
                BoxShadow(color: const Color(0xFF00D4FF).withValues(alpha: 0.3), blurRadius: 16),
              ]
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: -4),
              ];

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AspectRatio(
            aspectRatio: 1 / 1.05,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2),
                gradient: isLocked
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xCC141428), Color(0xE60A0A19)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xCC141E3C), Color(0xE60A0F28)],
                      ),
                boxShadow: glow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isNext ? 8 : 0),
                  Text(
                    'LEVEL $levelNumber',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isLocked
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white,
                      shadows: isLocked
                          ? null
                          : [const Shadow(color: Colors.black, blurRadius: 3)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLocked) const LockIcon(size: 28),
                  if (isNext) const PlayArrowIcon(size: 26),
                  if (isDone)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 1; i <= 3; i++) ...[
                          StarIcon(filled: i <= stars, size: 18),
                          if (i < 3) const SizedBox(width: 3),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
          // SIRA SENDE badge
          if (isNext)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4D9F), Color(0xFFFF006E)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF006E).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'SIRA SENDE',
                    style: GoogleFonts.orbitron(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
