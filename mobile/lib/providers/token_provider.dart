import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_model.dart';
import '../utils/constants.dart';

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenModel>((ref) {
  return TokenNotifier();
});

class TokenNotifier extends StateNotifier<TokenModel> {
  TokenNotifier() : super(const TokenModel()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('token_data');
    if (data != null) {
      state = TokenModel.fromJson(jsonDecode(data));
      // Reset daily ad count if new day
      if (state.lastDailyLogin != null) {
        final now = DateTime.now();
        final last = state.lastDailyLogin!;
        if (now.day != last.day ||
            now.month != last.month ||
            now.year != last.year) {
          state = state.copyWith(adsWatchedToday: 0);
        }
      }
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
