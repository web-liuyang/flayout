import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class RectangleGraphic extends BaseGraphic {
  RectangleGraphic({super.position, required this.width, required this.height});

  double width;

  double height;

  Path path = Path();

  @override
  void paint(Context ctx, Offset offset) {
    path = Path()..addRect(Rect.fromLTWH(position.dx + offset.dx, position.dy + offset.dy, width, height));
    ctx.canvas.drawPath(path, kEditorPaint);
  }

  @override
  bool contains(Offset position) {
    return path.contains(position);
  }

  @override
  RectangleGraphic clone() {
    return RectangleGraphic(position: position, width: width, height: height);
  }

  @override
  Rect aabb() => path.getBounds();
}
