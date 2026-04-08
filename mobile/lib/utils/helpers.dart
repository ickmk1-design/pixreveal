import 'dart:math';
import 'package:flutter/material.dart';

double distanceBetween(Offset a, Offset b) {
  return (a - b).distance;
}

bool isPointInPolygon(Offset point, List<Offset> polygon) {
  if (polygon.length < 3) return false;
  bool inside = false;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; i++) {
    if ((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy) &&
        point.dx <
            (polygon[j].dx - polygon[i].dx) *
                    (point.dy - polygon[i].dy) /
                    (polygon[j].dy - polygon[i].dy) +
                polygon[i].dx) {
      inside = !inside;
    }
    j = i;
  }
  return inside;
}

double polygonArea(List<Offset> polygon) {
  if (polygon.length < 3) return 0;
  double area = 0;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; i++) {
    area += (polygon[j].dx + polygon[i].dx) * (polygon[j].dy - polygon[i].dy);
    j = i;
  }
  return area.abs() / 2;
}

Color lerpNeonColor(double t) {
  final colors = [
    const Color(0xFFFF00FF),
    const Color(0xFF00FFFF),
    const Color(0xFF00FF00),
    const Color(0xFFFFFF00),
  ];
  final index = (t * (colors.length - 1)).floor().clamp(0, colors.length - 2);
  final localT = (t * (colors.length - 1)) - index;
  return Color.lerp(colors[index], colors[index + 1], localT)!;
}

String formatTime(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

int randomBetween(int min, int max) {
  return min + Random().nextInt(max - min + 1);
}
