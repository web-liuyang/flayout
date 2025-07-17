import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:vector_math/vector_math_64.dart';

import 'base_graphic.dart';

class CircleGraphic extends BaseGraphic {
  CircleGraphic({required this.position, required this.radius});

  final Offset position;

  final double radius;

  @override
  void paint(Context ctx, Offset offset) {
    ctx.canvas.drawCircle(position, radius, kEditorPaint);
  }

  @override
  bool contains(Offset position) {
    final dx = position.dx - this.position.dx;
    final dy = position.dy - this.position.dy;
    return dx * dx + dy * dy <= radius * radius;
  }

  @override
  CircleGraphic clone() {
    return CircleGraphic(position: position, radius: radius);
  }

  Rect aabb() => Rect.fromCircle(center: position, radius: radius);
}
