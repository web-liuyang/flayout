import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolylineGraphic extends BaseGraphic {
  PolylineGraphic({required super.graphic, super.position, required this.vertices, required this.halfWidth});

  final List<Offset> vertices;

  final double halfWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = kEditorPaint;

    canvas.drawPoints(PointMode.polygon, vertices, paint);
  }
}
