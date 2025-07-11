import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class CircleGraphic extends BaseGraphic {
  CircleGraphic({required this.position, required this.radius});

  final Offset position;

  final double radius;

  @override
  void paint(Context ctx, Offset offset) {
    ctx.canvas.drawCircle(position, radius, kEditorPaint);
  }
}
