import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/retro_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userState = ref.watch(userProvider);
    final iap = ref.read(iapServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonBlue),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: AppColors.neonBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game settings
            RetroCard(
              child: Column(
                children: [
                  _settingToggle(
                    'Sound Effects',
                    settings.soundEnabled,
                    () => ref.read(settingsProvider.notifier).toggleSound(),
                  ),
                  const Divider(color: AppColors.gridLine, height: 24),
                  _settingToggle(
                    'Music',
                    settings.musicEnabled,
                    () => ref.read(settingsProvider.notifier).toggleMusic(),
                  ),
                  const Divider(color: AppColors.gridLine, height: 24),
                  _settingToggle(
                    'Vibration',
                    settings.vibrationEnabled,
                    () => ref.read(settingsProvider.notifier).toggleVibration(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Account info
            RetroCard(
              borderColor: AppColors.neonPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCOUNT',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.neonPink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _settingRow(
                    'Provider',
                    userState.provider,
                  ),
                  if (userState.email != null) ...[
                    const Divider(color: AppColors.gridLine, height: 20),
                    _settingRow('Email', userState.email!),
                  ],
                  if (userState.displayName != null) ...[
                    const Divider(color: AppColors.gridLine, height: 20),
                    _settingRow('Name', userState.displayName!),
                  ],
                  if (userState.isAnonymous) ...[
                    const Divider(color: AppColors.gridLine, height: 20),
                    const Text(
                      'Link an account to save progress',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 6,
                        color: AppColors.neonYellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neonGreen),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LINK ACCOUNT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8,
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Purchases
            RetroCard(
              borderColor: AppColors.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PURCHASES',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await iap.restorePurchases();
                      await ref
                          .read(userProvider.notifier)
                          .refreshEntitlements();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchases restored'),
                            backgroundColor: AppColors.neonGreen,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RESTORE PURCHASES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 8,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Legal
            RetroCard(
              borderColor: AppColors.neonBlue,
              child: Column(
                children: [
                  _linkRow(
                    'Privacy Policy',
                    () => context.push('/privacy'),
                  ),
                  const Divider(color: AppColors.gridLine, height: 20),
                  _linkRow(
                    'Terms of Service',
                    () => context.push('/terms'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info
            RetroCard(
              child: Column(
                children: [
                  _settingRow('Language', settings.language.toUpperCase()),
                  const Divider(color: AppColors.gridLine, height: 24),
                  _settingRow('Version', '1.0.0'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign out
            if (userState.isLoggedIn && !userState.isAnonymous)
              GestureDetector(
                onTap: () async {
                  await ref.read(userProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neonYellow),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppColors.neonYellow,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Delete account
            if (userState.isLoggedIn)
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DELETE ACCOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'DELETE ACCOUNT',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'This will permanently delete your account and all game data. This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 7,
            color: Colors.white70,
            height: 1.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: AppColors.neonBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Delete from backend
              final uid = ref.read(userProvider).uid;
              if (uid != null) {
                try {
                  await http.delete(
                    Uri.parse(
                        '${AppConstants.apiBaseUrl}/api/auth/account?user_id=$uid'),
                  );
                } catch (_) {}
              }

              // Delete from Firebase
              await ref.read(userProvider.notifier).deleteAccount();
              if (context.mounted) context.go('/login');
            },
            child: const Text(
              'DELETE',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingToggle(String label, bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 9,
              color: AppColors.white,
            ),
          ),
          Container(
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: value ? AppColors.neonGreen : AppColors.gridLine,
              border: Border.all(
                color: value ? AppColors.neonGreen : AppColors.gridLine,
                width: 2,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? AppColors.white : AppColors.darkCard,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 8,
            color: AppColors.white,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 7,
              color: AppColors.neonBlue,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _linkRow(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              color: AppColors.white,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.neonBlue,
            size: 20,
          ),
        ],
      ),
    );
  }
}
