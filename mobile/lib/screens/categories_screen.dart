import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/level_progress.dart';
import '../services/audio_service.dart';
import '../services/token_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C1E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Arka plan: categories_bg_clean.png (AI) gelene kadar koyu gradient ──
          _Background(),
          SafeArea(
            child: Column(
              children: [
                _Header(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: GameCategory.values.length,
                    itemBuilder: (ctx, i) {
                      final cat = GameCategory.values[i];
                      return _CategoryRow(
                        category: cat,
                        onTap: () => _navigate(context, cat),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, GameCategory cat) {
    AudioService.play('button_click');
    CurrentCategory.set(cat);
    if (_isPremiumCategory(cat)) {
      context.go('/paywall');
    } else {
      context.go('/levels');
    }
  }

  bool _isPremiumCategory(GameCategory cat) {
    return cat == GameCategory.beach ||
        cat == GameCategory.fitness ||
        cat == GameCategory.ownImage;
  }
}

// ─── Arka Plan ────────────────────────────────────────────────
class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Daima görünen koyu gradient (fallback)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF080C1E), Color(0xFF0F1535), Color(0xFF080C1E)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // AI asset gelince üzerine oturur; yoksa SizedBox (hata yok)
        Image.asset(
          'assets/images/categories_bg_clean.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        // Üstten alta hafif karartma — okunabilirlik
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x88000000), Color(0x44000000)],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Başlık ───────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AudioService.play('button_click');
              context.go('/menu');
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Color(0xFF00D4FF), size: 26),
            ),
          ),
          const Spacer(),
          // Başlık
          Text(
            'KATEGORİ SEÇ',
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: Colors.white,
              shadows: const [
                Shadow(color: Color(0xFF00D4FF), blurRadius: 16),
                Shadow(color: Color(0xFF00D4FF), blurRadius: 6),
              ],
            ),
          ),
          const Spacer(),
          // Jeton bakiyesi
          ValueListenableBuilder<int>(
            valueListenable: TokenService.instance.notifier,
            builder: (_, balance, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(
                  color: const Color(0xFFFFCC00).withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '$balance',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFCC00),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kategori Satırı ──────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const _CategoryRow({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RowPlate(),
                Row(
                  children: [
                    _Thumbnail(category: category),
                    const SizedBox(width: 16),
                    Expanded(child: _CategoryLabel(category: category)),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.chevron_right,
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.8),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Satır Arka Planı ─────────────────────────────────────────
class _RowPlate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0D1B3E), Color(0xFF091228)],
        ),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
    );
  }
}

// ─── Thumbnail ────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final GameCategory category;
  const _Thumbnail({required this.category});

  @override
  Widget build(BuildContext context) {
    // ownImage için özel ikon
    if (category == GameCategory.ownImage) {
      return _iconThumb(Icons.add_photo_alternate_outlined);
    }

    final path = 'assets/images/${category.assetKey}_1.jpg';
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(13),
        bottomLeft: Radius.circular(13),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Colors.transparent],
          stops: [0.65, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Image.asset(
          path,
          width: 100,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconThumb(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }

  Widget _iconThumb(IconData icon) {
    return Container(
      width: 100,
      height: 80,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          bottomLeft: Radius.circular(13),
        ),
        color: Color(0xFF0A0E1F),
      ),
      child: Icon(icon, color: const Color(0xFF00D4FF), size: 32),
    );
  }
}

// ─── Kategori Yazısı ──────────────────────────────────────────
class _CategoryLabel extends StatelessWidget {
  final GameCategory category;
  const _CategoryLabel({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.displayName,
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.white,
            shadows: const [
              Shadow(color: Color(0x9900D4FF), blurRadius: 10),
              Shadow(color: Color(0x4400D4FF), blurRadius: 24),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '12 LEVEL',
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
