import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';
import '../utils/locale_helper.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _selectedPackage;
  Package? _monthlyPackage;
  Package? _yearlyPackage;
  bool _loading = false;
  bool _offeringsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await PurchaseService.instance.getOfferings();
    if (!mounted) return;
    if (offerings == null) {
      setState(() => _offeringsLoading = false);
      return;
    }
    final current = offerings.current;
    if (current == null) {
      setState(() => _offeringsLoading = false);
      return;
    }
    setState(() {
      _monthlyPackage = current.monthly;
      _yearlyPackage = current.annual;
      _selectedPackage = _yearlyPackage ?? _monthlyPackage;
      _offeringsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Stack(
          children: [
            MockupScreen(
              screen: 'paywall',
              assetPath: localeAsset('paywall'),
              calibrateMode: false,
              showBackButton: false,
              onNavigate: _onTap,
              overlayBuilder: _buildPriceOverlays,
            ),
            // X close button (not present in PNG design)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AudioService.play('button_click');
                  if (context.canPop()) { context.pop(); } else { context.go('/menu'); }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.55),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
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

  List<Widget> _buildPriceOverlays(Size size) {
    final tr = isTurkish();
    final labelStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.042,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF00D4FF),
    );
    final priceStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.055,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      shadows: const [Shadow(color: Color(0xFF00D4FF), blurRadius: 8)],
    );
    final subStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.032,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    );

    Widget priceWidget(Package? pkg, String staticLabel, String staticSub) {
      if (_offeringsLoading) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(staticLabel, style: labelStyle, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFF00D4FF),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(staticSub, style: subStyle, textAlign: TextAlign.center),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(staticLabel, style: labelStyle, textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(
            pkg?.storeProduct.priceString ?? '—',
            style: priceStyle,
            textAlign: TextAlign.center,
          ),
          Text(staticSub, style: subStyle, textAlign: TextAlign.center),
        ],
      );
    }

    return [
      Positioned(
        left: size.width * 0.04,
        top: size.height * 0.455,
        width: size.width * 0.43,
        child: priceWidget(
          _monthlyPackage,
          tr ? 'AYLIK' : 'MONTHLY',
          tr ? 'Her ay yenilenir' : 'Billed monthly',
        ),
      ),
      Positioned(
        left: size.width * 0.51,
        top: size.height * 0.455,
        width: size.width * 0.44,
        child: priceWidget(
          _yearlyPackage,
          tr ? 'YILLIK' : 'YEARLY',
          tr ? 'Her yıl yenilenir' : 'Billed annually',
        ),
      ),
    ];
  }

  void _onTap(String target, String id) {
    AudioService.play('button_click');
    if (target == 'close') {
      if (context.canPop()) { context.pop(); } else { context.go('/menu'); }
      return;
    }
    if (target != 'none') return;

    switch (id) {
      case 'monthly':
        setState(() => _selectedPackage = _monthlyPackage);
        _snack('Aylık plan seçildi');
      case 'yearly':
        setState(() => _selectedPackage = _yearlyPackage);
        _snack('Yıllık plan seçildi');
      case 'subscribe':
        _subscribe();
      case 'restore':
        _restore();
    }
  }

  Future<void> _subscribe() async {
    if (_selectedPackage == null) {
      _snack('Paket yüklenemedi — offerings boş olabilir');
      return;
    }
    setState(() => _loading = true);
    final result = await PurchaseService.instance.purchasePackage(_selectedPackage!);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      _snack('VIP aktif! Reklamsız, sınırsız can ve tüm power-up\'lar açıldı');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        if (context.canPop()) { context.pop(); } else { context.go('/categories'); }
      }
    } else if (!result.cancelled) {
      _snack('Satın alma başarısız: ${result.error ?? 'Bilinmeyen hata'}');
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    final result = await PurchaseService.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _loading = false);

    final tr = isTurkish();
    if (result.restored) {
      _snack(tr
          ? 'Satın almaların geri yüklendi'
          : 'Your purchases have been restored');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        if (context.canPop()) { context.pop(); } else { context.go('/categories'); }
      }
    } else if (result.error != null) {
      _snack(tr ? 'Hata: ${result.error}' : 'Error: ${result.error}');
    } else {
      _snack(tr
          ? 'Geri yüklenecek abonelik veya kalıcı satın alma yok'
          : 'No subscriptions or permanent purchases to restore');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      duration: const Duration(milliseconds: 2000),
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
