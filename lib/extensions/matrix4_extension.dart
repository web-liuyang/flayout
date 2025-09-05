import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:vector_math/vector_math_64.dart';

extension Matrix4TransformExtension on Matrix4Transform {
  Float64List get storage => m.storage;

  Offset getTranslation() {
    return Offset(m.entry(0, 3), m.entry(1, 3));
  }

  double getZoom() {
    return max(m.entry(0, 0), m.entry(1, 1));
  }

  Matrix4Transform setZoom(double zoom, {Offset? origin}) {
    if (zoom <= 1 && getZoom() <= 1) {
      return this;
    } else if ((origin == null) || (origin.dx == 0.0 && origin.dy == 0.0)) {
      return Matrix4Transform.from(
        m.clone()
          ..setEntry(0, 0, zoom)
          ..setEntry(1, 1, zoom),
      );
    } else {
      return Matrix4Transform.from(
        m.clone()
          ..translate(origin.dx, origin.dy)
          ..setEntry(0, 0, zoom)
          ..setEntry(1, 1, zoom)
          ..translate(-origin.dx, -origin.dy),
      );
    }
  }

  Vector3 localToGlobal(Vector3 point) {
    final x = m[0] * point.x + m[4] * point.y + m[12];
    final y = m[1] * point.x + m[5] * point.y + m[13];
    final z = m[2] * point.z + m[6] * point.z + m[14];

    return Vector3(x, y, z);
  }

  Offset screenToPlane(Offset offset) {
    return Offset(offset.dx, -offset.dy);
  }
  // void setTranslation(double tx, double ty) {
  //   setEntry(0, 2, tx);
  //   setEntry(1, 2, ty);
  // }

  // Matrix4 toMatrix4() {
  //   final Matrix4 matrix4 = Matrix4.identity();
  //   return matrix4;
  // }
}
