import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

extension OffsetExtension on Offset {
  Vector2 toVector2() {
    return Vector2(dx, dy);
  }

  Vector3 toVector3() {
    return Vector3(dx, dy, 1);
  }
}
