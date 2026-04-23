import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'shop',
          assetPath: 'assets/images/shop.png',
          showBackButton: true,
          onBack: () {
            AudioService.play('button_click');
            context.go('/menu');
          },
          onNavigate: (target, id) => _navigate(context, target, id),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'menu':
        context.go('/menu');
      case 'paywall':
        context.go('/paywall');
      case 'none':
        _handleShopAction(context, id);
      default:
        break;
    }
  }

  void _handleShopAction(BuildContext context, String id) {
    String msg;
    switch (id) {
      case 'watch-ad':
        msg = 'Reklam entegrasyonu yakında';
      case 'pack-20':
      case 'pack-50':
      case 'pack-120':
        msg = 'Satın alma yakında';
      case 'theme-cars':
      case 'theme-space':
      case 'theme-anim':
      case 'theme-beach':
        msg = 'Tema seçimi yakında';
      default:
        msg = 'Yakında';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: const Color(0xFF1A0F2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60),
      ),
    );
  }
}
