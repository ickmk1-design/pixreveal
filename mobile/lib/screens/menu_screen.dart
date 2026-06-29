import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/token_service.dart';
import '../utils/locale_helper.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        // ValueListenableBuilder: token balance değişince sadece coin overlay yeniden çizilir.
        child: ValueListenableBuilder<int>(
          valueListenable: TokenService.instance.notifier,
          builder: (_, balance, __) => MockupScreen(
            screen: 'menu',
            assetPath: localeAsset('menu'),
            onNavigate: (target, id) => _navigate(context, target),
            overlayBuilder: (size) => [
              Positioned(
                top: size.height * 0.04,
                right: size.width * 0.05,
                child: IgnorePointer(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1A0E2E),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFFC107), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55FFB300), blurRadius: 12),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/ui/coin_icon.png',
                          width: size.width * 0.06,
                          height: size.width * 0.06,
                        ),
                        SizedBox(width: size.width * 0.015),
                        Text(
                          '$balance',
                          style: TextStyle(
                            color: const Color(0xFFFFD24F),
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String target) {
    AudioService.play('button_click');
    switch (target) {
      case 'categories':
        context.go('/categories');
      case 'shop':
        context.go('/shop');
      case 'settings':
        context.go('/settings');
      default:
        break;
    }
  }
}
