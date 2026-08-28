import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../services/level_progress.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../utils/locale_helper.dart';
import '../constants/calibrate.dart';

class VictoryScreen extends StatelessWidget {
  final int levelId;
  final int score;
  final int combo;
  final int timeSeconds;
  final int tokensEarned;

  const VictoryScreen({
    super.key,
    this.levelId = 1,
    this.score = 0,
    this.combo = 1,
    this.timeSeconds = 0,
    this.tokensEarned = 0,
  });

  String _formatTime(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatScore(int s) {
    final str = s.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageAsset =
        'assets/images/${CurrentCategory.current.assetKey}_$levelId.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: isTurkish() ? 'victory_tr' : 'victory',
          assetPath: localeAsset('victory'),
          calibrateMode: kCalibrateMode,
          onNavigate: (target, id) => _navigate(context, target),
          overlayBuilder: (size) => [
            // Kategori resmi
            Positioned(
              left: size.width * (isTurkish() ? 0.237 : 0.253),
              top: size.height * (isTurkish() ? 0.312 : 0.314),
              width: size.width * (isTurkish() ? 0.476 : 0.470),
              height: size.height * (isTurkish() ? 0.225 : 0.234),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A0F2E)),
                ),
              ),
            ),

            // SCORE
            Positioned(
              left: size.width  * (isTurkish() ? 0.43 : 0.463),
              top:  size.height * (isTurkish() ? 0.573 : 0.582),
              width: size.width * 0.40,
              height: size.height * 0.045,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatScore(score),
                    style: TextStyle(
                      fontSize: size.height * 0.028,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),
            ),

            // COMBO
            Positioned(
              left: size.width  * (isTurkish() ? 0.57 : 0.563),
              top:  size.height * (isTurkish() ? 0.632 : 0.633),
              width: size.width * 0.30,
              height: size.height * 0.035,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'x$combo',
                    style: TextStyle(
                      fontSize: size.height * 0.022,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ),
              ),
            ),

            // TIME
            Positioned(
              left: size.width  * (isTurkish() ? 0.42 : 0.400),
              top:  size.height * (isTurkish() ? 0.685 : 0.684),
              width: size.width * 0.30,
              height: size.height * 0.030,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatTime(timeSeconds),
                    style: TextStyle(
                      fontSize: size.height * 0.020,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ),
              ),
            ),

            // TOKEN REWARD — sağ alt köşe, küçük yazı
            if (tokensEarned > 0)
              Positioned(
                right: size.width * 0.05,
                bottom: size.height * 0.12,
                child: IgnorePointer(
                  child: Text(
                    '+$tokensEarned 🪙',
                    style: TextStyle(
                      fontSize: size.height * 0.018,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFCC00),
                      shadows: const [
                        Shadow(color: Color(0xFFFFCC00), blurRadius: 8),
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

  Future<void> _navigate(BuildContext context, String target) async {
    AudioService.play('button_click');
    switch (target) {
      case 'next-level':
        // Interstitial göster, sonra geç (her 3 levelda bir)
        await AdService.instance.onLevelCompleted();
        if (context.mounted) context.go('/countdown?level=${levelId + 1}');
      case 'retry':
        context.go('/countdown?level=$levelId');
      case 'menu':
        await AdService.instance.onLevelCompleted();
        if (context.mounted) context.go('/menu');
      default:
        break;
    }
  }
}
