import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart' show debugPrint;

enum PowerUpType { freeze, speed, shield }

class PowerUp {
  final PowerUpType type;
  final int col;
  final int row;
  bool collected = false;
  double pulse = 0;

  PowerUp({required this.type, required this.col, required this.row});

  Color get color {
    switch (type) {
      case PowerUpType.freeze: return const Color(0xFF00DDFF);
      case PowerUpType.speed: return const Color(0xFFFFDD00);
      case PowerUpType.shield: return const Color(0xFF00FF88);
    }
  }

  String get label {
    switch (type) {
      case PowerUpType.freeze: return 'F';
      case PowerUpType.speed: return 'S';
      case PowerUpType.shield: return 'D';
    }
  }

  /// Effect duration in seconds (independent timer per power-up)
  double get duration {
    switch (type) {
      case PowerUpType.freeze: return 5.0;
      case PowerUpType.speed: return 8.0;
      case PowerUpType.shield: return 10.0;
    }
  }

  String get displayName {
    switch (type) {
      case PowerUpType.freeze: return 'FREEZE';
      case PowerUpType.speed: return 'SPEED';
      case PowerUpType.shield: return 'SHIELD';
    }
  }

  String get displayNameTr {
    switch (type) {
      case PowerUpType.freeze: return 'DONDURMA';
      case PowerUpType.speed: return 'HIZ';
      case PowerUpType.shield: return 'KORUMA';
    }
  }
}

/// Active power-up effect with independent countdown timer
class ActivePowerUp {
  final PowerUpType type;
  final double total;
  double remaining;
  ActivePowerUp({required this.type, required this.total, required this.remaining});
}

class PowerUpManager {
  final List<PowerUp> active = [];
  final List<ActivePowerUp> effects = [];
  final Random _rng = Random();

  /// Spawn one of each type + randoms, 3-5 total, all in empty cells.
  void spawnInitial(bool Function(int, int) isEmpty, int cols, int rows) {
    active.clear();
    // Guarantee one of each type + 1-2 extra randoms
    final types = <PowerUpType>[
      PowerUpType.freeze,
      PowerUpType.speed,
      PowerUpType.shield,
    ];
    // Add 0-2 random extras
    final extras = _rng.nextInt(3);
    for (int i = 0; i < extras; i++) {
      types.add(PowerUpType.values[_rng.nextInt(PowerUpType.values.length)]);
    }

    // Keep power-ups at least 12 cells from all borders to avoid edge corner bugs
    const margin = 12;
    for (final type in types) {
      int attempts = 0;
      while (attempts < 200) {
        attempts++;
        final c = margin + _rng.nextInt(cols - margin * 2);
        final r = margin + _rng.nextInt(rows - margin * 2);
        if (!isEmpty(c, r)) continue;
        // Avoid overlap with existing power-ups (min 4 cells apart)
        final clash = active.any((p) =>
          (p.col - c).abs() < 4 && (p.row - r).abs() < 4);
        if (clash) continue;
        active.add(PowerUp(type: type, col: c, row: r));
        debugPrint('Spawned $type at grid ($c, $r)');
        break;
      }
    }
  }

  /// Check if any power-ups fall inside newly claimed cells → auto-collect.
  /// Returns list of collected power-ups.
  List<PowerUp> collectInClaimedRegion(List<(int, int)> claimedCells) {
    debugPrint('=== POWER-UP CHECK ===');
    debugPrint('Claimed cells: ${claimedCells.length}, Active power-ups: ${active.length}');
    if (claimedCells.isEmpty) return [];

    final claimedSet = <int>{};
    for (final (c, r) in claimedCells) {
      claimedSet.add(r * 10000 + c);
    }

    final collected = <PowerUp>[];
    for (final pu in active) {
      if (pu.collected) {
        debugPrint('  [SKIP] ${pu.type} already collected');
        continue;
      }
      final key = pu.row * 10000 + pu.col;
      final inClaimed = claimedSet.contains(key);
      debugPrint('  Checking ${pu.type} at grid (${pu.col}, ${pu.row}) key=$key');
      debugPrint('    Inside new claimed area: $inClaimed');

      if (inClaimed) {
        pu.collected = true;
        collected.add(pu);
        effects.add(ActivePowerUp(
          type: pu.type,
          total: pu.duration,
          remaining: pu.duration,
        ));
        debugPrint('    COLLECTED ${pu.type} → effect added (${pu.duration}s)');
      }
    }
    debugPrint('Total collected this capture: ${collected.length}');
    debugPrint('=== END ===');
    return collected;
  }

  void update(double dt) {
    for (final pu in active) { pu.pulse += dt * 4; }
    active.removeWhere((p) => p.collected);

    for (final e in effects) { e.remaining -= dt; }
    effects.removeWhere((e) => e.remaining <= 0);
  }

  bool hasEffect(PowerUpType type) {
    return effects.any((e) => e.type == type);
  }

  /// Consume one shield charge (removes first active shield effect).
  /// Shield is time-limited but one-time protection — expires after 10s OR on death.
  bool consumeShield() {
    final idx = effects.indexWhere((e) => e.type == PowerUpType.shield);
    if (idx >= 0) {
      effects.removeAt(idx);
      return true;
    }
    return false;
  }

  void clear() {
    active.clear();
    effects.clear();
  }
}
