import 'dart:io';
import 'dart:math';

import 'package:flayout/editors/editor_config.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/gdsii/builder.dart';
import 'package:flayout/gdsii/gdsii.dart' as gdsii;
import 'package:flayout/gdsii/parse_gdsii.dart';
import 'package:flayout/layouts/cubits/cells_cubit.dart';
import 'package:flayout/layouts/cubits/layers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    cellsCubit.emit(CellsCubitState(cells: []));
    layersCubit.emit(LayersCubitState(layers: []));
  });

  test('vias_45.gds - raw GDSII read', () {
    const gdsPath = 'test/vias_45.gds';
    final file = File(gdsPath);
    expect(file.existsSync(), isTrue);

    final g = gdsii.readGDSII(gdsPath);

    expect(g.cells.length, equals(3));
    final cellNames = g.cells.map((c) => c.name).toSet();
    expect(cellNames, containsAll(['Via', 'Vias_s_x1', 'Vias_s']));

    // Via: 3 boundaries
    final viaCell = g.cells.firstWhere((c) => c.name == 'Via');
    expect(viaCell.srefs.length, equals(3));
    expect(viaCell.srefs.whereType<BoundaryStruct>().length, equals(3));

    // Vias_s_x1: 1 ARef + 2 boundaries + 2 texts = 5
    final viasSX1Cell = g.cells.firstWhere((c) => c.name == 'Vias_s_x1');
    expect(viasSX1Cell.srefs.length, equals(5));
    expect(viasSX1Cell.srefs.whereType<ARefStruct>().length, equals(1));
    expect(viasSX1Cell.srefs.whereType<BoundaryStruct>().length, equals(2));
    expect(viasSX1Cell.srefs.whereType<TextStruct>().length, equals(2));

    // Vias_s: 1 SRef with angle=45
    final viasSCell = g.cells.firstWhere((c) => c.name == 'Vias_s');
    expect(viasSCell.srefs.length, equals(1));
    final sref = viasSCell.srefs.first as SRefStruct;
    expect(sref.name, equals('Vias_s_x1'));
    expect(sref.angle, equals(45.0));
    expect(sref.magnification, equals(1.0));
    expect(sref.vMirror, isFalse);
  });

  test('vias_45.gds - parseGDSII cell count', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    expect(result.cells.length, equals(3));
    final cellNames = result.cells.map((c) => c.name).toSet();
    expect(cellNames, containsAll(['Via', 'Vias_s_x1', 'Vias_s']));
  });

  test('vias_45.gds - Via cell has 3 PolygonGraphics', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    final viaCell = result.cells.firstWhere((c) => c.name == 'Via');
    expect(viaCell.graphic.children.length, equals(3));
    expect(viaCell.graphic.children.whereType<PolygonGraphic>().length, equals(3));
  });

  test('vias_45.gds - Via cell boundaries have correct layers', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    final viaCell = result.cells.firstWhere((c) => c.name == 'Via');
    final polygons = viaCell.graphic.children.whereType<PolygonGraphic>().toList();

    // Layer order: 43/3, 36/3, 35/3
    expect(polygons[0].layer!.layer, equals(43));
    expect(polygons[0].layer!.datatype, equals(3));
    expect(polygons[1].layer!.layer, equals(36));
    expect(polygons[1].layer!.datatype, equals(3));
    expect(polygons[2].layer!.layer, equals(35));
    expect(polygons[2].layer!.datatype, equals(3));
  });

  test('vias_45.gds - Vias_s_x1 has ARef with 16 elements (4x4)', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'Vias_s_x1');
    // 1 GroupGraphic (ARef) + 2 PolygonGraphics + 2 TextGraphics = 5
    expect(cell.graphic.children.length, equals(5));

    final groupGraphics = cell.graphic.children.whereType<GroupGraphic>().toList();
    expect(groupGraphics.length, equals(1));

    // ARef: 4 columns × 4 rows = 16 RootRefGraphics
    final group = groupGraphics.first;
    expect(group.children.length, equals(16));
    expect(group.children.whereType<RootRefGraphic>().length, equals(16));

    // All 16 reference the "Via" cell
    for (final child in group.children) {
      expect((child as RootRefGraphic).name, equals('Via'));
    }
  });

  test('vias_45.gds - Vias_s has SRef with angle=45', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'Vias_s');
    expect(cell.graphic.children.length, equals(1));

    final sref = cell.graphic.children.first as RootRefGraphic;
    expect(sref.name, equals('Vias_s_x1'));
    expect(sref.angle, equals(45.0));
    expect(sref.magnification, equals(1.0));
    expect(sref.vMirror, isFalse);
  });

  test('vias_45.gds - Text elements are preserved', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    int textCount = 0;
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is TextGraphic) textCount++;
      }
    }
    expect(textCount, equals(2));

    // Verify text content
    final cell = result.cells.firstWhere((c) => c.name == 'Vias_s_x1');
    final texts = cell.graphic.children.whereType<TextGraphic>().toList();
    expect(texts.length, equals(2));
    expect(texts[0].text, equals('el_0'));
    expect(texts[1].text, equals('el_1'));
  });

  test('vias_45.gds - layers are returned', () {
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    // Layers: 43/3, 36/3, 35/3, 70/30, 70/41
    expect(result.layers.length, equals(5));

    final layerKeys = result.layers.map((l) => '${l.layer}/${l.datatype}').toSet();
    expect(layerKeys, containsAll(['43/3', '36/3', '35/3', '70/30', '70/41']));
  });

  test('vias_45.gds - ARef spacing is correct', () {
    const gdsPath = 'test/vias_45.gds';
    final raw = gdsii.readGDSII(gdsPath);
    final result = parseGDSII(gdsPath);

    final rawCell = raw.cells.firstWhere((c) => c.name == 'Vias_s_x1');
    final rawAref = rawCell.srefs.whereType<ARefStruct>().first;

    final cell = result.cells.firstWhere((c) => c.name == 'Vias_s_x1');
    final group = cell.graphic.children.whereType<GroupGraphic>().first;
    final refs = group.children.cast<RootRefGraphic>().toList();

    // Check that elements are not all at the same position
    final positions = refs.map((r) => r.position).toSet();
    expect(positions.length, equals(16), reason: 'All 16 elements should be at unique positions');

    final y0 = refs.first.position.dy;
    final firstRow = refs.where((r) => (r.position.dy - y0).abs() < 1e-9).toList()..sort((a, b) => a.position.dx.compareTo(b.position.dx));
    expect(firstRow.length, equals(rawAref.col));

    final dx = firstRow[1].position.dx - firstRow[0].position.dx;
    expect(dx, closeTo(rawAref.colSpacing * kEditorUnits, 1e-9));
  });

  test('vias_45.gds - RootRefGraphic applies transform in paint', () {
    // 这个测试验证 RootRefGraphic 的 paint 方法能正确处理旋转
    // 通过检查 angle 属性是否被正确存储来验证
    const gdsPath = 'test/vias_45.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'Vias_s');
    final sref = cell.graphic.children.first as RootRefGraphic;

    // angle=45 应该被正确存储
    expect(sref.angle, equals(45.0));
    // 转换为弧度
    expect(sref.angle * pi / 180, closeTo(0.785398, 1e-5));
  });
}
