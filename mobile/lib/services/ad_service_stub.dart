/// Stub AdService for web platform — ads are not supported on web.
class AdService {
  Future<void> init() async {}
  void loadInterstitial() {}
  void loadRewarded() {}
  void setAdFree(bool adFree) {}
  Future<bool> showInterstitialIfReady() async => false;
  Future<bool> notifyLevelComplete() async => false;
  bool get isRewardedReady => false;
  Future<void> showRewarded({required void Function() onRewarded}) async {}
  void dispose() {}
}
