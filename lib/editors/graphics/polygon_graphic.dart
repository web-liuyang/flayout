import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolygonGraphic extends BaseGraphic {
  PolygonGraphic({super.position, required super.layer, required this.vertices, this.close = false});

  final List<Offset> vertices;

  final bool close;

  Path path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    final List<Offset> vertices = this.vertices.map((e) => e + position + offset).toList();
    path = Path()..addPolygon(vertices, close);
    ctx.canvas.drawPath(path, kEditorPaint);
  }

  @override
  bool contains(Offset position) {
    return path.contains(position);
  }

  @override
  PolygonGraphic clone() {
    return PolygonGraphic(position: position, layer: layer, vertices: vertices, close: close);
  }

  @override
  Rect aabb() => path.getBounds();
}
