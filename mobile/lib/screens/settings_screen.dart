import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/premium_button.dart';
import '../widgets/space_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sfx = true;
  bool music = true;
  bool vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _circleButton(Icons.arrow_back_ios_new, () => context.go('/menu')),
                    Expanded(
                      child: Center(
                        child: Text(
                          L.get('settings'),
                          style: TextStyle(
                            color: Color(0xFF98F4FF),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [Shadow(color: Color(0xAA11DCFF), blurRadius: 18)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    _section(
                      L.get('sound'),
                      child: Column(
                        children: [
                          _switchRow(L.get('sound_effects'), sfx, (v) => setState(() => sfx = v)),
                          _divider(),
                          _switchRow(L.get('music'), music, (v) => setState(() => music = v)),
                          _divider(),
                          _switchRow(L.get('vibration'), vibration, (v) => setState(() => vibration = v)),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    _section(
                      L.get('account'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L.get('provider_guest'),
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          SizedBox(height: 14),
                          PremiumButton(
                            text: L.get('link_account'),
                            height: 54,
                            gradient: const [Color(0xFF1A8AFF), Color(0xFF33D7FF)],
                            onPressed: () => _showLinkAccountSheet(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    _section(
                      L.get('purchases'),
                      child: PremiumButton(
                        text: L.get('restore_purchases'),
                        height: 54,
                        gradient: const [Color(0xFFFFE18A), Color(0xFFFFB22E)],
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(height: 14),
                    _section(
                      L.get('legal'),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/privacy'),
                            child: _arrowRow(L.get('privacy_policy')),
                          ),
                          _divider(),
                          GestureDetector(
                            onTap: () => context.go('/terms'),
                            child: _arrowRow(L.get('terms_of_service')),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    GestureDetector(
                      onTap: () async {
                        await L.setLang(L.isTr ? 'en' : 'tr');
                        if (mounted) setState(() {});
                      },
                      child: _section(
                        L.get('language'),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF1A2230),
                                border: Border.all(color: const Color(0x33A8D8FF)),
                              ),
                              child: Text(L.isTr ? '🇹🇷' : '🇬🇧', style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                L.isTr ? 'Türkçe' : 'English',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.swap_horiz_rounded, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'v1.0',
                        style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w700),
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

  Widget _section(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0x22161A23),
        border: Border.all(color: const Color(0x3363CCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9AEFFF),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _switchRow(String text, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _premiumSwitch(value, onChanged),
      ],
    );
  }

  Widget _premiumSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: value
                ? [const Color(0xFF4BFF8A), const Color(0xFF20C85F)]
                : [const Color(0xFF505A67), const Color(0xFF2D3440)],
          ),
          boxShadow: value
              ? const [
                  BoxShadow(color: Color(0x664BFF8A), blurRadius: 14),
                ]
              : null,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFE7EAF0)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _arrowRow(String text) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.white70),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Color(0x22FFFFFF), height: 1),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x22161A23),
          border: Border.all(color: const Color(0x44A8D8FF)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showLinkAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              L.isTr ? 'Hesabını Bağla' : 'Link Your Account',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L.isTr ? 'İlerlemeni kaydetmek için bir hesap bağla' : 'Link an account to save your progress',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _linkButton(
              L.isTr ? 'Google ile Bağla' : 'Link with Google',
              Icons.g_mobiledata,
              const Color(0xFFEA4335),
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: const Color(0xFF1A1A2E),
                  content: Text(
                    L.isTr ? 'Google bağlantısı yakında!' : 'Google linking coming soon!',
                    style: const TextStyle(color: Color(0xFF00DDFF)),
                  ),
                ));
              },
            ),
            const SizedBox(height: 12),
            _linkButton(
              L.isTr ? 'E-posta ile Bağla' : 'Link with Email',
              Icons.email_outlined,
              const Color(0xFF4285F4),
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: const Color(0xFF1A1A2E),
                  content: Text(
                    L.isTr ? 'E-posta bağlantısı yakında!' : 'Email linking coming soon!',
                    style: const TextStyle(color: Color(0xFF00DDFF)),
                  ),
                ));
              },
            ),
            const SizedBox(height: 12),
            if (Theme.of(context).platform == TargetPlatform.iOS)
              _linkButton(
                L.isTr ? 'Apple ile Bağla' : 'Link with Apple',
                Icons.apple,
                Colors.white,
                () {
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _linkButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF141428),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}