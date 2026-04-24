import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../services/purchase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _settings.sfx,
          builder: (_, sfx, __) => ValueListenableBuilder(
            valueListenable: _settings.music,
            builder: (_, music, __) => ValueListenableBuilder(
              valueListenable: _settings.vibration,
              builder: (_, vibration, __) => MockupScreen(
                screen: 'settings',
                assetPath: 'assets/images/settings.png',
                showBackButton: true,
                onBack: () {
                  AudioService.play('button_click');
                  context.go('/menu');
                },
                onNavigate: (target, id) => _navigate(target, id),
                overlayBuilder: (size) => [
                  if (!sfx) _toggleOffOverlay(size, yPercent: 24.4),
                  if (!music) _toggleOffOverlay(size, yPercent: 30.3),
                  if (!vibration) _toggleOffOverlay(size, yPercent: 35.8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleOffOverlay(Size size, {required double yPercent}) {
    return Positioned(
      left: size.width * 0.78,
      top: size.height * (yPercent - 2.2) / 100,
      width: size.width * 0.16,
      height: size.height * 0.042,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.black.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }

  void _navigate(String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'menu':
        context.go('/menu');
      case 'toggle-sfx':
        _settings.setSfx(!_settings.sfx.value);
      case 'toggle-music':
        _settings.setMusic(!_settings.music.value);
      case 'toggle-vibration':
        _toggleVibration();
      case 'none':
        _handleNone(id);
    }
  }

  void _toggleVibration() {
    final newVal = !_settings.vibration.value;
    _settings.setVibration(newVal);
    if (newVal) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _handleNone(String id) {
    switch (id) {
      case 'link':
        _showLinkAccountSheet();
      case 'restore':
        _restore();
      case 'privacy':
        _launch('https://pixreveal.app/privacy');
      case 'terms':
        _launch('https://pixreveal.app/terms');
    }
  }

  void _showLinkAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
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
              const Text('Hesap Bağla',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Verilerini kaydet ve cihazlar arası senkronize et',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _sheetButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google ile devam et',
                onTap: () { Navigator.pop(context); _signInGoogle(); },
              ),
              if (!kIsWeb && Platform.isIOS) ...[
                const SizedBox(height: 12),
                _sheetButton(
                  icon: Icons.apple,
                  label: 'Apple ile devam et',
                  onTap: () { Navigator.pop(context); _signInApple(); },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
          color: const Color(0xFF00D4FF).withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _signInGoogle() async {
    final result = await AuthService.instance.signInWithGoogle();
    if (!mounted) return;
    if (result.user != null) {
      _snack('Hesap bağlandı: ${result.user!.email ?? result.user!.uid}');
    } else if (result.error != null) {
      _snack('Giriş yapılamadı: ${result.error}');
    }
  }

  Future<void> _signInApple() async {
    final result = await AuthService.instance.signInWithApple();
    if (!mounted) return;
    if (result.user != null) {
      _snack('Hesap bağlandı: ${result.user!.email ?? result.user!.uid}');
    } else if (result.error != null) {
      _snack('Giriş yapılamadı: ${result.error}');
    }
  }

  Future<void> _restore() async {
    final result = await PurchaseService.instance.restorePurchases();
    if (!mounted) return;
    if (result.hasPremium) {
      _snack('Aboneliğin geri yüklendi!');
    } else if (result.error != null) {
      _snack('Hata: ${result.error}');
    } else {
      _snack('Aktif abonelik bulunamadı');
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) _snack('Sayfa açılamadı: $url');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      duration: const Duration(milliseconds: 2000),
      backgroundColor: const Color(0xFF1A0F2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00D4FF), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60),
    ));
  }
}
