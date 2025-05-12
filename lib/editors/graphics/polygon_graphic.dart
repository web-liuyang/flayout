import 'dart:typed_data';
import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolygonGraphic extends BaseGraphic {
  PolygonGraphic({required this.vertices});

  // final List<Offset> vertices;
  final Float32List vertices;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = kEditorPaint;

    canvas.drawRawPoints(PointMode.polygon, vertices, paint);
    // canvas.drawPoints(PointMode.polygon, vertices, paint);
  }
}
