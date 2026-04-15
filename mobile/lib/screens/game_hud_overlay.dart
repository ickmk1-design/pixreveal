import 'dart:math';
import 'package:flutter/material.dart';
import 'pix_theme.dart';

enum PowerUpType { paint, speed, bomb }

class PowerUpInfo {
  final PowerUpType type;
  final int count;
  final int cooldownSeconds;

  const PowerUpInfo({required this.type, this.count = 0, this.cooldownSeconds = 0});
}

class GameHudOverlay extends StatelessWidget {
  final int lives;
  final int maxLives;
  final double percent;
  final int level;
  final String time;
  final int tokens;
  final List<PowerUpInfo> powerUps;
  final VoidCallback? onPause;
  final Function(PowerUpType)? onPowerUpTap;

  const GameHudOverlay({
    super.key,
    this.lives = 3,
    this.maxLives = 3,
    this.percent = 45.2,
    this.level = 3,
    this.time = '01:23',
    this.tokens = 1125,
    this.powerUps = const [],
    this.onPause,
    this.onPowerUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top HUD bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: PixTheme.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              // Hearts
              ...List.generate(maxLives, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.favorite,
                    size: 22,
                    color: i < lives ? PixTheme.redHeart : Colors.grey.shade800,
                    shadows: i < lives
                        ? [Shadow(color: PixTheme.redHeart.withOpacity(0.5), blurRadius: 6)]
                        : null,
                  ),
                );
              }),

              const SizedBox(width: 8),

              // Progress bar
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: PixTheme.neonCyan.withOpacity(0.3), width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Fill
                      FractionallySizedBox(
                        widthFactor: (percent / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00AAFF), Color(0xFF00E5FF)],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(color: PixTheme.neonCyan.withOpacity(0.4), blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                      // Percentage text
                      Center(
                        child: Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Level + Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LV.$level',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 8,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Tokens
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PixTheme.gold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: PixTheme.goldButtonGradient,
                      ),
                      child: const Center(
                        child: Text('\$', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF663300))),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$tokens',
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 9,
                        color: PixTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Power-up sidebar (right side)
        if (powerUps.isNotEmpty)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: powerUps.map((pu) => _buildPowerUpButton(pu)).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPowerUpButton(PowerUpInfo pu) {
    IconData icon;
    Color color;
    switch (pu.type) {
      case PowerUpType.paint:
        icon = Icons.brush;
        color = PixTheme.neonCyan;
      case PowerUpType.speed:
        icon = Icons.bolt;
        color = PixTheme.gold;
      case PowerUpType.bomb:
        icon = Icons.local_fire_department;
        color = PixTheme.emerald;
    }

    return GestureDetector(
      onTap: pu.count > 0 ? () => onPowerUpTap?.call(pu.type) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: PixTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28,
              shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)]),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pu.count > 0 ? PixTheme.emerald : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${pu.count}:${pu.cooldownSeconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 7,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
