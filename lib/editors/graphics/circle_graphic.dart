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

  final Path _path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer!, ctx);
    if (paint == null) return;

    _path
      ..reset()
      ..addArc(Rect.fromCircle(center: center + position + offset, radius: radius), 0, 2 * pi);

    if (ctx.viewport.canSee(aabb())) {
      ctx.canvas.drawPath(_path, paint);
    }
  }

  @override
  bool contains(Offset position) => _path.contains(position);

  @override
  CircleGraphic clone() => CircleGraphic(position: position, layer: layer, radius: radius, center: center);

  @override
  Rect aabb() => _path.getBounds();
}
