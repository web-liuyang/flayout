import 'dart:ui';

import '../../layouts/cubits/cubits.dart';

import 'base_graphic.dart';

class RectangleGraphic extends BaseGraphic {
  RectangleGraphic({super.position, required super.layer, required this.width, required this.height});

  double width;

  double height;

  Path path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    path = Path()..addRect(Rect.fromLTWH(position.dx + offset.dx, position.dy + offset.dy, width, height));
    final paint = layersCubit.getPaint(layer!, ctx);
    ctx.canvas.drawPath(path, paint);
  }

  @override
  bool contains(Offset position) {
    return path.contains(position);
  }

  @override
  RectangleGraphic clone() {
    return RectangleGraphic(position: position, layer: layer, width: width, height: height);
  }

  @override
  Rect aabb() => path.getBounds();
}
