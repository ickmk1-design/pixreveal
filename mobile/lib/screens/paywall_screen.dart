import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../state/paywall_state.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(paywallPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: MockupScreen(
        screen: 'paywall',
        assetPath: 'assets/images/paywall.png',
        onNavigate: (target, id) => _navigate(context, ref, target, id),
        overlays: [
          // Monthly highlight overlay when monthly selected
          if (plan == PaywallPlan.monthly)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.08,
              top: MediaQuery.of(context).size.height * 0.29,
              width: MediaQuery.of(context).size.width * 0.38,
              height: MediaQuery.of(context).size.height * 0.10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF00D4FF),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Color(0x9900D4FF),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, WidgetRef ref, String target, String id) {
    if (id == 'monthly') {
      ref.read(paywallPlanProvider.notifier).select(PaywallPlan.monthly);
      return;
    }
    if (id == 'yearly') {
      ref.read(paywallPlanProvider.notifier).select(PaywallPlan.yearly);
      return;
    }
    switch (target) {
      case 'menu':
        context.go('/menu');
    }
  }
}
