import 'dart:typed_data';
import 'dart:ui';

import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolygonGraphic extends BaseGraphic {
  PolygonGraphic({required this.vertices});

  final List<Offset> vertices;

  Rect? aabb;

  Path? path;

  Paint? _paint;

  void updatePath() {
    final path = Path();
    for (final vertex in vertices) {
      final renderVertex = vertex * kEditorUnits;
      path.lineTo(renderVertex.dx, renderVertex.dy);
    }

    this.path = path;
  }

  void updateAabb() {
    aabb = path?.getBounds();
  }

  void updatePaint() {
    _paint = kEditorPaint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (path == null) updatePath();
    if (aabb == null) updateAabb();
    if (_paint == null) updatePaint();

    canvas.drawPath(path!, _paint!);

    // final paint = kEditorPaint;
    // if (graphic.cachePath == null) {

    //   final cachePath = Path();
    //   cachePath.moveTo(vertices[0], vertices[1]);
    //   for (int i = 2; i < vertices.length; i += 2) {
    //     cachePath.lineTo(vertices[i], vertices[i + 1]);
    //   }
    //   cachePath.close();

    //   graphic.cachePath = cachePath;

    //   globalPath.addPath(cachePath, Offset.zero);
    // }

    // canvas.drawPath(graphic.cachePath!, paint);

    // canvas.drawRawPoints(PointMode.polygon, vertices, paint);
    // canvas.drawPoints(PointMode.polygon, vertices, paint);
  }
}
