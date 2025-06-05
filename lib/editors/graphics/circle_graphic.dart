import 'dart:ui';

import 'base_graphic.dart';

class CircleGraphic extends BaseGraphic {
  CircleGraphic({required super.graphic, super.position, required this.radius});

  final double radius;
}
