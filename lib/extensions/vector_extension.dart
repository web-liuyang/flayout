import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

extension Vector3Extension on Vector3 {
  Offset toOffset() {
    return Offset(x, y);
  }
}

extension Vector2Extension on Vector2 {
  Offset toOffset() {
    return Offset(x, y);
  }
}
