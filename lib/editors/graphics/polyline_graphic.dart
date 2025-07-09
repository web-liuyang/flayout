import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolylineGraphic extends BaseGraphic {
  PolylineGraphic({required this.vertices, required this.halfWidth});

  final List<Offset> vertices;

  final double halfWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(PointMode.lines, vertices, kEditorPaint);
  }
}
