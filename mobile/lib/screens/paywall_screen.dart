import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../widgets/mockup_screen.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';
import '../utils/locale_helper.dart';
import '../constants/calibrate.dart';

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
  bool _offeringsError = false;

  // İçerik alanı — fiyat metni buraya çizilir
  static const double _monthlyX = 2,  _monthlyY = 57, _monthlyW = 44, _monthlyH = 15;
  static const double _yearlyX  = 50, _yearlyY  = 57, _yearlyW  = 33, _yearlyH  = 15; // w=33: %40 rozeti sağda kalır
  // Seçim çerçevesi — gerçek iPhone köşe kalibrasyonu 2026-08-28
  static const double _monthlyBX = 11,  _monthlyBY = 51.5, _monthlyBW = 34, _monthlyBH = 21;
  static const double _yearlyBX  = 53,  _yearlyBY  = 51.5, _yearlyBW  = 34, _yearlyBH  = 21;
  static const double _subscribeX = 8, _subscribeY = 79, _subscribeW = 84, _subscribeH = 10;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _offeringsLoading = true;
      _offeringsError = false;
    });
    final offerings = await PurchaseService.instance.getOfferings();
    if (!mounted) return;
    final current = offerings?.current;
    if (current == null) {
      setState(() {
        _offeringsLoading = false;
        _offeringsError = true;
      });
      return;
    }
    setState(() {
      _monthlyPackage = current.monthly;
      _yearlyPackage = current.annual;
      // Default: yearly (RECOMMENDED)
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
              calibrateMode: kCalibrateMode,
              showBackButton: false,
              onNavigate: _onTap,
              overlayBuilder: _buildOverlays,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AudioService.play('button_click');
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/menu');
                  }
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
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOverlays(Size size) {
    final tr = isTurkish();

    final labelStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.038,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF00D4FF),
    );
    final priceStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.052,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      shadows: const [Shadow(color: Color(0xFF00D4FF), blurRadius: 8)],
    );
    final subStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.028,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    );

    final renewalStyle = GoogleFonts.rajdhani(
      fontSize: size.width * 0.022,
      fontWeight: FontWeight.w500,
      color: Colors.white54,
    );

    Widget priceContent(Package? pkg, String label, String periyot, String renewal) {
      if (_offeringsLoading) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(label, style: labelStyle, textAlign: TextAlign.center),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 2),
            ),
            Text(periyot, style: subStyle, textAlign: TextAlign.center),
            Text(renewal, style: renewalStyle, textAlign: TextAlign.center),
          ],
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(label, style: labelStyle, textAlign: TextAlign.center),
          Text(
            pkg?.storeProduct.priceString ?? '—',
            style: priceStyle,
            textAlign: TextAlign.center,
          ),
          Text(periyot, style: subStyle, textAlign: TextAlign.center),
          Text(renewal, style: renewalStyle, textAlign: TextAlign.center),
        ],
      );
    }

    // Yearly is selected unless monthly was explicitly chosen
    final bool monthlySelected = _selectedPackage == _monthlyPackage && _selectedPackage != null;
    final bool yearlySelected = !monthlySelected;

    const borderRadius = BorderRadius.all(Radius.circular(12));
    const selectedBorder = BoxDecoration(
      borderRadius: borderRadius,
      border: Border.fromBorderSide(
        BorderSide(color: Color(0xFF00D4FF), width: 2.5),
      ),
    );

    return [
      // ── Monthly box: dikey dağılım başlık→fiyat→periyot→yenilenme ──
      Positioned(
        left: size.width * _monthlyX / 100,
        top: size.height * _monthlyY / 100,
        width: size.width * _monthlyW / 100,
        height: size.height * _monthlyH / 100,
        child: priceContent(
          _monthlyPackage,
          tr ? 'AYLIK' : 'MONTHLY',
          tr ? '/ay' : '/mo',
          tr ? 'Her ay yenilenir' : 'Billed monthly',
        ),
      ),

      // ── Yearly box: dikey dağılım başlık→fiyat→periyot→yenilenme ──
      Positioned(
        left: size.width * _yearlyX / 100,
        top: size.height * _yearlyY / 100,
        width: size.width * _yearlyW / 100,
        height: size.height * _yearlyH / 100,
        child: priceContent(
          _yearlyPackage,
          tr ? 'YILLIK' : 'YEARLY',
          tr ? '/yıl' : '/yr',
          tr ? 'Her yıl yenilenir' : 'Billed annually',
        ),
      ),

      // ── Selected border: monthly ─────────────────────────────────
      if (monthlySelected)
        Positioned(
          left: size.width * _monthlyBX / 100,
          top: size.height * _monthlyBY / 100,
          width: size.width * _monthlyBW / 100,
          height: size.height * _monthlyBH / 100,
          child: const DecoratedBox(decoration: selectedBorder),
        ),

      // ── Selected border: yearly (default + explicit) ─────────────
      if (yearlySelected)
        Positioned(
          left: size.width * _yearlyBX / 100,
          top: size.height * _yearlyBY / 100,
          width: size.width * _yearlyBW / 100,
          height: size.height * _yearlyBH / 100,
          child: const DecoratedBox(decoration: selectedBorder),
        ),

      // ── Subscribe area: loading indicator ───────────────────────
      if (_offeringsLoading)
        Positioned(
          left: size.width * _subscribeX / 100,
          top: size.height * _subscribeY / 100,
          width: size.width * _subscribeW / 100,
          height: size.height * _subscribeH / 100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFF00D4FF),
                strokeWidth: 2,
              ),
            ),
          ),
        ),

      // ── Subscribe area: error / retry hint ──────────────────────
      if (_offeringsError)
        Positioned(
          left: size.width * _subscribeX / 100,
          top: size.height * _subscribeY / 100,
          width: size.width * _subscribeW / 100,
          height: size.height * _subscribeH / 100,
          child: Center(
            child: Text(
              tr ? '↺ Tekrar Dene' : '↺ Retry',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFFF6B35),
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ];
  }

  void _onTap(String target, String id) {
    AudioService.play('button_click');
    if (target == 'close') {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/menu');
      }
      return;
    }
    if (target != 'none') return;

    switch (id) {
      case 'monthly':
        if (!_offeringsLoading && _monthlyPackage != null) {
          setState(() => _selectedPackage = _monthlyPackage);
        }
      case 'yearly':
        if (!_offeringsLoading && _yearlyPackage != null) {
          setState(() => _selectedPackage = _yearlyPackage);
        }
      case 'subscribe':
        _subscribe();
      case 'restore':
        _restore();
    }
  }

  Future<void> _subscribe() async {
    if (_offeringsLoading) {
      _snack(isTurkish() ? 'Paketler yükleniyor...' : 'Loading packages...');
      return;
    }
    if (_offeringsError || _selectedPackage == null) {
      // Retry loading offerings
      await _loadOfferings();
      if (_selectedPackage == null) {
        _snack(isTurkish()
            ? 'Paket yüklenemedi — internet bağlantını kontrol et'
            : 'Could not load packages — check your connection');
      }
      return;
    }
    setState(() => _loading = true);
    final result = await PurchaseService.instance.purchasePackage(_selectedPackage!);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      _snack(isTurkish()
          ? 'VIP aktif! Reklamsız, sınırsız can ve tüm power-up\'lar açıldı'
          : 'VIP active! Ad-free, unlimited lives and all power-ups unlocked');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/categories');
        }
      }
    } else if (!result.cancelled) {
      _snack(isTurkish()
          ? 'Satın alma başarısız: ${result.error ?? 'Bilinmeyen hata'}'
          : 'Purchase failed: ${result.error ?? 'Unknown error'}');
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
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/categories');
        }
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
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
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
