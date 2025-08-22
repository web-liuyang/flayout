import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flayout/editors/editor_config.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flayout/gdsii/builder.dart';
import 'package:flayout/gdsii/gdsii.dart' as gdsii;
import 'package:flayout/layouts/cubits/cells_cubit.dart';
import 'package:flayout/layouts/cubits/layers_cubit.dart';
import 'package:flutter/material.dart';

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

Color getColor() {
  final usedColors = layersCubit.layers.map((item) => item.palette.outlineColor).toSet();
  final availableColors = Colors.primaries.toSet().difference(usedColors);
  return availableColors.isEmpty ? Colors.primaries.shuffled().first : availableColors.first;
}

Layer getLayer(int layer, int datatype) {
  Layer? result = layersCubit.layers.firstWhereOrNull((item) => item.layer == layer && item.datatype == datatype);
  if (result == null) {
    final color = getColor();
    result = Layer(
      name: 'Layer $layer/$datatype',
      layer: layer,
      datatype: datatype,
      palette: LayerPalette(outlineColor: color),
    );
    layersCubit.addLayer(result);
  }

  return result;
}

List<BaseGraphic> parseStructs(
  List<Struct> structs,
  Map<String, Cell> nameToCell,
  Map<String, Layer> nameToLayer,
) {
  final List<BaseGraphic> items = [];

  for (final Struct struct in structs) {
    if (struct is TextStruct) {
      // print('TextStruct');
      final position = struct.offset.toOffset();
      final text = struct.string;
      // final layerKey = combineIdentity(struct.layer, struct.texttype);
      // final layer = nameToLayer[layerKey] ??= Layer(name: layerKey, layer: struct.layer, datatype: struct.texttype);
      final layer = getLayer(struct.layer, struct.texttype);
      // items.add(TextGraphic(text: text, position: position, layer: layer));
    }

    if (struct is BoundaryStruct) {
      // print('BoundaryStruct');
      final vertices = struct.points.toOffsets();
      // final layerKey = combineIdentity(struct.layer, struct.datatype);
      // final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      // final layer = layersCubit.current!;
      final layer = getLayer(struct.layer, struct.datatype);
      items.add(PolygonGraphic(vertices: vertices, layer: layer));
    }

    if (struct is PathStruct) {
      // print('PathStruct');
      final vertices = struct.points.toOffsets();
      // final layerKey = combineIdentity(struct.layer, struct.datatype);
      // final layer = nameToLayer[layerKey] ??= Layer(number: struct.layer, datatype: struct.datatype);
      final halfWidth = struct.width / 2;
      // final layer = layersCubit.current!;
      final layer = getLayer(struct.layer, struct.datatype);
      items.add(PolylineGraphic(vertices: vertices, layer: layer, halfWidth: halfWidth));
    }

    if (struct is SRefStruct) {
      // print("SRefStruct");
      final position = struct.offset.toOffset();
      final name = struct.name;
      final vMirror = struct.vMirror;
      final magnification = struct.magnification;
      final angle = struct.angle;

      final RootRefGraphic rootRefGraphic = RootRefGraphic(
        position: position,
        name: name,
        vMirror: vMirror,
        magnification: magnification,
        angle: angle,
      );

      items.add(rootRefGraphic);
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

String combineIdentity(int number, int datatype) {
  return "$number/$datatype";
}
