import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool sfx;
  final bool music;
  final bool vibration;

  const SettingsState({
    this.sfx = true,
    this.music = true,
    this.vibration = true,
  });

  SettingsState copyWith({bool? sfx, bool? music, bool? vibration}) =>
      SettingsState(
        sfx: sfx ?? this.sfx,
        music: music ?? this.music,
        vibration: vibration ?? this.vibration,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleSfx() => state = state.copyWith(sfx: !state.sfx);
  void toggleMusic() => state = state.copyWith(music: !state.music);
  void toggleVibration() => state = state.copyWith(vibration: !state.vibration);
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
