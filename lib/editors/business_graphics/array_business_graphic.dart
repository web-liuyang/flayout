import 'dart:ui';

import 'package:blueprint_master/editors/graphics/base_graphic.dart';
import 'package:blueprint_master/editors/graphics/group_graphic.dart';

import 'base_business_graphic.dart';
import 'cell_business_graphic.dart';

class ArrayBusinessGraphic extends BaseBusinessGraphic {
  ArrayBusinessGraphic({
    required this.position,
    required this.cell,
    required this.vMirror,
    required this.magnification,
    required this.angle,
    required this.col,
    required this.colSpacing,
    required this.row,
    required this.rowSpacing,
  });

  final Offset position;

  final CellBusinessGraphic cell;

  final bool vMirror;

  final num magnification;

  final num angle;

  final int col;

  final double colSpacing;

  final int row;

  final double rowSpacing;

  @override
  BaseGraphic toGraphic(world) {
    final BaseGraphic child = cell.toGraphic(world);
    final List<BaseGraphic> children = [];
    for (int i = 0; i < col; i++) {
      final double colOffset = (i) * colSpacing;
      for (int j = 0; j < row; j++) {
        final double rowOffset = (j) * rowSpacing;
        final Offset pos = Offset(colOffset, rowOffset);
        children.add(GroupGraphic(position: pos, children: [child]));
      }
    }

    return GroupGraphic(position: position, children: children);
  }
}


      // graphics.add(groupShape);