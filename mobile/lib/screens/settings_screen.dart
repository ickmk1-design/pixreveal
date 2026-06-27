import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
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
                  // ACCOUNT section (LINK ACCOUNT) — v1.0 hesapsız, PNG üzeri kapatıldı
                  Positioned(
                    left: 0,
                    top: size.height * 0.375,
                    width: size.width,
                    height: size.height * 0.225,
                    child: const IgnorePointer(
                      child: ColoredBox(color: Color(0xFF050510)),
                    ),
                  ),
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
      case 'restore':
        _restore();
      case 'privacy':
        _launch('https://pixreveal.app/privacy');
      case 'terms':
        _launch('https://pixreveal.app/terms');
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
