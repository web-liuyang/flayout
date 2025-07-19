import 'dart:math';
import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class CircleGraphic extends BaseGraphic {
  CircleGraphic({super.position, required this.center, required this.radius});

  final Offset center;

  final double radius;

  Path path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    path = Path()..addArc(Rect.fromCircle(center: center + position + offset, radius: radius), 0, 2 * pi);
    ctx.canvas.drawPath(path, kEditorPaint);
  }

  @override
  bool contains(Offset position) => path.contains(position);

  @override
  CircleGraphic clone() => CircleGraphic(position: position, radius: radius, center: center);

  @override
  Rect aabb() => path.getBounds();
}
