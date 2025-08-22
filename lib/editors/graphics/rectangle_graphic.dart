import 'dart:ui';

import '../../layouts/cubits/cubits.dart';

import 'base_graphic.dart';

class RectangleGraphic extends BaseGraphic {
  RectangleGraphic({super.position, required super.layer, required this.width, required this.height});

  double width;

  double height;

  final Path _path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer!, ctx);
    if (paint == null) return;

    _path
      ..reset()
      ..addRect(Rect.fromLTWH(position.dx + offset.dx, position.dy + offset.dy, width, height));

    if (ctx.viewport.canSee(aabb())) {
      ctx.canvas.drawPath(_path, paint);
    }
  }

  @override
  bool contains(Offset position) {
    return _path.contains(position);
  }

  @override
  RectangleGraphic clone() {
    return RectangleGraphic(position: position, layer: layer, width: width, height: height);
  }

  @override
  Rect aabb() => _path.getBounds();
}
