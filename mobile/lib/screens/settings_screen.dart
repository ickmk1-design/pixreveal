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
import '../utils/locale_helper.dart';
import '../constants/calibrate.dart';

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
                assetPath: localeAsset('settings'),
                calibrateMode: kCalibrateMode,
                showBackButton: false,
                onNavigate: (target, id) => _navigate(target, id),
                overlayBuilder: (size) => [
                  // Geri ok — ScreenFrame içinde, PNG'nin empty box'ını örter
                  Positioned(
                    left: 10,
                    top: 30,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        AudioService.play('button_click');
                        context.go('/menu');
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.75),
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  _toggleWidget(size, yCenter: 30.3, value: sfx),
                  _toggleWidget(size, yCenter: 38.4, value: music),
                  _toggleWidget(size, yCenter: 46.6, value: vibration),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleWidget(Size size, {required double yCenter, required bool value}) {
    // Ölçülen değerler: track sol=786/1024=0.7676, genişlik=178/1024=0.1738, yükseklik=75/1536=0.0488
    final double tw = size.width * 0.1738;
    final double th = size.height * 0.0488;
    const double kw = 22.0;
    return Positioned(
      left: size.width * 0.7676,
      top: size.height * yCenter / 100 - th / 2,
      width: tw,
      height: th,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: value ? const Color(0xFF00CC44) : const Color(0xFF44445A),
            boxShadow: value
                ? [BoxShadow(color: const Color(0xFF00CC44).withValues(alpha: 0.5), blurRadius: 6)]
                : [],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: kw,
                height: kw,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
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
        _launch('https://cytbilisim.com/revealzone/privacy');
      case 'terms':
        _launch('https://cytbilisim.com/revealzone/terms');
    }
  }

  Future<void> _restore() async {
    final result = await PurchaseService.instance.restorePurchases();
    if (!mounted) return;
    final tr = isTurkish();
    if (result.restored) {
      _snack(tr
          ? 'Satın almaların geri yüklendi'
          : 'Your purchases have been restored');
    } else if (result.error != null) {
      _snack(tr ? 'Hata: ${result.error}' : 'Error: ${result.error}');
    } else {
      _snack(tr
          ? 'Geri yüklenecek abonelik veya kalıcı satın alma yok'
          : 'No subscriptions or permanent purchases to restore');
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
