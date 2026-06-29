import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';
import '../services/token_service.dart';
import '../services/entitlement_service.dart';
import '../services/ad_service.dart';
import '../utils/locale_helper.dart';
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
              assetPath: localeAsset('shop'),
              showBackButton: true,
              onBack: () {
                AudioService.play('button_click');
                context.go('/menu');
              },
              onNavigate: (target, id) => _navigate(target, id),
              overlayBuilder: _buildPriceOverlays,
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

  String _price(int amount) {
    final key = 'token_$amount';
    final pkg = _offerings?.current?.getPackage(key)
        ?? _offerings?.current?.availablePackages
            .where((p) => p.identifier == key)
            .firstOrNull;
    return pkg?.storeProduct.priceString ?? '';
  }

  List<Widget> _buildPriceOverlays(Size size) {
    final style = GoogleFonts.rajdhani(
      fontSize: size.width * 0.038,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF3D2800),
      shadows: const [
        Shadow(color: Color(0x55000000), blurRadius: 2, offset: Offset(0, 1)),
      ],
    );

    // xPct/yPct = button top-left, wPct/hPct = button size — text centered inside
    Widget btn(double xPct, double yPct, double wPct, double hPct, String text) =>
        Positioned(
          left: size.width * xPct / 100,
          top: size.height * yPct / 100,
          width: size.width * wPct / 100,
          height: size.height * hPct / 100,
          child: Center(
            child: Text(text, style: style, textAlign: TextAlign.center),
          ),
        );

    final p20  = _price(20);
    final p50  = _price(50);
    final p120 = _price(120);
    final p300 = _price(300);
    final p750 = _price(750);

    // Button areas (bottom ~4% of each card):
    // 3-card row cards: y=23-41% → buttons at y=37-41%
    // 2-card row cards: y=43-61% → buttons at y=57-61%
    return [
      if (p20.isNotEmpty)  btn(2,  37, 31, 4, p20),
      if (p50.isNotEmpty)  btn(35, 37, 30, 4, p50),
      if (p120.isNotEmpty) btn(67, 37, 31, 4, p120),
      if (p300.isNotEmpty) btn(2,  57, 46, 4, p300),
      if (p750.isNotEmpty) btn(51, 57, 47, 4, p750),
    ];
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
        _snack('Arabalar teması seçildi');
      case 'theme-space':
        _snack('Uzay teması seçildi');
      case 'theme-anim':
        _snack('Hayvanlar teması seçildi');
      case 'theme-beach':
        if (EntitlementService.instance.isPremium) {
          _snack('Plaj teması seçildi');
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
