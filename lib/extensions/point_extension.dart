import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';

extension PointExtension on Point {
  Offset toOffset() => Offset(x.toDouble(), y.toDouble());

  Vector2 toVector2() => Vector2(x.toDouble(), y.toDouble());
}

extension ListPointExtension on List<Point> {
  List<Offset> toOffsets() => map((e) => e.toOffset()).toList();

  List<Vector2> toVector2s() => map((e) => e.toVector2()).toList();
}
