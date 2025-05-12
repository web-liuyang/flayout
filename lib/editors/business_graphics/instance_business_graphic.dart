import 'dart:ui';

import 'package:blueprint_master/editors/graphics/graphics.dart';

import 'base_business_graphic.dart';
import 'cell_business_graphic.dart';

class InstanceBusinessGraphic extends BaseBusinessGraphic {
  InstanceBusinessGraphic({required this.position, required this.cell, required this.vMirror, required this.magnification, required this.angle});

  final Offset position;

  final CellBusinessGraphic cell;

  final bool vMirror;

  final num magnification;

  final num angle;

  @override
  BaseGraphic toGraphic(world) {
    return GroupGraphic(position: position, children: [cell.toGraphic(world)]);
  }
}
