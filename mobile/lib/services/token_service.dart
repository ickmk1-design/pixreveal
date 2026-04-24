import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  TokenService._();
  static final instance = TokenService._();

  static const _key = 'token_balance';
  int _balance = 0;

  final _notifier = ValueNotifier<int>(0);
  ValueNotifier<int> get notifier => _notifier;
  int get balance => _balance;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_key) ?? 0;
    _notifier.value = _balance;
  }

  Future<void> addTokens(int amount) async {
    _balance += amount;
    _notifier.value = _balance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _balance);
  }

  Future<bool> spendToken(int amount) async {
    if (_balance < amount) return false;
    _balance -= amount;
    _notifier.value = _balance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _balance);
    return true;
  }
}
