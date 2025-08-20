import 'dart:ui';

import 'package:flayout/editors/business_graphics/business_graphics.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flayout/gdsii/builder.dart';
import 'package:flayout/gdsii/gdsii.dart';
import 'package:flayout/layers/layers.dart';

class ParseGDSIIResult {
  ParseGDSIIResult({required this.cells, required this.layers});

  final List<CellBusinessGraphic> cells;

  final List<Layer> layers;
}

ParseGDSIIResult parseGDSII(String path) {
  final GDSII gdsii = readGDSII(path);

  final Map<String, CellBusinessGraphic> nameToCBG = {};
  final Map<String, Cell> nameToCell = {for (final cell in gdsii.cells) cell.name: cell};
  final Map<String, Layer> nameToLayer = {};

  final List<CellBusinessGraphic> cells = [];

  for (final Cell item in gdsii.cells) {
    cells.add(parseCell(item, nameToCBG, nameToCell, nameToLayer));
  }

  return ParseGDSIIResult(cells: cells, layers: nameToLayer.values.toList());
}

CellBusinessGraphic parseCell(
  Cell cell,
  Map<String, CellBusinessGraphic> nameToCBG,
  Map<String, Cell> nameToCell,
  Map<String, Layer> nameToLayer,
) {
  final List<BaseBusinessGraphic> children = parseStructs(cell.srefs, nameToCBG, nameToCell, nameToLayer);
  return CellBusinessGraphic(name: cell.name, children: children);
}

List<BaseBusinessGraphic> parseStructs(
  List<Struct> structs,
  Map<String, CellBusinessGraphic> nameToCBG,
  Map<String, Cell> nameToCell,
  Map<String, Layer> nameToLayer,
) {
  final List<BaseBusinessGraphic> items = [];

  for (final Struct struct in structs) {
    if (struct is TextStruct) {
      final position = struct.offset.toOffset();
      final text = struct.string;
      final layerKey = combineIdentity(struct.layer, struct.texttype);
      final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.texttype);
      items.add(TextBusinessGraphic(text: text, position: position, layer: layer));
    }

    if (struct is BoundaryStruct) {
      final vertices = struct.points.toOffsets();
      final layerKey = combineIdentity(struct.layer, struct.datatype);
      final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      items.add(BoundaryBusinessGraphic(vertices: vertices, layer: layer));
    }

    if (struct is PathStruct) {
      final vertices = struct.points.toOffsets();
      final layerKey = combineIdentity(struct.layer, struct.datatype);
      final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      final halfWidth = struct.width / 2;
      items.add(PathBusinessGraphic(vertices: vertices, layer: layer, halfWidth: halfWidth));
    }

    if (struct is SRefStruct) {
      final position = struct.offset.toOffset();
      final name = struct.name;
      final vMirror = struct.vMirror;
      final magnification = struct.magnification;
      final angle = struct.angle;

      if (!nameToCBG.containsKey(name)) {
        final Cell cell = nameToCell[name]!;
        final CellBusinessGraphic cellBusinessGraphic = parseCell(cell, nameToCBG, nameToCell, nameToLayer);
        nameToCBG[name] = cellBusinessGraphic;
      }

      final CellBusinessGraphic cellBusinessGraphic = nameToCBG[name]!;
      final ins = InstanceBusinessGraphic(
        position: position,
        cell: cellBusinessGraphic,
        vMirror: vMirror,
        magnification: magnification,
        angle: angle,
      );
      items.add(ins);
    }

    if (struct is ARefStruct) {
      final Offset position = struct.offset.toOffset();
      final String name = struct.name;
      final bool vMirror = struct.vMirror;
      final num magnification = struct.magnification;
      final num angle = struct.angle;
      final int col = struct.col;
      final int row = struct.row;
      final double colSpacing = struct.colSpacing;
      final double rowSpacing = struct.rowSpacing;

      if (!nameToCBG.containsKey(name)) {
        final Cell cell = nameToCell[name]!;
        final CellBusinessGraphic cellBusinessGraphic = parseCell(cell, nameToCBG, nameToCell, nameToLayer);
        nameToCBG[name] = cellBusinessGraphic;
      }

      final CellBusinessGraphic cellBusinessGraphic = nameToCBG[name]!;
      final arr = ArrayBusinessGraphic(
        position: position,
        cell: cellBusinessGraphic,
        vMirror: vMirror,
        magnification: magnification,
        angle: angle,
        col: col,
        row: row,
        colSpacing: colSpacing,
        rowSpacing: rowSpacing,
      );

      items.add(arr);
    }
  }

  return items;
}
