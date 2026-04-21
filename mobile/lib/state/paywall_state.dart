import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaywallPlan { monthly, yearly }

class PaywallNotifier extends Notifier<PaywallPlan> {
  @override
  PaywallPlan build() => PaywallPlan.yearly;

  void select(PaywallPlan plan) => state = plan;
}

final paywallPlanProvider = NotifierProvider<PaywallNotifier, PaywallPlan>(
  PaywallNotifier.new,
);
