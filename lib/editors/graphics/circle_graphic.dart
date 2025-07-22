import 'dart:math';
import 'dart:ui';

import '../../layouts/cubits/cubits.dart';
import 'base_graphic.dart';

class CircleGraphic extends BaseGraphic {
  CircleGraphic({
    super.position,
    required super.layer,
    required this.center,
    required this.radius,
  });

  Offset center;

  double radius;

  Path path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    path = Path()..addArc(Rect.fromCircle(center: center + position + offset, radius: radius), 0, 2 * pi);
    final paint = layersCubit.getPaint(layer!, ctx);
    ctx.canvas.drawPath(path, paint);
  }

  @override
  bool contains(Offset position) => path.contains(position);

  @override
  CircleGraphic clone() => CircleGraphic(position: position, layer: layer, radius: radius, center: center);

  @override
  Rect aabb() => path.getBounds();
}
