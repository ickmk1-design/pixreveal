import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mockup_screen.dart';
import '../state/paywall_state.dart';
import '../services/audio_service.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(paywallPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: MockupScreen(
          screen: 'paywall',
          assetPath: 'assets/images/paywall.png',
          showBackButton: true,
          onBack: () {
            AudioService.play('button_click');
            context.go('/menu');
          },
          onNavigate: (target, id) => _navigate(context, ref, target, id),
          overlayBuilder: (size) => [
            // Default highlight in the PNG is on the YEARLY plan.
            // If user taps MONTHLY, draw a cyan ring on it.
            if (plan == PaywallPlan.monthly)
              Positioned(
                left: size.width * 0.17,
                top: size.height * 0.404,
                width: size.width * 0.20,
                height: size.height * 0.124,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00D4FF),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigate(
      BuildContext context, WidgetRef ref, String target, String id) {
    AudioService.play('button_click');
    if (target == 'menu') {
      context.go('/menu');
      return;
    }
    if (target == 'none') {
      if (id == 'monthly') {
        ref.read(paywallPlanProvider.notifier).select(PaywallPlan.monthly);
      } else if (id == 'yearly') {
        ref.read(paywallPlanProvider.notifier).select(PaywallPlan.yearly);
      } else if (id == 'restore') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satın almaları geri yükleme yakında'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
