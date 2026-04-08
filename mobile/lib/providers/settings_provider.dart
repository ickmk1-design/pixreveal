import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String language;

  const SettingsState({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'en',
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    String? language,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      soundEnabled: prefs.getBool('sound') ?? true,
      musicEnabled: prefs.getBool('music') ?? true,
      vibrationEnabled: prefs.getBool('vibration') ?? true,
      language: prefs.getString('language') ?? 'en',
    );
  }

  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', state.soundEnabled);
  }

  Future<void> toggleMusic() async {
    state = state.copyWith(musicEnabled: !state.musicEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music', state.musicEnabled);
  }

  Future<void> toggleVibration() async {
    state = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration', state.vibrationEnabled);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}
