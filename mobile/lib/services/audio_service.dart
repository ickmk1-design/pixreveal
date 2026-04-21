class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  static void play(String name) {}
  Future<void> init() async {}
  void playSfx(String name) {}
  void playBgm(String name) {}
  void stopBgm() {}
  void setMusicEnabled(bool v) {}
  void setSfxEnabled(bool v) {}
}
