import 'dart:math';
import 'dart:ui';

extension PointExtension on Point {
  Offset toOffset() {
    return Offset(x.toDouble(), y.toDouble());
  }

  Offset operator /(num other) {
    return Offset(x / other, y / other);
  }
}

extension ListPointExtension on List<Point> {
  List<Offset> toOffsets() {
    return map((e) => e.toOffset()).toList();
  }
}
