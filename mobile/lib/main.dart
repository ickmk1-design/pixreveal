import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';
import 'services/iap_service.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // RevenueCat — early anonymous init so offerings are ready
  await Purchases.configure(
    PurchasesConfiguration(IAPService.apiKey),
  );

  // AdMob
  final adService = AdService();
  await adService.init();
  adService.loadInterstitial();
  adService.loadRewarded();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(ProviderScope(
    overrides: [
      adServiceProvider.overrideWithValue(adService),
    ],
    child: const PixRevealApp(),
  ));
}

final adServiceProvider = Provider<AdService>((ref) => AdService());

class PixRevealApp extends StatelessWidget {
  const PixRevealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PixReveal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkArcade,
      routerConfig: router,
    );
  }
}
