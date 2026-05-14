import 'dart:math';
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

  for (final gdsii.Cell item in g.cells) {
    cells.add(parseCell(item));
  }

  return ParseGDSIIResult(cells: cells, layers: layersCubit.layers.toList());
}

Cell parseCell(gdsii.Cell cell) {
  final List<BaseGraphic> children = parseStructs(cell.srefs);
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

List<BaseGraphic> parseStructs(List<Struct> structs) {
  final List<BaseGraphic> items = [];

  for (final Struct struct in structs) {
    if (struct is TextStruct) {
      final position = struct.offset.toOffset() * kEditorUnits;
      final text = struct.string;
      final layer = getLayer(struct.layer, struct.texttype);
      items.add(TextGraphic(text: text, position: position, layer: layer));
    }

    if (struct is BoundaryStruct) {
      final vertices = struct.points.toOffsets() * kEditorUnits;
      final layer = getLayer(struct.layer, struct.datatype);
      items.add(PolygonGraphic(vertices: vertices, layer: layer));
    }

    if (struct is PathStruct) {
      final vertices = struct.points.toOffsets() * kEditorUnits;
      final halfWidth = (struct.width * kEditorUnits) / 2.0;
      final layer = getLayer(struct.layer, struct.datatype);
      items.add(PolylineGraphic(vertices: vertices, layer: layer, halfWidth: halfWidth));
    }

    if (struct is SRefStruct) {
      final position = struct.offset.toOffset() * kEditorUnits;
      final name = struct.name;
      final vMirror = struct.vMirror;
      final magnification = struct.magnification;
      final angle = struct.angle;

      items.add(RootRefGraphic(
        position: position,
        name: name,
        vMirror: vMirror,
        magnification: magnification,
        angle: angle,
      ));
    }

    if (struct is ARefStruct) {
      final position = struct.offset.toOffset() * kEditorUnits;
      final name = struct.name;
      final vMirror = struct.vMirror;
      final magnification = struct.magnification;
      final angle = struct.angle;
      final int col = struct.col;
      final int row = struct.row;
      final double colSpacing = struct.colSpacing * kEditorUnits;
      final double rowSpacing = struct.rowSpacing * kEditorUnits;

      // GDSII ARef 变换：镜像和旋转作用于整个阵列晶格，而非单个元素
      // 预计算每个元素的世界坐标位置
      final double rad = angle * pi / 180;
      final double cosA = cos(rad);
      final double sinA = sin(rad);
      final double signY = vMirror ? -1.0 : 1.0;
      final double mag = magnification.toDouble();

      final List<BaseGraphic> arrayChildren = [];
      for (int c = 0; c < col; c++) {
        for (int r = 0; r < row; r++) {
          // 网格位置
          double dx = c * colSpacing;
          double dy = r * rowSpacing * signY; // mirror first

          // rotate around array reference point
          double rx = dx * cosA - dy * sinA;
          double ry = dx * sinA + dy * cosA;

          // scale
          rx *= mag;
          ry *= mag;

          final Offset cellOffset = position + Offset(rx, ry);
          // 变换已在 world-space 位置中体现，子元素不需要再变换
          arrayChildren.add(RootRefGraphic(
            position: cellOffset,
            name: name,
            vMirror: false,
            magnification: 1,
            angle: 0,
          ));
        }
      }
      items.add(GroupGraphic(position: Offset.zero, children: arrayChildren));
    }
  }

  return items;
}
