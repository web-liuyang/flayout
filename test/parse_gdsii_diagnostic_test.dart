import 'dart:io';

import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/gdsii/builder.dart';
import 'package:flayout/gdsii/gdsii.dart' as gdsii;
import 'package:flayout/gdsii/parse_gdsii.dart';
import 'package:flayout/layouts/cubits/cells_cubit.dart';
import 'package:flayout/layouts/cubits/layers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // 重置 cubits 为干净状态
    cellsCubit.emit(CellsCubitState(cells: []));
    layersCubit.emit(LayersCubitState(layers: []));
  });

  test('parseGDSII: mmi.gds - raw GDSII read', () {
    const gdsPath = 'test/mmi.gds';
    final file = File(gdsPath);
    expect(file.existsSync(), isTrue);

    final g = gdsii.readGDSII(gdsPath);

    expect(g.cells.length, equals(7));
    expect(g.libname, equals('library'));

    // 统计各类型 struct
    int boundaryCount = 0, pathCount = 0, textCount = 0, srefCount = 0, arefCount = 0;
    for (final cell in g.cells) {
      for (final sref in cell.srefs) {
        if (sref is BoundaryStruct) boundaryCount++;
        if (sref is PathStruct) pathCount++;
        if (sref is TextStruct) textCount++;
        if (sref is SRefStruct) srefCount++;
        if (sref is ARefStruct) arefCount++;
      }
    }

    expect(boundaryCount, equals(21));
    expect(pathCount, equals(0));
    expect(textCount, equals(15));
    expect(srefCount, equals(7));
    expect(arefCount, equals(0));
  });

  test('parseGDSII: mmi.gds - cell count and structure', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    // Cell 数量
    expect(result.cells.length, equals(7));

    // 验证已知 cell 名称
    final cellNames = result.cells.map((c) => c.name).toSet();
    expect(cellNames, containsAll(['Straight', 'TaperLinear', 'wg', 'wg_x1', 'wg_x2', 'TaperLinear_x1', 'Mmi']));
  });

  test('parseGDSII: mmi.gds - layers are returned', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    // layers 不再为空
    expect(result.layers.length, equals(4));

    final layerKeys = result.layers.map((l) => '${l.layer}/${l.datatype}').toSet();
    expect(layerKeys, containsAll(['70/41', '70/31', '1/1', '1/2']));
  });

  test('parseGDSII: mmi.gds - Text elements are NOT dropped', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    // 统计所有 TextGraphic
    int textGraphicCount = 0;
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is TextGraphic) textGraphicCount++;
      }
    }

    // 应该有 15 个 Text 元素（与原始 GDSII 一致）
    expect(textGraphicCount, equals(15));
  });

  test('parseGDSII: mmi.gds - Boundary elements', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    int polygonCount = 0;
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is PolygonGraphic) polygonCount++;
      }
    }

    expect(polygonCount, equals(21));
  });

  test('parseGDSII: mmi.gds - SRef elements are RootRefGraphic', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    int rootRefCount = 0;
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is RootRefGraphic) rootRefCount++;
      }
    }

    expect(rootRefCount, equals(7));
  });

  test('parseGDSII: mmi.gds - Mmi cell has correct children', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    final mmiCell = result.cells.firstWhere((c) => c.name == 'Mmi');
    final children = mmiCell.graphic.children;

    // Mmi: 4 SRefs + 3 Texts + 3 Boundaries = 10 children
    expect(children.length, equals(10));

    final srefCount = children.whereType<RootRefGraphic>().length;
    final textCount = children.whereType<TextGraphic>().length;
    final boundaryCount = children.whereType<PolygonGraphic>().length;

    expect(srefCount, equals(4));
    expect(textCount, equals(3));
    expect(boundaryCount, equals(3));
  });

  test('parseGDSII: mmi.gds - Straight cell children types', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    final straightCell = result.cells.firstWhere((c) => c.name == 'Straight');
    final children = straightCell.graphic.children;

    // Straight: 1 SRef + 2 Texts + 2 Boundaries = 5 children
    expect(children.length, equals(5));
    expect(children.whereType<RootRefGraphic>().length, equals(1));
    expect(children.whereType<TextGraphic>().length, equals(2));
    expect(children.whereType<PolygonGraphic>().length, equals(2));
  });

  test('parseGDSII: mmi.gds - Text content is preserved', () {
    const gdsPath = 'test/mmi.gds';
    final result = parseGDSII(gdsPath);

    final allTexts = <String>[];
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is TextGraphic) {
          allTexts.add(child.text);
        }
      }
    }

    // 验证特定文本标签存在
    expect(allTexts, contains('op_0'));
    expect(allTexts, contains('op_1'));
  });

  test('parseGDSII: mmi.gds - layersCubit is populated', () {
    const gdsPath = 'test/mmi.gds';
    parseGDSII(gdsPath);

    // layersCubit 应该被 getLayer() 填充
    expect(layersCubit.layers.length, equals(4));
    expect(layersCubit.layers.map((l) => '${l.layer}/${l.datatype}'),
        containsAll(['70/41', '70/31', '1/1', '1/2']));
  });
}
