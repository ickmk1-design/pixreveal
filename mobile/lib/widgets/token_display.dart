import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/token_provider.dart';
import '../utils/constants.dart';

class TokenDisplay extends ConsumerWidget {
  const TokenDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 9,
                  color: AppColors.darkBg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tokenState.tokens}',
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 14,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
