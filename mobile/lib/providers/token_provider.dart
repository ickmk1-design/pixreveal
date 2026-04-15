import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class TokenState {
  final int tokens;
  final int lives;
  final int adsWatchedToday;
  final DateTime? lastDailyLogin;

  const TokenState({
    this.tokens = 1250,
    this.lives = 3,
    this.adsWatchedToday = 0,
    this.lastDailyLogin,
  });

  bool get hasDailyLoginAvailable {
    if (lastDailyLogin == null) return true;
    final now = DateTime.now();
    final last = lastDailyLogin!;
    return now.day != last.day || now.month != last.month || now.year != last.year;
  }

  bool get canWatchAd => adsWatchedToday < GameConfig.maxAdRewardsPerDay;

  TokenState copyWith({
    int? tokens,
    int? lives,
    int? adsWatchedToday,
    DateTime? lastDailyLogin,
  }) {
    return TokenState(
      tokens: tokens ?? this.tokens,
      lives: lives ?? this.lives,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      lastDailyLogin: lastDailyLogin ?? this.lastDailyLogin,
    );
  }

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'lives': lives,
        'adsWatchedToday': adsWatchedToday,
        'lastDailyLogin': lastDailyLogin?.toIso8601String(),
      };

  factory TokenState.fromJson(Map<String, dynamic> json) => TokenState(
        tokens: (json['tokens'] as int?) ?? 1250,
        lives: (json['lives'] as int?) ?? 3,
        adsWatchedToday: (json['adsWatchedToday'] as int?) ?? 0,
        lastDailyLogin: json['lastDailyLogin'] != null
            ? DateTime.tryParse(json['lastDailyLogin'] as String)
            : null,
      );
}

final tokenProvider =
    StateNotifierProvider<TokenNotifier, TokenState>((ref) => TokenNotifier());

class TokenNotifier extends StateNotifier<TokenState> {
  TokenNotifier() : super(const TokenState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('token_data');
    if (data != null) {
      try {
        final s = TokenState.fromJson(jsonDecode(data) as Map<String, dynamic>);
        // Reset daily ad count if new day
        if (s.lastDailyLogin != null) {
          final now = DateTime.now();
          final last = s.lastDailyLogin!;
          if (now.day != last.day ||
              now.month != last.month ||
              now.year != last.year) {
            state = s.copyWith(adsWatchedToday: 0);
            return;
          }
        }
        state = s;
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_data', jsonEncode(state.toJson()));
  }

  bool useToken() {
    if (state.tokens <= 0) return false;
    state = state.copyWith(
      tokens: state.tokens - 1,
      lives: GameConfig.livesPerToken,
    );
    _save();
    return true;
  }

  void loseLife() {
    state = state.copyWith(lives: state.lives - 1);
    _save();
  }

  bool get isAlive => state.lives > 0;

  void addTokens(int amount) {
    state = state.copyWith(tokens: state.tokens + amount);
    _save();
  }

  bool claimDailyLogin() {
    if (!state.hasDailyLoginAvailable) return false;
    state = state.copyWith(
      tokens: state.tokens + GameConfig.dailyLoginTokens,
      lastDailyLogin: DateTime.now(),
    );
    _save();
    return true;
  }

  bool claimAdReward() {
    if (!state.canWatchAd) return false;
    state = state.copyWith(
      tokens: state.tokens + GameConfig.adRewardTokens,
      adsWatchedToday: state.adsWatchedToday + 1,
    );
    _save();
    return true;
  }

  void awardThreeStarBonus() {
    state = state.copyWith(
      tokens: state.tokens + GameConfig.threeStarBonusTokens,
    );
    _save();
  }
}
