import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolygonGraphic extends BaseGraphic {
  PolygonGraphic({required this.vertices});

  final List<Offset> vertices;

  Path? path;

  Path createPath() {
    final path = Path();
    for (final vertex in vertices) {
      // final renderVertex = vertex * kEditorUnits;
      final renderVertex = vertex;
      path.lineTo(renderVertex.dx, renderVertex.dy);
    }

    return path;
  }

  @override
  void paint(Context ctx, Offset offset) {
    ctx.canvas.drawPoints(PointMode.polygon, vertices, kEditorPaint);
  }
}
