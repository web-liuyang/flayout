import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:flutter/rendering.dart';

abstract class BaseGraphic extends CustomPainter {
  BaseGraphic({this.position = Offset.zero});

  Offset position;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Path getPath() {
    return Path();
  }
}
