import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lock_icon.dart';

// JSX custom-screens.jsx LevelCard stilinden türetildi:
//
// UNLOCKED (done state):
//   border: 2px solid rgba(0,212,255,.7)   → Color(0xB200D4FF)
//   boxShadow: 0 0 16px rgba(0,212,255,.3) + inset 0 0 16px rgba(0,212,255,.1)
//   background: linear-gradient(180deg, rgba(20,30,60,.8), rgba(10,15,40,.9))
//             → [Color(0xCC141E3C), Color(0xE60A0F28)]
//   borderRadius: 14
//
// PREMIUM (locked state, gold tonlu):
//   border: 2px solid rgba(255,215,0,.5)   → Color(0x80FFD700)
//   boxShadow: inset 0 0 12px rgba(0,0,0,.4)
//            + 0 0 14px rgba(255,215,0,.25)
//   background: linear-gradient(180deg, rgba(31,26,10,.8), rgba(15,10,0,.9))
//             → [Color(0xCC1F1A0A), Color(0xE60F0A00)]
//   borderRadius: 14
//   + LockIcon (JSX custom-screens.jsx, gold gradient)

class CategoryCard extends StatelessWidget {
  final String name;
  final String? thumbAsset;
  final bool isPremium;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.isPremium,
    required this.onTap,
    this.thumbAsset,
  });

  @override
  Widget build(BuildContext context) {
    // ── Border color ──────────────────────────────────────────
    // done:   rgba(0,212,255,.7)
    // locked: rgba(100,120,180,.3) → premium gold: rgba(255,215,0,.5)
    final borderColor = isPremium
        ? const Color(0x80FFD700)   // rgba(255,215,0,.5)
        : const Color(0xB200D4FF);  // rgba(0,212,255,.7)

    // ── Box shadows ───────────────────────────────────────────
    // done:    0 0 16px rgba(0,212,255,.3)  + inset 0 0 16px rgba(0,212,255,.1)
    // premium: inset 0 0 12px rgba(0,0,0,.4) + 0 0 14px rgba(255,215,0,.25)
    final shadows = isPremium
        ? const [
            BoxShadow(color: Color(0x66000000), blurRadius: 12),
            BoxShadow(color: Color(0x40FFD700), blurRadius: 14),
          ]
        : const [
            BoxShadow(color: Color(0x4D00D4FF), blurRadius: 16),
            BoxShadow(color: Color(0x1A00D4FF), blurRadius: 16, spreadRadius: -4),
          ];

    // ── Background gradient ───────────────────────────────────
    // done:   rgba(20,30,60,.8) → rgba(10,15,40,.9)
    // locked: rgba(20,20,40,.8) → rgba(10,10,25,.9)
    // premium (gold toned): rgba(31,26,10,.8) → rgba(15,10,0,.9)
    final bgColors = isPremium
        ? const [Color(0xCC1F1A0A), Color(0xE60F0A00)]
        : const [Color(0xCC141E3C), Color(0xE60A0F28)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
          boxShadow: shadows,
        ),
        child: Row(
          children: [
            // ── Thumbnail 80×80 ─────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: thumbAsset != null
                    ? Image.asset(
                        'assets/images/$thumbAsset',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // ── Name (Orbitron 20, weight 900, letterSpacing 2) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  name,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    // done: #fff / locked: rgba(255,255,255,.35)
                    color: isPremium
                        ? const Color(0x59FFFFFF) // rgba(255,255,255,.35)
                        : Colors.white,
                    shadows: isPremium
                        ? null
                        : const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                ),
              ),
            ),
            // ── LockIcon (premium only) ──────────────────────
            if (isPremium)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: LockIcon(size: 28),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF0A0A1A),
      child: const Icon(Icons.image_not_supported_outlined,
          color: Color(0xFF333355), size: 28),
    );
  }
}
