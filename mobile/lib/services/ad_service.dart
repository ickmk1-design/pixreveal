import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  // Test Ad Unit IDs (replace with real ones before production)
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId =>
      Platform.isAndroid ? _testBannerAndroid : _testBannerIos;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;

  static String get rewardedAdUnitId =>
      Platform.isAndroid ? _testRewardedAndroid : _testRewardedIos;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _levelsSinceLastAd = 0;
  bool _isAdFree = false;

  static const int _levelsBeforeInterstitial = 3;

  /// Track level completion. Checks ad-free status first.
  Future<bool> notifyLevelComplete() async {
    // Check if ads removed via IAP
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('ads_removed') == true) return false;
    } catch (_) {}
    return await showInterstitialIfReady();
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  void setAdFree(bool adFree) {
    _isAdFree = adFree;
    if (_isAdFree) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
    }
  }

  // --- Interstitial ---

  Future<void> loadInterstitial() async {
    if (_isAdFree) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  /// Show interstitial after every N levels. Returns true if shown.
  Future<bool> showInterstitialIfReady() async {
    if (_isAdFree) return false;

    _levelsSinceLastAd++;
    if (_levelsSinceLastAd < _levelsBeforeInterstitial) return false;

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
        },
      );
      await _interstitialAd!.show();
      _levelsSinceLastAd = 0;
      return true;
    }

    // Ad not loaded yet, try loading for next time
    loadInterstitial();
    return false;
  }

  // --- Rewarded (for tokens) ---

  Future<void> loadRewarded() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  bool get isRewardedReady => _rewardedAd != null;

  /// Show rewarded ad. Calls [onRewarded] when user earns the reward.
  Future<void> showRewarded({required void Function() onRewarded}) async {
    if (_rewardedAd == null) {
      loadRewarded();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onRewarded(),
    );
  }

  // --- Banner ---

  BannerAd createBanner({AdSize size = AdSize.banner}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
