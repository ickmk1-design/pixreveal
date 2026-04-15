import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/localization.dart';
import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsState {
  final bool sfx;
  final bool music;
  final bool vibration;
  final String language;

  const SettingsState({
    this.sfx = true,
    this.music = true,
    this.vibration = true,
    this.language = 'TR',
  });

  SettingsState copyWith({
    bool? sfx,
    bool? music,
    bool? vibration,
    String? language,
  }) {
    return SettingsState(
      sfx: sfx ?? this.sfx,
      music: music ?? this.music,
      vibration: vibration ?? this.vibration,
      language: language ?? this.language,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void toggleSfx() => state = state.copyWith(sfx: !state.sfx);
  void toggleMusic() => state = state.copyWith(music: !state.music);
  void toggleVibration() => state = state.copyWith(vibration: !state.vibration);
  void toggleLanguage() =>
      state = state.copyWith(language: state.language == 'TR' ? 'EN' : 'TR');
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  TextStyle get _pixelTitle => const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 18,
        height: 1.35,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x22161A23),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Text(L.get('settings').toUpperCase(), style: _pixelTitle),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _SettingsSection(
                      title: L.get('sound'),
                      child: Column(
                        children: [
                          _ToggleRow(
                            title: L.get('sound_effects'),
                            value: settings.sfx,
                            onTap: () => ref.read(settingsProvider.notifier).toggleSfx(),
                          ),
                          const Divider(color: Color(0x22FFFFFF)),
                          _ToggleRow(
                            title: L.get('music'),
                            value: settings.music,
                            onTap: () => ref.read(settingsProvider.notifier).toggleMusic(),
                          ),
                          const Divider(color: Color(0x22FFFFFF)),
                          _ToggleRow(
                            title: L.get('vibration'),
                            value: settings.vibration,
                            onTap: () => ref.read(settingsProvider.notifier).toggleVibration(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: L.get('account'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L.get('guest_account'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PremiumButton(
                            text: L.get('link_account').toUpperCase(),
                            blue: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: L.get('purchases'),
                      child: PremiumButton(
                        text: L.get('restore_purchases').toUpperCase(),
                        gold: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: L.get('legal'),
                      child: Column(
                        children: [
                          _ArrowRow(title: L.get('privacy_policy'), onTap: () => context.go('/privacy')),
                          const Divider(color: Color(0x22FFFFFF)),
                          _ArrowRow(title: L.get('terms_of_service'), onTap: () => context.go('/terms')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: L.get('language'),
                      child: _ArrowRow(
                        title: settings.language,
                        leading: const Text('🇹🇷', style: TextStyle(fontSize: 22)),
                        onTap: () => ref.read(settingsProvider.notifier).toggleLanguage(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'v1.0',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xAA101725),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFA7F5FF),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onTap;

  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 62,
            height: 34,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: value
                    ? [const Color(0xFF52FF99), const Color(0xFF19C868)]
                    : [const Color(0xFF4B5567), const Color(0xFF293040)],
              ),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  final String title;
  final Widget? leading;
  final VoidCallback onTap;

  const _ArrowRow({
    required this.title,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}
