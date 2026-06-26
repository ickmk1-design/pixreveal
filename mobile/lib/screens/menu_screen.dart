import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/token_service.dart';

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
            assetPath: 'assets/images/menu.png',
            onNavigate: (target, id) => _navigate(context, target),
            overlayBuilder: (size) => [
              // Coin overlay — hotspot 'coins': x=64, y=0, w=36, h=6
              // PNG'deki coin alanının tam üstüne coin sayısını yazar.
              Positioned(
                left: size.width * 0.64,
                top: size.height * 0.005,
                width: size.width * 0.36,
                height: size.height * 0.06,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$balance',
                      style: TextStyle(
                        fontSize: size.height * 0.022,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        shadows: const [
                          Shadow(color: Color(0xFFFFAA00), blurRadius: 8),
                        ],
                      ),
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
