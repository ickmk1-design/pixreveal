import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service.dart';

class SettingsService {
  SettingsService._();
  static final instance = SettingsService._();

  static const _keySfx = 'settings_sfx';
  static const _keyMusic = 'settings_music';
  static const _keyVibration = 'settings_vibration';

  final sfx = ValueNotifier<bool>(true);
  final music = ValueNotifier<bool>(true);
  final vibration = ValueNotifier<bool>(true);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    sfx.value = prefs.getBool(_keySfx) ?? true;
    music.value = prefs.getBool(_keyMusic) ?? true;
    vibration.value = prefs.getBool(_keyVibration) ?? true;
    AudioService.instance.setSfxEnabled(sfx.value);
    AudioService.instance.setMusicEnabled(music.value);
  }

  Future<void> setSfx(bool v) async {
    sfx.value = v;
    AudioService.instance.setSfxEnabled(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySfx, v);
  }

  Future<void> setMusic(bool v) async {
    music.value = v;
    AudioService.instance.setMusicEnabled(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusic, v);
  }

  Future<void> setVibration(bool v) async {
    vibration.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, v);
  }
}
