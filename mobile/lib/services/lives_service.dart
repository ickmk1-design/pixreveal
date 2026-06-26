import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entitlement_service.dart';
import '../constants/economy_config.dart';

class LivesService {
  LivesService._();
  static final instance = LivesService._();

  static const _kLives = 'persistent_lives';
  static const _kTimestamp = 'regen_timestamp';

  int _lives = EconomyConfig.maxLives;
  int _regenTimestamp = 0;

  final ValueNotifier<int> notifier = ValueNotifier(EconomyConfig.maxLives);

  int get lives => _lives;
  bool get isVip => EntitlementService.instance.isPremium;

  /// VIP: sınırsız can (bypass sistem). Non-VIP: 0 ise false.
  bool get hasLives => isVip || _lives > 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _lives = prefs.getInt(_kLives) ?? EconomyConfig.startLives;
    _regenTimestamp =
        prefs.getInt(_kTimestamp) ?? DateTime.now().millisecondsSinceEpoch;

    if (_lives < EconomyConfig.maxLives) {
      _applyRegen();
      await _persist(prefs);
    }
    notifier.value = _lives;
  }

  void _applyRegen() {
    const regenMs = EconomyConfig.lifeRegenMinutes * 60 * 1000;
    final elapsed = DateTime.now().millisecondsSinceEpoch - _regenTimestamp;
    final gained = (elapsed ~/ regenMs).clamp(0, EconomyConfig.maxLives - _lives);
    if (gained > 0) {
      _lives = (_lives + gained).clamp(0, EconomyConfig.maxLives);
      _regenTimestamp += gained * regenMs;
    }
  }

  /// Level başarısız olduğunda çağır. VIP'te pas geçer.
  Future<void> deductLife() async {
    if (isVip || _lives <= 0) return;
    // İlk kez tam doludan düşüyorsa regen saatini sıfırla
    if (_lives == EconomyConfig.maxLives) {
      _regenTimestamp = DateTime.now().millisecondsSinceEpoch;
    }
    _lives--;
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  /// Rewarded reklam ödülü veya başka bir kaynak +1 can ekler.
  Future<void> addLife() async {
    if (_lives >= EconomyConfig.maxLives) return;
    _lives++;
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  /// Bir sonraki cana kalan saniye. Can doluysa 0 döner.
  int nextRegenSeconds() {
    if (_lives >= EconomyConfig.maxLives) return 0;
    const regenMs = EconomyConfig.lifeRegenMinutes * 60 * 1000;
    final elapsed = DateTime.now().millisecondsSinceEpoch - _regenTimestamp;
    final remaining = regenMs - (elapsed % regenMs);
    return (remaining / 1000).ceil().clamp(1, EconomyConfig.lifeRegenMinutes * 60);
  }

  /// Geri sayımı "MM:SS" formatında string olarak döner.
  String nextRegenFormatted() {
    final secs = nextRegenSeconds();
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setInt(_kLives, _lives);
    await prefs.setInt(_kTimestamp, _regenTimestamp);
    notifier.value = _lives;
  }
}
