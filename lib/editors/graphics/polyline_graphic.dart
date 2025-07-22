import 'dart:ui';

import '../../layouts/cubits/cubits.dart';
import 'base_graphic.dart';

class PolylineGraphic extends BaseGraphic {
  PolylineGraphic({
    super.position,
    required super.layer,
    required this.vertices,
    required this.halfWidth,
  });

  final List<Offset> vertices;

  final double halfWidth;

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    final vertices = this.vertices.map((e) => e + position + offset).toList();
    final paint = layersCubit.getPaint(layer!, ctx);
    ctx.canvas.drawPoints(PointMode.lines, vertices, paint);
  }

  @override
  bool contains(Offset position) {
    return false;
  }

  @override
  PolylineGraphic clone() {
    return PolylineGraphic(position: position, layer: layer, vertices: vertices, halfWidth: halfWidth);
  }

  @override
  Rect aabb() => Rect.fromPoints(vertices.first, vertices.last);
}
