import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/level_card.dart';
import '../services/level_progress.dart';

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
    context.go('/countdown?level=$n');
  }
}
