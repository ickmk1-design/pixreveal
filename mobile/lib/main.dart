import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/audio_service.dart';
import 'services/purchase_service.dart';
import 'services/token_service.dart';
import 'services/entitlement_service.dart';
import 'services/settings_service.dart';
import 'services/lives_service.dart';
import 'services/ad_service.dart';
import 'app.dart';

/// Run a Future with a timeout; swallow errors so startup never blocks.
Future<void> _safe(String label, Future<void> Function() fn,
    {Duration timeout = const Duration(seconds: 4)}) async {
  try {
    await fn().timeout(timeout);
  } catch (e) {
    // ignore: avoid_print
    print('[startup] $label failed/slow: $e');
  }
}

Future<void> _initHeavyServices() async {
  // All of the following touch native plugins, network, UMP/ATT dialogs, or
  // preload large asset buffers. They MUST run after the first frame so the
  // splash doesn't block the UI thread -> ANR on cold start.
  await _safe('firebase', () async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });
  await _safe('rc.configure', () => PurchaseService.instance.configure());
  _safe('entitlement.init', () async => EntitlementService.instance.init());
  _safe('entitlement.refresh', () => EntitlementService.instance.refresh(),
      timeout: const Duration(seconds: 6));
  // AdService internally runs UMP form + ATT prompt + MobileAds.initialize —
  // easily 5-10s on cold start. Fire-and-forget after first frame.
  _safe('ads.initialize', () => AdService.instance.initialize(),
      timeout: const Duration(seconds: 15));
  _safe('audio.init', () => AudioService.instance.init(),
      timeout: const Duration(seconds: 10));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only SharedPreferences-backed loads run before first frame — they're
  // essentially free (<50ms) and needed for initial routing decisions.
  await _safe('settings.load', () => SettingsService.instance.load());
  await _safe('lives.load', () => LivesService.instance.load());
  await _safe('tokens.load', () => TokenService.instance.load());

  // Non-blocking — scheduled synchronously, no await.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: PixRevealApp(),
    ),
  );

  // Kick off the heavy init AFTER the first frame is scheduled.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    // Microtask so we return to the event loop before plugin channels fire.
    scheduleMicrotask(_initHeavyServices);
  });
}
