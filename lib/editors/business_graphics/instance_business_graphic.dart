import 'dart:ui';

import 'package:flayout/editors/business_graphics/business_graphics.dart';
import 'package:flayout/editors/editor_config.dart';
import 'package:flayout/layers/layers.dart';

class InstanceBusinessGraphic extends BaseBusinessGraphic {
  InstanceBusinessGraphic({required this.position, required this.cell, required this.vMirror, required this.magnification, required this.angle});

  final Offset position;

  final CellBusinessGraphic cell;

  final bool vMirror;

  final num magnification;

  final num angle;

  // GroupGraphic? cache;

  // @override
  // GroupGraphic toGraphic(world) {
  //   cache ??= GroupGraphic(graphic: this, position: position, children: [cell.toGraphic(world)]);
  //   return cache!;
  // }

  Path? path;

  Path getPath(Path cellPath) {
    return Path()..addPath(cellPath, position * kEditorUnits);
  }

  @override
  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath) {
  Path collect(Collection collection) {
    final cellPath = cell.collect(collection);
    path ??= getPath(cellPath);
    return path!;
  }
}
