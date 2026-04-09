import 'dart:collection';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show debugPrint;

enum CellState { empty, border, claimed, trail }

class GameGrid extends Component {
  static const int gridCols = 120;
  static const int gridRows = 90;

  final Rect bounds;
  late final double cellW;
  late final double cellH;
  final List<List<CellState>> cells;

  double flashAlpha = 0;
  final List<(int, int)> lastClaimed = [];
  int levelId = 1;

  /// Level-based overlay colors (Gals Panic style)
  // Overlay: 0xEB = 235/255 ≈ 0.92 opacity. Silhouette barely visible.
  static const _overlayColors = [
    Color(0xEB0022AA), // Level 1: Blue
    Color(0xEB6600AA), // Level 2: Purple
    Color(0xEB006633), // Level 3: Green
    Color(0xEB994400), // Level 4: Orange
    Color(0xEB990022), // Level 5: Red
  ];

  Color get overlayColor => _overlayColors[(levelId - 1) % _overlayColors.length];

  GameGrid({required this.bounds})
      : cells = List.generate(gridRows, (r) =>
            List.generate(gridCols, (c) {
              if (r == 0 || r == gridRows - 1 || c == 0 || c == gridCols - 1) {
                return CellState.border;
              }
              return CellState.empty;
            })) {
    cellW = bounds.width / gridCols;
    cellH = bounds.height / gridRows;
    debugPrint('Grid: ${gridCols}x$gridRows, Cell size: ${cellW.toStringAsFixed(1)}x${cellH.toStringAsFixed(1)} px');
  }

  CellState get(int c, int r) {
    if (c < 0 || c >= gridCols || r < 0 || r >= gridRows) return CellState.border;
    return cells[r][c];
  }

  void set(int c, int r, CellState s) {
    if (c >= 0 && c < gridCols && r >= 0 && r < gridRows) cells[r][c] = s;
  }

  Offset center(int c, int r) =>
      Offset(bounds.left + c * cellW + cellW / 2, bounds.top + r * cellH + cellH / 2);

  (int, int) toGrid(double x, double y) => (
    ((x - bounds.left) / cellW).floor().clamp(0, gridCols - 1),
    ((y - bounds.top) / cellH).floor().clamp(0, gridRows - 1),
  );

  // ---- WALKABILITY ----

  /// A cell is walkable if:
  /// - BORDER (always)
  /// - CLAIMED and on the "edge" (has at least one non-CLAIMED/non-BORDER neighbor,
  ///   OR is adjacent to BORDER)
  /// Interior claimed cells completely surrounded by claimed/border are NOT walkable.
  bool isWalkable(int c, int r) {
    final s = get(c, r);
    if (s == CellState.border) return true;
    if (s == CellState.claimed) return _isEdge(c, r);
    return false;
  }

