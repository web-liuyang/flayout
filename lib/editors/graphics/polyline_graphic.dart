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

  final Path _path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    if (this.vertices.length < 2) return;
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer!, ctx);
    if (paint == null) return;

    final vertices = this.vertices.map((e) => e + position + offset).toList();
    _path
      ..reset()
      ..moveTo(vertices.first.dx, vertices.first.dy);
    for (int i = 1; i < vertices.length; i++) {
      _path.lineTo(vertices[i].dx, vertices[i].dy);
    }

    ctx.canvas.drawPath(_path, paint);
  }

  @override
  bool contains(Offset position) {
    return _path.contains(position);
  }

  @override
  PolylineGraphic clone() {
    return PolylineGraphic(position: position, layer: layer, vertices: vertices, halfWidth: halfWidth);
  }

  @override
  Rect aabb() => _path.getBounds();
}
