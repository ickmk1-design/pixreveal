import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';
import '../services/token_service.dart';
import '../services/entitlement_service.dart';
import '../services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Offerings? _offerings;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final o = await PurchaseService.instance.getOfferings();
    if (mounted) setState(() => _offerings = o);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Stack(
          children: [
            MockupScreen(
              screen: 'shop',
              assetPath: 'assets/images/shop.png',
              showBackButton: true,
              onBack: () {
                AudioService.play('button_click');
                context.go('/menu');
              },
              onNavigate: (target, id) => _navigate(target, id),
            ),
            if (_loading)
              const ColoredBox(
                color: Color(0x88000000),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))),
              ),
          ],
        ),
      ),
    );
  }

  void _navigate(String target, String id) {
    AudioService.play('button_click');
    switch (target) {
      case 'menu':
        context.go('/menu');
      case 'paywall':
        context.go('/paywall');
      case 'none':
        _handleAction(id);
    }
  }

  void _handleAction(String id) {
    switch (id) {
      case 'watch-ad':
        _handleWatchAd();
      case 'pack-20':
        _buyTokens(20);
      case 'pack-50':
        _buyTokens(50);
      case 'pack-120':
        _buyTokens(120);
      case 'pack-300':
        _buyTokens(300);
      case 'pack-750':
        _buyTokens(750);
      case 'theme-cars':
      case 'theme-space':
      case 'theme-anim':
        _snack('Tema seçimi yakında');
      case 'theme-beach':
      case 'theme-lock':
        if (EntitlementService.instance.isPremium) {
          _snack('Tema seçimi yakında');
        } else {
          context.go('/paywall');
        }
      case 'go-premium':
        context.go('/paywall');
      case 'restore':
        _restore();
      default:
        _snack('Yakında');
    }
  }

  static const int _dailyAdTokenLimit = 10;
  static const String _kAdCount = 'shop_ad_tokens_today';
  static const String _kAdDate  = 'shop_ad_date';

  Future<void> _handleWatchAd() async {
    if (!AdService.instance.isRewardedReady) {
      _snack('Reklam henüz hazırlanıyor, birkaç saniye bekle.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString(_kAdDate) ?? '';
    if (savedDate != dateStr) {
      await prefs.setInt(_kAdCount, 0);
      await prefs.setString(_kAdDate, dateStr);
    }
    final count = prefs.getInt(_kAdCount) ?? 0;
    if (count >= _dailyAdTokenLimit) {
      _snack('Günlük limit doldu (10/10). Yarın tekrar dene.');
      return;
    }

    AdService.instance.showRewarded(
      onEarned: () async {
        await prefs.setInt(_kAdCount, count + 1);
        await TokenService.instance.addTokens(1);
        if (mounted) _snack('1 token kazandın! Bakiye: ${TokenService.instance.balance}');
      },
      onNotReady: () {
        if (mounted) _snack('Reklam hazır değil, biraz bekle.');
      },
    );
  }

  Future<void> _buyTokens(int amount) async {
    final lookupKey = 'token_$amount';
    final pkg = _offerings?.current?.getPackage(lookupKey)
        ?? _offerings?.current?.availablePackages
            .where((p) => p.identifier == lookupKey)
            .firstOrNull;

    if (pkg == null) {
      final available = _offerings?.current?.availablePackages
          .map((p) => p.identifier).toList() ?? [];
      _snack('$lookupKey bulunamadı. Mevcut: $available');
      return;
    }

    setState(() => _loading = true);
    final result = await PurchaseService.instance.purchasePackage(pkg);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      await TokenService.instance.addTokens(amount);
      _snack('$amount token eklendi! Yeni bakiye: ${TokenService.instance.balance}');
    } else if (!result.cancelled) {
      _snack('Satın alma başarısız: ${result.error ?? 'Bilinmeyen hata'}');
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    final result = await PurchaseService.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.hasPremium) {
      _snack('Aboneliğin geri yüklendi!');
    } else if (result.error != null) {
      _snack('Hata: ${result.error}');
    } else {
      _snack('Aktif abonelik bulunamadı');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      duration: const Duration(milliseconds: 1500),
      backgroundColor: const Color(0xFF1A0F2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00D4FF), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60),
    ));
  }
}
