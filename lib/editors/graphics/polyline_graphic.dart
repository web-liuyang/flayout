import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class PolylineGraphic extends BaseGraphic {
  PolylineGraphic({super.position, required this.vertices});

  final List<Offset> vertices;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = kEditorPaint;

    // canvas.drawPoints(PointMode.polygon, vertices, paint);
  }
}
