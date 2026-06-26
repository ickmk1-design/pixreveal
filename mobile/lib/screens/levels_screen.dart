import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/level_card.dart';
import '../services/level_progress.dart';
import '../services/lives_service.dart';
import '../services/ad_service.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  int _highestUnlocked = 1;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await LevelProgress.highestUnlocked();
    if (!mounted) return;
    setState(() {
      _highestUnlocked = u;
      _loaded = true;
    });
  }

  LevelState _stateFor(int n, int stars) {
    if (n < _highestUnlocked) return LevelState.done;
    if (n == _highestUnlocked) return LevelState.next;
    return LevelState.locked;
  }

  // Stars earned for completed levels (stored for now as all 3 — can be replaced with real scoring later)
  int _starsFor(int n) => n < _highestUnlocked ? 3 : 0;

  @override
  Widget build(BuildContext context) {
    final title = CurrentCategory.current.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E27), Color(0xFF1A0F2E)],
          ),
        ),
        child: SafeArea(
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Row(
                          children: [
                            // Back
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => context.go('/categories'),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.4),
                                  border: Border.all(
                                    color: const Color(0xFF00D4FF)
                                        .withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(Icons.chevron_left,
                                    color: Color(0xFF00D4FF), size: 28),
                              ),
                            ),
                            const Spacer(),
                            _buildHeader(title),
                            const Spacer(),
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1 / 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final n = i + 1;
                            final state = _stateFor(n, 0);
                            final stars = _starsFor(n);
                            return LevelCard(
                              levelNumber: n,
                              stars: stars,
                              state: state,
                              onTap: () => _onTap(n, state),
                            );
                          },
                          childCount: 12,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
          width: 2,
        ),
        color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: const Color(0xFF00D4FF),
          shadows: const [
            Shadow(color: Color(0xFF00D4FF), blurRadius: 20),
            Shadow(color: Color(0x80005078), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  void _onTap(int n, LevelState state) {
    if (state == LevelState.locked) {
      context.go('/paywall');
      return;
    }
    final ls = LivesService.instance;
    if (!ls.hasLives) {
      _showNoLivesDialog();
      return;
    }
    context.go('/countdown?level=$n');
  }

  void _showNoLivesDialog() {
    final ls = LivesService.instance;
    final regenStr = ls.nextRegenFormatted();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0E27),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
        ),
        title: const Text(
          'CAN YOK',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF00D4FF),
            fontFamily: 'PressStart2P',
            fontSize: 14,
          ),
        ),
        content: Text(
          'Sonraki can: $regenStr',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Reklam izle → +1 can
          _dialogBtn(
            label: 'REKLAM İZLE  (+1 CAN)',
            color: const Color(0xFF00D4FF),
            onTap: () async {
              Navigator.of(ctx).pop();
              await AdService.instance.showRewarded(onEarned: () async {
                await LivesService.instance.addLife();
                if (mounted) setState(() {});
              });
            },
          ),
          const SizedBox(height: 8),
          // Bekle
          _dialogBtn(
            label: 'BEKLE',
            color: const Color(0xFF555577),
            onTap: () => Navigator.of(ctx).pop(),
          ),
          const SizedBox(height: 8),
          // VIP ol
          _dialogBtn(
            label: 'VIP OL → SINIRSIIZ CAN',
            color: const Color(0xFFFF006E),
            onTap: () {
              Navigator.of(ctx).pop();
              context.go('/paywall');
            },
          ),
        ],
      ),
    );
  }

  Widget _dialogBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
          color: color.withValues(alpha: 0.15),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
