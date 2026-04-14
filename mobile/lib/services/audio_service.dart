import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Audio service with silent fallback if assets are missing.
class AudioService {
  static bool _enabled = true;
  static bool _initialized = false;

  static void setEnabled(bool enabled) { _enabled = enabled; }
  static bool get isEnabled => _enabled;

  /// Sound effect paths (optional — silently skipped if missing)
  static const _sounds = {
    'trail': 'trail_draw.wav',
    'capture': 'capture.wav',
    'die': 'die.wav',
    'level_complete': 'level_complete.wav',
    'token': 'token_insert.wav',
    'click': 'button_click.wav',
  };

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Preload all sound files (skip if missing)
      for (final file in _sounds.values) {
        try {
          await FlameAudio.audioCache.load(file);
        } catch (_) {
          // Silently ignore missing files
        }
      }
    } catch (e) {
      debugPrint('Audio init skipped: $e');
    }
  }

  static Future<void> play(String key) async {
    if (!_enabled) return;
    final file = _sounds[key];
    if (file == null) return;
    try {
      await FlameAudio.play(file, volume: 0.6);
    } catch (_) {
      // Silently ignore
    }
  }
}
