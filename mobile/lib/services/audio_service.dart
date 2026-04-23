import 'package:flame_audio/flame_audio.dart';

/// Real audio service using flame_audio.
/// Sound files live at assets/audio/:
///   button_click.wav, capture.wav, die.wav, level_complete.wav,
///   token_insert.wav, trail_draw.wav
class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await FlameAudio.audioCache.loadAll([
        'button_click.wav',
        'capture.wav',
        'die.wav',
        'level_complete.wav',
        'token_insert.wav',
        'trail_draw.wav',
      ]);
      _initialized = true;
    } catch (e) {
      // ignore: avoid_print
      print('Audio init error: $e');
    }
  }

  /// Static shortcut used by game code.
  static void play(String name) => instance.playSfx(name);

  void playSfx(String name) {
    if (!_sfxEnabled) return;
    final file = name.endsWith('.wav') ? name : '$name.wav';
    try {
      FlameAudio.play(file);
    } catch (e) {
      // ignore: avoid_print
      print('Audio play error $file: $e');
    }
  }

  void playBgm(String name) {
    if (!_musicEnabled) return;
    final file = name.endsWith('.mp3') || name.endsWith('.wav') ? name : '$name.wav';
    try {
      FlameAudio.bgm.play(file, volume: 0.5);
    } catch (e) {
      // ignore: avoid_print
      print('BGM error: $e');
    }
  }

  void stopBgm() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void setMusicEnabled(bool v) {
    _musicEnabled = v;
    if (!v) stopBgm();
  }

  void setSfxEnabled(bool v) {
    _sfxEnabled = v;
  }

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
}
