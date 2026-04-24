import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/revenue_cat_keys.dart';

class PurchaseService {
  PurchaseService._();
  static final instance = PurchaseService._();

  bool _initialized = false;

  Future<void> configure({String? userId}) async {
    if (kIsWeb) return;
    if (_initialized) return;

    final apiKey = Platform.isIOS
        ? RevenueCatKeys.iosApiKey
        : RevenueCatKeys.androidApiKey;

    final config = PurchasesConfiguration(apiKey);
    if (userId != null) config.appUserID = userId;

    await Purchases.configure(config);
    await Purchases.setLogLevel(LogLevel.debug);
    _initialized = true;
    debugPrint('[RC] Purchases configured. Platform: ${Platform.operatingSystem}');
  }

  Future<Offerings?> getOfferings() async {
    if (kIsWeb || !_initialized) return null;
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('[RC] Offerings keys: ${offerings.all.keys.toList()}');
      debugPrint('[RC] Current offering: ${offerings.current?.identifier}');
      debugPrint('[RC] Packages: ${offerings.current?.availablePackages.map((p) => p.identifier).toList()}');
      return offerings;
    } catch (e, st) {
      debugPrint('[RC] getOfferings ERROR: $e');
      debugPrint('[RC] StackTrace: $st');
      return null;
    }
  }

  Future<({bool success, String? error, bool cancelled})> purchasePackage(
      Package pkg) async {
    if (kIsWeb || !_initialized) {
      return (success: false, error: 'Satın alma bu platformda desteklenmiyor', cancelled: false);
    }
    try {
      await Purchases.purchasePackage(pkg);
      return (success: true, error: null, cancelled: false);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return (success: false, error: null, cancelled: true);
      }
      return (success: false, error: e.name, cancelled: false);
    } catch (e) {
      return (success: false, error: e.toString(), cancelled: false);
    }
  }

  Future<({bool hasPremium, String? error})> restorePurchases() async {
    if (kIsWeb || !_initialized) {
      return (hasPremium: false, error: 'Desteklenmiyor');
    }
    try {
      final info = await Purchases.restorePurchases();
      final hasPremium =
          info.entitlements.active.containsKey(RevenueCatKeys.entitlementPremium);
      return (hasPremium: hasPremium, error: null);
    } catch (e) {
      return (hasPremium: false, error: e.toString());
    }
  }

  Future<bool> get isPremium async {
    if (kIsWeb || !_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active
          .containsKey(RevenueCatKeys.entitlementPremium);
    } catch (_) {
      return false;
    }
  }

  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    if (kIsWeb || !_initialized) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoListener(void Function(CustomerInfo) listener) {
    if (kIsWeb || !_initialized) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }
}