  bool _isEdge(int c, int r) {
    // Edge = has at least one neighbor that is EMPTY or TRAIL
    for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
      final ns = get(c + dc, r + dr);
      if (ns == CellState.empty || ns == CellState.trail) return true;
    }
    // Also edge if adjacent to BORDER (so player can walk along border-claimed junction)
    for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
      final ns = get(c + dc, r + dr);
      if (ns == CellState.border) return true;
    }
    return false;
  }

  /// Is this cell EMPTY? (for enemy movement constraint)
  bool isEmpty(int c, int r) => get(c, r) == CellState.empty;

  // ---- TRAIL ----

  void clearTrail() {
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        if (cells[r][c] == CellState.trail) cells[r][c] = CellState.empty;
      }
    }
  }

  // ---- CAPTURE ----

  void capture(List<(int, int)> enemyGridPos) {
    // Count trail cells before converting
    int trailCount = 0;
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        if (cells[r][c] == CellState.trail) trailCount++;
      }
    }

    // 1. Trail → Claimed (trail becomes wall)
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        if (cells[r][c] == CellState.trail) cells[r][c] = CellState.claimed;
      }
    }

    // 2. Find all connected EMPTY regions
    final globalVisited = <int>{};
    final regions = <Set<int>>[];
    for (int r = 1; r < gridRows - 1; r++) {
      for (int c = 1; c < gridCols - 1; c++) {
        final k = r * gridCols + c;
        if (cells[r][c] == CellState.empty && !globalVisited.contains(k)) {
          final region = <int>{};
          _bfs(c, r, region);
          globalVisited.addAll(region);
          regions.add(region);
        }
      }
    }

    // DEBUG LOG
    debugPrint('=== CAPTURE ===');
    debugPrint('Trail cells: $trailCount');
    debugPrint('Regions found: ${regions.length}');
    for (int i = 0; i < regions.length; i++) {
      debugPrint('  Region $i: ${regions[i].length} cells');
    }
    debugPrint('Enemy positions: $enemyGridPos');

    // 3. Decide which region(s) to claim
    lastClaimed.clear();
    if (regions.isEmpty || regions.length <= 1) {
      debugPrint('  -> Only ${regions.length} region(s), nothing to claim beyond trail');
      flashAlpha = 1.0;
      return;
    }

    // Find which region contains the enemy
    int enemyRegionIdx = -1;
    for (final (ec, er) in enemyGridPos) {
      final ek = er * gridCols + ec;
      for (int i = 0; i < regions.length; i++) {
        if (regions[i].contains(ek)) {
          enemyRegionIdx = i;
          break;
        }
      }
      if (enemyRegionIdx >= 0) break;
    }

    debugPrint('  Enemy in region: $enemyRegionIdx');

    if (enemyRegionIdx >= 0) {
      // Enemy found in a region → KEEP that region, CLAIM all others
      for (int i = 0; i < regions.length; i++) {
        if (i == enemyRegionIdx) {
          debugPrint('  -> KEEP region $i (${regions[i].length} cells, has enemy)');
        } else {
          debugPrint('  -> CLAIM region $i (${regions[i].length} cells)');
          _claimRegion(regions[i]);
        }
      }
    } else {
      // Enemy not found in any region → keep LARGEST, claim rest
      int largestIdx = 0;
      for (int i = 1; i < regions.length; i++) {
        if (regions[i].length > regions[largestIdx].length) largestIdx = i;
      }
      for (int i = 0; i < regions.length; i++) {
        if (i == largestIdx) {
          debugPrint('  -> KEEP region $i (${regions[i].length} cells, largest, no enemy found)');
        } else {
          debugPrint('  -> CLAIM region $i (${regions[i].length} cells)');
          _claimRegion(regions[i]);
        }
      }
    }

    final pct = percent;
    debugPrint('  Total claimed: ${(pct * 100).toStringAsFixed(1)}%');
    debugPrint('=== END ===');
    flashAlpha = 1.0;
  }

  void _claimRegion(Set<int> region) {
    for (final k in region) {
      final r = k ~/ gridCols, c = k % gridCols;
      cells[r][c] = CellState.claimed;
      lastClaimed.add((c, r));
    }
  }

  void _bfs(int sc, int sr, Set<int> visited) {
    final q = Queue<int>();
    final k = sr * gridCols + sc;
    if (visited.contains(k)) return;
    q.add(k);
    visited.add(k);
    while (q.isNotEmpty) {
      final k = q.removeFirst();
      final r = k ~/ gridCols, c = k % gridCols;
      for (final (dc, dr) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
        final nc = c + dc, nr = r + dr;
        if (nc < 0 || nc >= gridCols || nr < 0 || nr >= gridRows) continue;
        final nk = nr * gridCols + nc;
        if (visited.contains(nk)) continue;
        if (cells[nr][nc] != CellState.empty) continue;
        visited.add(nk);
        q.add(nk);
      }
    }
  }

  // ---- STATS ----

  double get percent {
    int total = 0, claimed = 0;
    for (int r = 1; r < gridRows - 1; r++) {
      for (int c = 1; c < gridCols - 1; c++) {
        total++;
        if (cells[r][c] == CellState.claimed) claimed++;
      }
    }
    return total > 0 ? claimed / total : 0;
  }

  bool touchesTrail(int ec, int er) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (get(ec + dc, er + dr) == CellState.trail) return true;
      }
    }
    return false;
  }

  // ---- RENDERING: only empty overlay + flash ----

  @override
  void update(double dt) {
    super.update(dt);
    if (flashAlpha > 0) flashAlpha = (flashAlpha - dt * 2.5).clamp(0.0, 1.0);
  }

  // Pixel-snapped rects — floor start, ceil end → no gaps, slight overlap OK
  Rect _cellRect(int c, int r) {
    final x1 = (bounds.left + c * cellW).floorToDouble();
    final y1 = (bounds.top + r * cellH).floorToDouble();
    final x2 = (bounds.left + (c + 1) * cellW).ceilToDouble();
    final y2 = (bounds.top + (r + 1) * cellH).ceilToDouble();
    return Rect.fromLTRB(x1, y1, x2, y2);
  }

  Rect _cellRangeRect(int c1, int c2, int r) {
    final x1 = (bounds.left + c1 * cellW).floorToDouble();
    final y1 = (bounds.top + r * cellH).floorToDouble();
    final x2 = (bounds.left + c2 * cellW).ceilToDouble();
    final y2 = (bounds.top + (r + 1) * cellH).ceilToDouble();
    return Rect.fromLTRB(x1, y1, x2, y2);
  }

  @override
  void render(Canvas canvas) {
    // Build ONE Path for all unclaimed cells → single fill, zero gaps/lines.
    final path = Path();
    for (int r = 0; r < gridRows; r++) {
      int start = -1;
      for (int c = 0; c <= gridCols; c++) {
        final s = c < gridCols ? cells[r][c] : CellState.border;
        final needsOverlay = s == CellState.empty || s == CellState.trail;
        if (needsOverlay) {
          if (start < 0) start = c;
        } else {
          if (start >= 0) {
            path.addRect(_cellRangeRect(start, c, r));
            start = -1;
          }
        }
      }
    }
    canvas.drawPath(path, Paint()..color = overlayColor..style = PaintingStyle.fill);

    // Flash on capture
    if (flashAlpha > 0 && lastClaimed.isNotEmpty) {
      final flashPath = Path();
      for (final (c, r) in lastClaimed) {
        flashPath.addRect(_cellRect(c, r));
      }
      canvas.drawPath(flashPath,
        Paint()..color = Color.fromARGB((flashAlpha * 150).toInt(), 255, 255, 255));
    }
  }
}
