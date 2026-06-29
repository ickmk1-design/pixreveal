import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/lives_service.dart';
import '../services/ad_service.dart';
import '../services/token_service.dart';
import '../utils/locale_helper.dart';

class GameoverScreen extends StatefulWidget {
  final int levelId;
  const GameoverScreen({super.key, this.levelId = 1});

  @override
  State<GameoverScreen> createState() => _GameoverScreenState();
}

class _GameoverScreenState extends State<GameoverScreen> {
  bool _reviveUsed = false;

  @override
  void initState() {
    super.initState();
    LivesService.instance.deductLife();
    AdService.instance.onPlayerDied(); // her 3 ölümde otomatik interstitial
  }

  // Token miktarı — PNG'deki static '1' silindi, buradan dinamik gösterilir.
  static const int continueCost = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'gameover',
          assetPath: localeAsset('gameover'),
          showBackButton: true,
          onBack: () {
            AudioService.play('button_click');
            context.go('/menu');
          },
          onNavigate: (target, id) => _navigate(context, target, id),
          overlayBuilder: (size) => [
            Positioned(
              left: size.width * 0.14,
              top: size.height * 0.54,
              width: size.width * 0.72,
              height: size.height * 0.09,
              child: IgnorePointer(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/ui/coin_icon.png',
                        width: size.height * 0.040,
                        height: size.height * 0.040,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        isTurkish() ? '$continueCost TOKEN KULLAN' : 'USE $continueCost TOKENS',
                        style: TextStyle(
                          fontSize: size.height * 0.024,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 2)),
                          ],
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
    );
  }

  void _navigate(BuildContext context, String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'retry':
        if (id == 'watch-ad') {
          _handleRevive();
        } else if (id == 'use-token') {
          if (TokenService.instance.balance >= continueCost) {
            AudioService.play('token_insert');
            TokenService.instance.spendToken(continueCost); // fire-and-forget
            LivesService.instance.addLife();                // fire-and-forget
            context.go('/countdown?level=${widget.levelId}');
          } else {
            _snack('Yeterli token yok ($continueCost gerekli). Reklam izle veya token satın al.');
          }
        } else {
          context.go('/countdown?level=${widget.levelId}');
        }
      case 'menu':
        context.go('/menu');
      default:
        break;
    }
  }

  static const int _dailyAdLimit = 5;
  static const String _kAdCount = 'ad_continues_today';
  static const String _kAdDate  = 'ad_continue_date';

  Future<bool> _checkDailyAdLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString(_kAdDate) ?? '';

    // Gün değişmişse sayacı sıfırla
    if (savedDate != dateStr) {
      await prefs.setInt(_kAdCount, 0);
      await prefs.setString(_kAdDate, dateStr);
    }

    final count = prefs.getInt(_kAdCount) ?? 0;
    if (count >= _dailyAdLimit) return false; // limit doldu

    await prefs.setInt(_kAdCount, count + 1);
    return true;
  }

  void _handleRevive() {
    // VIP: ücretsiz devam
    if (LivesService.instance.isVip) {
      LivesService.instance.addLife();
      context.go('/countdown?level=${widget.levelId}');
      return;
    }

    if (_reviveUsed) {
      _snack('Bu level için revive hakkını kullandın');
      return;
    }

    if (!AdService.instance.isRewardedReady) {
      _snack('Reklam henüz hazırlanıyor, lütfen birkaç saniye bekle.');
      return;
    }

    _checkDailyAdLimit().then((allowed) {
      if (!allowed) {
        _snack('Günlük limit doldu (5/5). Yarın tekrar dene.');
        return;
      }
      AdService.instance.showRewarded(
        onEarned: () {
          _reviveUsed = true;
          LivesService.instance.addLife();
          if (mounted) context.go('/countdown?level=${widget.levelId}');
        },
        onNotReady: () {
          if (mounted) _snack('Reklam henüz hazırlanıyor, lütfen birkaç saniye bekle.');
        },
      );
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      duration: const Duration(milliseconds: 2500),
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
