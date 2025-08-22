import 'dart:ui';

import '../../layouts/cubits/cubits.dart';
import 'base_graphic.dart';

class PolygonGraphic extends BaseGraphic {
  PolygonGraphic({
    super.position,
    required super.layer,
    required this.vertices,
    this.close = false,
  });

  final List<Offset> vertices;

  final bool close;

  final Path _path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer!, ctx);
    if (paint == null) return;

    final List<Offset> vertices = this.vertices.map((e) => e + position + offset).toList();
    _path
      ..reset()
      ..addPolygon(vertices, close);

    if (ctx.viewport.canSee(aabb())) {
      ctx.canvas.drawPath(_path, paint);
    }
  }

  @override
  bool contains(Offset position) {
    return _path.contains(position);
  }

  @override
  PolygonGraphic clone() {
    return PolygonGraphic(position: position, layer: layer, vertices: vertices, close: close);
  }

  @override
  Rect aabb() => _path.getBounds();
}
