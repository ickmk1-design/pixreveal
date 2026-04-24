import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/revenue_cat_keys.dart';
import 'purchase_service.dart';

class EntitlementService {
  EntitlementService._();
  static final instance = EntitlementService._();

  bool _isPremium = false;
  final _notifier = ValueNotifier<bool>(false);

  ValueNotifier<bool> get notifier => _notifier;
  bool get isPremium => _isPremium;

  void init() {
    if (kIsWeb) return;
    PurchaseService.instance.addCustomerInfoListener(_onCustomerInfo);
  }

  void _onCustomerInfo(CustomerInfo info) {
    _isPremium =
        info.entitlements.active.containsKey(RevenueCatKeys.entitlementPremium);
    _notifier.value = _isPremium;
  }

  Future<void> refresh() async {
    _isPremium = await PurchaseService.instance.isPremium;
    _notifier.value = _isPremium;
  }
}
