import 'package:purchases_flutter/purchases_flutter.dart';

// RevenueCat product identifiers
class IAPProducts {
  // Consumable token packs
  static const tokenPack20 = 'pixreveal_tokens_20';
  static const tokenPack50 = 'pixreveal_tokens_50';
  static const tokenPack120 = 'pixreveal_tokens_120';
  static const tokenPack300 = 'pixreveal_tokens_300';
  static const tokenPack750 = 'pixreveal_tokens_750';

  // Non-consumable theme packs
  static const themeArt = 'pixreveal_theme_art';
  static const themeCars = 'pixreveal_theme_cars';
  static const themeFantasy = 'pixreveal_theme_fantasy';
  static const themeNeon = 'pixreveal_theme_neon';
  static const themeLegend = 'pixreveal_theme_legend';

  // Non-consumable one-time
  static const removeAds = 'pixreveal_remove_ads';

  // Subscriptions
  static const customMonthly = 'pixreveal_custom_monthly';
  static const customYearly = 'pixreveal_custom_yearly';
  static const premiumMonthly = 'pixreveal_premium_monthly';
  static const premiumYearly = 'pixreveal_premium_yearly';

  static const allTokenPacks = [
    tokenPack20,
    tokenPack50,
    tokenPack120,
    tokenPack300,
    tokenPack750,
  ];

  static const allThemePacks = [
    themeArt,
    themeCars,
    themeFantasy,
    themeNeon,
    themeLegend,
  ];

  static const allSubscriptions = [
    customMonthly,
    customYearly,
    premiumMonthly,
    premiumYearly,
  ];

  static int tokenCount(String productId) {
    switch (productId) {
      case tokenPack20:
        return 20;
      case tokenPack50:
        return 50;
      case tokenPack120:
        return 120;
      case tokenPack300:
        return 300;
      case tokenPack750:
        return 750;
      default:
        return 0;
    }
  }

  static String displayName(String productId) {
    switch (productId) {
      case tokenPack20:
        return '20 Tokens';
      case tokenPack50:
        return '50 Tokens';
      case tokenPack120:
        return '120 Tokens';
      case tokenPack300:
        return '300 Tokens';
      case tokenPack750:
        return '750 Tokens';
      case themeArt:
        return 'Art Collection';
      case themeCars:
        return 'Cars & Speed';
      case themeFantasy:
        return 'Fantasy World';
      case themeNeon:
        return 'Neon City';
      case themeLegend:
        return 'Legends';
      case removeAds:
        return 'Remove Ads';
      case customMonthly:
        return 'Custom Image Monthly';
      case customYearly:
        return 'Custom Image Yearly';
      case premiumMonthly:
        return 'Premium Monthly';
      case premiumYearly:
        return 'Premium Yearly';
      default:
        return productId;
    }
  }
}

// RevenueCat entitlements
class Entitlements {
  static const customImage = 'custom_image';
  static const premium = 'premium';
  static const adFree = 'ad_free';
}

class IAPService {
  static const apiKey = 'test_KUxVJUvmaaazvPxhjMmSGkYWcNa';

  bool _initialized = false;
  Offerings? _cachedOfferings;

  /// Mark as initialized (configure is called in main.dart)
  void markInitialized() {
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  /// Fetch available offerings from RevenueCat
  Future<Offerings?> fetchOfferings() async {
    try {
      _cachedOfferings = await Purchases.getOfferings();
      return _cachedOfferings;
    } catch (_) {
      return null;
    }
  }

  /// Get cached offerings (call fetchOfferings first)
  Offerings? get offerings => _cachedOfferings;

  /// Get the current (default) offering
  Offering? get currentOffering => _cachedOfferings?.current;

  /// Get packages from an offering by identifier
  List<Package> getPackages(String offeringId) {
    final offering = _cachedOfferings?.getOffering(offeringId);
    return offering?.availablePackages ?? [];
  }

  /// Get all available packages from the current offering
  List<Package> get currentPackages =>
      currentOffering?.availablePackages ?? [];

  /// Get products by their store product IDs
  Future<List<StoreProduct>> getProducts(List<String> productIds) async {
    try {
      return await Purchases.getProducts(productIds);
    } catch (_) {
      return [];
    }
  }

  /// Purchase a package (preferred over purchasing a product directly)
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Purchase a store product directly
  Future<CustomerInfo?> purchase(StoreProduct product) async {
    try {
      return await Purchases.purchaseStoreProduct(product);
    } catch (_) {
      return null;
    }
  }

  /// Restore previous purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (_) {
      return null;
    }
  }

  /// Check if user has a specific entitlement
  Future<bool> hasEntitlement(String entitlement) async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlement);
    } catch (_) {
      return false;
    }
  }

  /// Check all entitlements at once
  Future<Map<String, bool>> checkAllEntitlements() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return {
        Entitlements.premium:
            info.entitlements.active.containsKey(Entitlements.premium),
        Entitlements.customImage:
            info.entitlements.active.containsKey(Entitlements.customImage),
        Entitlements.adFree:
            info.entitlements.active.containsKey(Entitlements.adFree),
      };
    } catch (_) {
      return {
        Entitlements.premium: false,
        Entitlements.customImage: false,
        Entitlements.adFree: false,
      };
    }
  }

  Future<bool> isPremium() => hasEntitlement(Entitlements.premium);
  Future<bool> hasCustomImage() => hasEntitlement(Entitlements.customImage);
  Future<bool> isAdFree() => hasEntitlement(Entitlements.adFree);

  /// Log in a user to RevenueCat (syncs purchases across devices)
  Future<void> logIn(String userId) async {
    try {
      await Purchases.logIn(userId);
      await fetchOfferings();
    } catch (_) {}
  }

  /// Log out from RevenueCat
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (_) {}
  }

  /// Get customer info for purchase history
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }
}
