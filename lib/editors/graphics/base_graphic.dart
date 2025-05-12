import 'package:flutter/rendering.dart';

abstract class BaseGraphic extends CustomPainter {
  BaseGraphic({this.position = Offset.zero, this.parent});

  Offset position;

  final BaseGraphic? parent;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
