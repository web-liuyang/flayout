import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

extension OffsetExtension on Offset {
  double distanceTo(Offset offset) {
    final dx = offset.dx - this.dx;
    final dy = offset.dy - this.dy;
    return sqrt(dx * dx + dy * dy);
  }

  Vector2 toVector2() {
    return Vector2(dx, dy);
  }

  Vector3 toVector3() {
    return Vector3(dx, dy, 1);
  }
}
