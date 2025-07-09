import 'package:flutter/rendering.dart';

abstract class BaseGraphic extends CustomPainter {
  BaseGraphic();

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
