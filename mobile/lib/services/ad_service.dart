import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entitlement_service.dart';
import '../constants/economy_config.dart';

// ─── Ad Unit IDs ───────────────────────────────────────────────
class AdConfig {
  AdConfig._();

  static final String rewardedId = Platform.isAndroid
      ? 'ca-app-pub-2172235968793446/7553607834'
      : 'ca-app-pub-2172235968793446/9800497221';

  static final String interstitialId = Platform.isAndroid
      ? 'ca-app-pub-2172235968793446/6154107707'
      : 'ca-app-pub-2172235968793446/8932314285';
}

// ─── Ad Service ────────────────────────────────────────────────
class AdService {
  AdService._();
  static final instance = AdService._();

  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  bool _initialized = false;

  // Session-bazlı ölüm sayacı — uygulama kapanınca sıfırlanır.
  int _sessionDeaths = 0;
  static const int _deathsPerAd = 3;

  bool get isVip => EntitlementService.instance.isPremium;

  /// Çağır: main() içinde, UMP consent sonrası.
  Future<void> initialize() async {
    if (kIsWeb) return;
    await _requestConsent();
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadRewarded();
    _loadInterstitial();
  }

  // ── UMP + ATT consent ──────────────────────────────────────────
  // ATT prompt iOS'ta NSUserTrackingUsageDescription (Info.plist) + bu flow ile tetiklenir.
  // GDPR/CCPA için ConsentInformation güncellenir; ilerleyen fazda UMP form gösterimi eklenebilir.
  Future<void> _requestConsent() async {
    try {
      final done = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => done.complete(),
        (error) {
          debugPrint('UMP consent error: ${error.message}');
          done.complete();
        },
      );
      await done.future;
    } catch (e) {
      debugPrint('UMP exception: $e');
    }
  }

  // ── Rewarded ──────────────────────────────────────────────────
  void _loadRewarded() {
    if (!_initialized) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          debugPrint('[AdService] Rewarded ad loaded OK');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded load failed: ${error.message}');
          _rewarded = null;
          // 30 saniye sonra tekrar dene
          Future.delayed(const Duration(seconds: 30), _loadRewarded);
        },
      ),
    );
  }

  /// Rewarded reklam göster. [onEarned]: ödül verildiğinde çağrılır.
  /// [onNotReady]: reklam henüz hazır değilse çağrılır (opsiyonel).
  /// Reklam yüklü değilse kullanıcıya bilgi verir ve yeniden yükleme tetikler.
  Future<void> showRewarded({
    required VoidCallback onEarned,
    VoidCallback? onNotReady,
  }) async {
    if (!_initialized || isVip) {
      // VIP: reklamlara girme, ödülü direkt ver
      onEarned();
      return;
    }
    final ad = _rewarded;
    if (ad == null) {
      debugPrint('[AdService] Rewarded ad not ready — triggering reload');
      _loadRewarded(); // yeni yüklemeyi tetikle
      onNotReady?.call();
      return;
    }
    _rewarded = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        _loadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => onEarned());
  }

  bool get isRewardedReady => _rewarded != null;

  // ── Interstitial ──────────────────────────────────────────────
  void _loadInterstitial() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          debugPrint('[AdService] Interstitial ad loaded OK');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial load failed: ${error.message}');
          _interstitial = null;
          // 30 saniye sonra tekrar dene
          Future.delayed(const Duration(seconds: 30), _loadInterstitial);
        },
      ),
    );
  }

  /// Oyuncu öldüğünde çağır. Her 3 ölümde 1 otomatik interstitial.
  Future<void> onPlayerDied() async {
    if (!_initialized || isVip) return;
    _sessionDeaths++;
    debugPrint('[AdService] Death #$_sessionDeaths');
    if (_sessionDeaths % _deathsPerAd == 0) {
      debugPrint('[AdService] Auto interstitial after $_sessionDeaths deaths');
      await _showInterstitial();
    }
  }

  /// Level tamamlandığında çağır. Her [EconomyConfig.interstitialEvery]
  /// level'da bir interstitial gösterir. VIP'te göstermez.
  Future<void> onLevelCompleted() async {
    if (!_initialized) return;
    if (isVip) {
      debugPrint('[AdService] Premium user, skipping interstitial');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt('levels_since_ad') ?? 0) + 1;
    debugPrint('[AdService] Level complete, counter=$count');
    if (count >= EconomyConfig.interstitialEvery) {
      await prefs.setInt('levels_since_ad', 0);
      await _showInterstitial();
    } else {
      await prefs.setInt('levels_since_ad', count);
    }
  }

  /// Public: reklam göster (premium ise atla).
  Future<void> showInterstitial() => _showInterstitial();

  Future<void> _showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      debugPrint('[AdService] Interstitial not ready, loading...');
      _loadInterstitial(); // yüklemeyi tetikle (bir sonraki cycle için)
      return;
    }
    debugPrint('[AdService] Showing interstitial...');
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        _loadInterstitial();
      },
    );
    await ad.show();
  }
}
