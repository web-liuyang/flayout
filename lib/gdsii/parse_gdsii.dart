import 'dart:ui';

import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flayout/gdsii/builder.dart';
import 'package:flayout/gdsii/gdsii.dart' as gdsii;
import 'package:flayout/layouts/cubits/cells_cubit.dart';
import 'package:flayout/layouts/cubits/layers_cubit.dart';

class ParseGDSIIResult {
  ParseGDSIIResult({required this.cells, required this.layers});

  final List<Cell> cells;

  final List<Layer> layers;
}

ParseGDSIIResult parseGDSII(String path) {
  final gdsii.GDSII g = gdsii.readGDSII(path);

  final List<Cell> cells = [];

  // final Map<String, CellBusinessGraphic> nameToCBG = {};
  // final Map<String, Cell> nameToCell = {for (final cell in gdsii.cells) cell.name: cell};
  // final Map<String, Layer> nameToLayer = {};
  final Map<String, Cell> nameToCell = {
    for (final cell in g.cells) cell.name: Cell(name: cell.name, graphic: RootGraphic(name: cell.name, children: [])),
  };
  final Map<String, Layer> nameToLayer = {};

  for (final gdsii.Cell item in g.cells) {
    // item.
    cells.add(parseCell(item, nameToCell, nameToLayer));
  }

  return ParseGDSIIResult(cells: cells, layers: []);
}

Cell parseCell(
  gdsii.Cell cell,
  Map<String, Cell> nameToCell,
  Map<String, Layer> nameToLayer,
) {
  final List<BaseGraphic> children = parseStructs(cell.srefs, nameToCell, nameToLayer);
  return Cell(name: cell.name, graphic: RootGraphic(name: cell.name, children: children));
}

List<BaseGraphic> parseStructs(
  List<Struct> structs,
  Map<String, Cell> nameToCell,
  Map<String, Layer> nameToLayer,
) {
  final List<BaseGraphic> items = [];

  for (final Struct struct in structs) {
    if (struct is TextStruct) {
      final position = struct.offset.toOffset();
      final text = struct.string;
      // final layerKey = combineIdentity(struct.layer, struct.texttype);
      // final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.texttype);
      final layer = layersCubit.current!;
      items.add(TextGraphic(text: text, position: position, layer: layer));
    }

    if (struct is BoundaryStruct) {
      final vertices = struct.points.toOffsets();
      // final layerKey = combineIdentity(struct.layer, struct.datatype);
      // final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      final layer = layersCubit.current!;
      items.add(PolygonGraphic(vertices: vertices, layer: layer));
    }

    if (struct is PathStruct) {
      final vertices = struct.points.toOffsets();
      // final layerKey = combineIdentity(struct.layer, struct.datatype);
      // final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      final halfWidth = struct.width / 2;
      final layer = layersCubit.current!;
      items.add(PolylineGraphic(vertices: vertices, layer: layer, halfWidth: halfWidth));
    }

    if (struct is SRefStruct) {
      print("SRefStruct");
      final position = struct.offset.toOffset();
      final name = struct.name;
      final vMirror = struct.vMirror;
      final magnification = struct.magnification;
      final angle = struct.angle;

      if (!nameToCell.containsKey(name)) {
        final Cell cell = nameToCell[name]!;
        // final CellBusinessGraphic cellBusinessGraphic = parseCell(cell, nameToCell, nameToLayer);
        // nameToCBG[name] = cellBusinessGraphic;
        // final Cell cell_ = parseCell(cell, nameToCell, nameToLayer);
        // nameToCBG[name] = cellBusinessGraphic;
      }

      final Cell cell = nameToCell[name]!;
      // final ins = InstanceBusinessGraphic(
      //   position: position,
      //   cell: cellBusinessGraphic,
      //   vMirror: vMirror,
      //   magnification: magnification,
      //   angle: angle,
      // );
      // items.add(cell.graphic);
    }

    if (struct is ARefStruct) {
      print("ARefStruct");
      // final Offset position = struct.offset.toOffset();
      // final String name = struct.name;
      // final bool vMirror = struct.vMirror;
      // final num magnification = struct.magnification;
      // final num angle = struct.angle;
      // final int col = struct.col;
      // final int row = struct.row;
      // final double colSpacing = struct.colSpacing;
      // final double rowSpacing = struct.rowSpacing;

      // if (!nameToCBG.containsKey(name)) {
      //   final Cell cell = nameToCell[name]!;
      //   final CellBusinessGraphic cellBusinessGraphic = parseCell(cell, nameToCBG, nameToCell, nameToLayer);
      //   nameToCBG[name] = cellBusinessGraphic;
      // }

      // final CellBusinessGraphic cellBusinessGraphic = nameToCBG[name]!;
      // final arr = ArrayBusinessGraphic(
      //   position: position,
      //   cell: cellBusinessGraphic,
      //   vMirror: vMirror,
      //   magnification: magnification,
      //   angle: angle,
      //   col: col,
      //   row: row,
      //   colSpacing: colSpacing,
      //   rowSpacing: rowSpacing,
      // );

      // items.add(arr);
    }
  }

  return items;
}
