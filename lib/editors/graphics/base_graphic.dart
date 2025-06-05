import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:flutter/rendering.dart';

abstract class BaseGraphic<T extends BaseBusinessGraphic?> extends CustomPainter {
  BaseGraphic({required this.graphic, this.position = Offset.zero});

  T graphic;

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
