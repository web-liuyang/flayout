import 'dart:ui';

import 'package:flayout/editors/business_graphics/business_graphics.dart';
import 'package:flayout/editors/editor_config.dart';

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

  // GroupGraphic? cache;

  // @override
  // GroupGraphic toGraphic() {
  //   if (cache == null) {
  //     final BaseGraphic child = cell.toGraphic();
  //     final List<BaseGraphic> children = [];
  //     for (int i = 0; i < col; i++) {
  //       final double colOffset = (i) * colSpacing;
  //       for (int j = 0; j < row; j++) {
  //         final double rowOffset = (j) * rowSpacing;
  //         final Offset pos = Offset(colOffset, rowOffset);
  //         children.add(GroupGraphic(graphic: null, position: pos, children: [child]));
  //       }
  //     }

  //     cache = GroupGraphic(graphic: this, position: position, children: children);
  //   }

  //   return cache!;
  // }

  Path? path;

  Path getPath(Path cellPath) {
    final path = Path();
    for (int i = 0; i < col; i++) {
      final double colOffset = (i) * colSpacing;
      for (int j = 0; j < row; j++) {
        final double rowOffset = (j) * rowSpacing;
        final Offset pos = Offset(colOffset, rowOffset);

        path.addPath(cellPath, pos);
      }
    }

    return Path()..addPath(path, position * kEditorUnits);
  }

  @override
  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath) {
  Path collect(Collection collection) {
    final cellPath = cell.collect(collection);
    path ??= getPath(cellPath);
    return path!;
  }
}
