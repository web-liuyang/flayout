import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolylineGraphic extends BaseGraphic {
  PolylineGraphic({super.position, required this.vertices, required this.halfWidth});

  final List<Offset> vertices;

  final double halfWidth;

  @override
  void paint(Context ctx, Offset offset) {
    final vertices = this.vertices.map((e) => e + position + offset).toList();
    ctx.canvas.drawPoints(PointMode.lines, vertices, kEditorPaint);
  }

  @override
  bool contains(Offset position) {
    return false;
  }

  @override
  PolylineGraphic clone() {
    return PolylineGraphic(position: position, vertices: vertices, halfWidth: halfWidth);
  }

  @override
  Rect aabb() => Rect.fromPoints(vertices.first, vertices.last);
}
