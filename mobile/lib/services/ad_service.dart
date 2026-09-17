import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entitlement_service.dart';
import '../constants/economy_config.dart';

// ─── Ad Unit IDs ───────────────────────────────────────────────
class AdConfig {
  AdConfig._();

  static final String rewardedId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : (Platform.isAndroid
          ? 'ca-app-pub-2172235968793446/7553607834'
          : 'ca-app-pub-2172235968793446/9800497221');

  static final String interstitialId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : (Platform.isAndroid
          ? 'ca-app-pub-2172235968793446/6154107707'
          : 'ca-app-pub-2172235968793446/8932314285');
}

// ─── Ad Service ────────────────────────────────────────────────
class AdService {
  AdService._();
  static final instance = AdService._();

  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  bool _initialized = false;

  // ── ATT / UMP izin durumu ────────────────────────────────────
  // Default FALSE — izin doğrulanana kadar personalized ad İSTEMEYİZ.
  // Apple 5.1.1(iv): ATT denied/notDetermined iken IDFA/tracking cookie
  // çekilmemeli → non-personalized ad request gönderilir.
  bool _trackingAllowed = false; // iOS ATT authorized
  bool _umpAllowed = false;      // UMP obtained veya notRequired (non-EEA)

  // Session-bazlı ölüm sayacı — uygulama kapanınca sıfırlanır.
  int _sessionDeaths = 0;
  static const int _deathsPerAd = 3;

  bool get isVip => EntitlementService.instance.isPremium;

  /// Sıra: UMP/GDPR formu → ATT (iOS) → MobileAds init → ad load.
  /// Apple 5.1.1(iv): GDPR formu ATT'den ÖNCE gösterilmeli.
  Future<void> initialize() async {
    if (kIsWeb) return;
    debugPrint('[AdInit] START');
    await _requestConsent();         // 1) UMP/GDPR → _umpAllowed set
    await _requestAttPermission();   // 2) ATT      → _trackingAllowed set
    debugPrint('[AdInit] Consent snapshot → tracking=$_trackingAllowed '
        'ump=$_umpAllowed → personalized=${_trackingAllowed && _umpAllowed}');
    debugPrint('[AdInit] MobileAds.initialize()');
    await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint('[AdInit] DONE — loading ads');
    _loadRewarded();
    _loadInterstitial();
  }

  // ── AdRequest builder — ATT + UMP izinlerine göre npa hesapla ──
  // Kural: (_trackingAllowed && _umpAllowed) DEĞİLSE non-personalized.
  //   - ATT denied / notDetermined (iOS) → npa=1
  //   - UMP required / unknown (EEA formu reddedildi) → npa=1
  //   - Android'de ATT yok → _trackingAllowed init'te authorized
  //     gibi işlem görecek (bkz. _requestAttPermission).
  // extras: {'npa':'1'} mediation ağlarına da sinyal verir.
  AdRequest _buildAdRequest() {
    final canPersonalize = _trackingAllowed && _umpAllowed;
    if (canPersonalize) {
      debugPrint('[AdRequest] npa=0 (personalized) — tracking + ump OK');
      return const AdRequest();
    }
    debugPrint('[AdRequest] npa=1 (NON-personalized) — '
        'tracking=$_trackingAllowed ump=$_umpAllowed');
    return const AdRequest(
      nonPersonalizedAds: true,
      extras: {'npa': '1'},
    );
  }

  // ── ATT (iOS App Tracking Transparency) ────────────────────────
  // Popup için Info.plist'te NSUserTrackingUsageDescription şart.
  // iOS 14.5+ cihazlarda notDetermined ise popup göster; kullanıcı yanıtını bekle.
  Future<void> _requestAttPermission() async {
    if (!Platform.isIOS) {
      // Android'de ATT yok — tracking izni ATT üzerinden aranmaz.
      // AdMob personalization Android tarafında UMP / user settings ile
      // yönetilir; ATT flag'ini "izinli" işaretle ki iOS-özel kısıt
      // Android'i etkilemesin.
      _trackingAllowed = true;
      debugPrint('[ATT] Non-iOS platform — _trackingAllowed=true (N/A)');
      return;
    }
    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('[ATT] Current status: $status');
      if (status == TrackingStatus.notDetermined) {
        // İlk kare çizilsin diye küçük gecikme (Apple önerisi).
        await Future.delayed(const Duration(milliseconds: 250));
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('[ATT] Request result: $status');
      } else {
        debugPrint('[ATT] Already resolved — no popup');
      }
      _trackingAllowed = status == TrackingStatus.authorized;
      debugPrint('[ATT] _trackingAllowed=$_trackingAllowed (status=$status)');
    } catch (e) {
      debugPrint('[ATT] Exception: $e — _trackingAllowed stays false');
      _trackingAllowed = false;
    }
  }

  // ── UMP (GDPR/CCPA consent) ────────────────────────────────────
  // Info güncelle → gerekiyorsa formu yükleyip göster → devam et.
  Future<void> _requestConsent() async {
    try {
      final infoDone = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          debugPrint('[UMP] Consent info updated');
          infoDone.complete();
        },
        (error) {
          debugPrint('[UMP] requestConsentInfoUpdate error: ${error.message}');
          infoDone.complete();
        },
      );
      await infoDone.future;

      final formDone = Completer<void>();
      ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          debugPrint('[UMP] loadAndShowConsentFormIfRequired error: '
              '${error.message}');
        } else {
          debugPrint('[UMP] Form flow complete');
        }
        formDone.complete();
      });
      await formDone.future;

      // ConsentStatus okuması:
      //   obtained    → kullanıcı formda seçim yaptı, personalized OK
      //   notRequired → GDPR bölgesi dışı, izin gerekmiyor → OK
      //   required    → izin lazım ama alınmamış → NPA
      //   unknown     → durum belirsiz → NPA (güvenli taraf)
      final status = await ConsentInformation.instance.getConsentStatus();
      _umpAllowed = status == ConsentStatus.obtained ||
          status == ConsentStatus.notRequired;
      debugPrint('[UMP] _umpAllowed=$_umpAllowed (status=$status)');
    } catch (e) {
      debugPrint('[UMP] Exception: $e — _umpAllowed stays false');
      _umpAllowed = false;
    }
  }

  // ── Rewarded ──────────────────────────────────────────────────
  void _loadRewarded() {
    if (!_initialized) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: _buildAdRequest(),
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
      request: _buildAdRequest(),
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
