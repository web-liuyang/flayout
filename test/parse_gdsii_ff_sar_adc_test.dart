import 'dart:io';

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

  test('FF_SAR_ADC.gds - raw GDSII read', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final file = File(gdsPath);
    expect(file.existsSync(), isTrue);

    final g = gdsii.readGDSII(gdsPath);

    expect(g.version, equals(3));
    expect(g.libname, equals('SAR_ADC_LEDIT_2023.2.0'));
    expect(g.cells.length, equals(357));

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

    expect(boundaryCount, equals(52177));
    expect(pathCount, equals(2510));
    expect(textCount, equals(1981));
    expect(srefCount, equals(3217));
    expect(arefCount, equals(25));
  });

  test('FF_SAR_ADC.gds - cell count and known cell names', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    expect(result.cells.length, equals(357));

    final cellNames = result.cells.map((c) => c.name).toSet();
    expect(cellNames, contains('dummy'));
    expect(cellNames, contains('SAR_ADC'));
    expect(cellNames, contains('SAR_Ctrl'));
    expect(cellNames, contains('R2RDAC8'));
    expect(cellNames, contains('Comp_Dynamic'));
    expect(cellNames, contains('MUX3'));
    expect(cellNames, contains('WSPSet_AN'));
  });

  test('FF_SAR_ADC.gds - layers are returned', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    expect(result.layers.length, equals(45));

    final layerKeys = result.layers.map((l) => '${l.layer}/${l.datatype}').toSet();
    expect(layerKeys, containsAll(['1/0', '2/0', '7/0', '90/0', '90/251', '100/0', '120/0']));
  });

  test('FF_SAR_ADC.gds - empty cell (dummy)', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final dummyCell = result.cells.firstWhere((c) => c.name == 'dummy');
    expect(dummyCell.graphic.children.length, equals(0));
  });

  test('FF_SAR_ADC.gds - cell with only boundaries', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'GR_nwell_unit_v_corner');
    expect(cell.graphic.children.length, equals(20));
    expect(cell.graphic.children.whereType<PolygonGraphic>().length, equals(20));
  });

  test('FF_SAR_ADC.gds - cell with boundaries and texts', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'AND2x2_ASAP7_75t_R');
    final children = cell.graphic.children;
    expect(children.length, equals(79));
    expect(children.whereType<PolygonGraphic>().length, greaterThan(0));
    expect(children.whereType<TextGraphic>().length, greaterThan(0));
  });

  test('FF_SAR_ADC.gds - cell with only paths', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'M1_WSP_BIT');
    final children = cell.graphic.children;
    expect(children.length, equals(9));
    expect(children.whereType<PolylineGraphic>().length, equals(9));
  });

  test('FF_SAR_ADC.gds - cell with SRefs', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'R2RDAC8_GR');
    final children = cell.graphic.children;
    final refs = children.whereType<RootRefGraphic>().toList();
    expect(refs.length, equals(33));

    final refNames = refs.map((r) => r.name).toSet();
    expect(refNames, contains('cmim_Auto_zh24egtmh9'));
    expect(refNames, contains('DAC_BIT'));
    expect(refNames, contains('DAC_BIT_Dummy'));
    expect(refNames, contains('DAC_IN'));
  });

  test('FF_SAR_ADC.gds - cell with ARefs', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'R2RDAC8');
    final groups = cell.graphic.children.whereType<GroupGraphic>().toList();
    expect(groups.length, equals(1));

    // ARef: col=7, row=3 -> 21 elements
    final group = groups.first;
    expect(group.children.length, equals(21));
    expect(group.children.whereType<RootRefGraphic>().length, equals(21));

    final firstRef = group.children.first as RootRefGraphic;
    expect(firstRef.name, equals('cmim_Auto_zh24egtmh9'));
  });

  test('FF_SAR_ADC.gds - cell with many ARefs', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'Comp_Dynamic');
    final groups = cell.graphic.children.whereType<GroupGraphic>().toList();
    expect(groups.length, equals(18));

    // Verify ARef children reference nmos_rvt or pmos_rvt cells
    for (final group in groups) {
      for (final child in group.children) {
        final ref = child as RootRefGraphic;
        expect(ref.name, anyOf(equals('nmos_rvt_Auto_y1rkur4i0a'), equals('pmos_rvt_Auto_y1rkur4i0a')));
      }
    }
  });

  test('FF_SAR_ADC.gds - top cell SAR_ADC', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'SAR_ADC');
    final children = cell.graphic.children;

    expect(children.whereType<PolygonGraphic>().length, equals(27));
    expect(children.whereType<PolylineGraphic>().length, equals(383));
    expect(children.whereType<TextGraphic>().length, equals(24));
    expect(children.whereType<RootRefGraphic>().length, equals(99));
    expect(children.whereType<GroupGraphic>().length, equals(1));
    expect(children.length, equals(534));
  });

  test('FF_SAR_ADC.gds - text element content', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final allTexts = <String>{};
    for (final cell in result.cells) {
      for (final child in cell.graphic.children) {
        if (child is TextGraphic) {
          allTexts.add(child.text);
        }
      }
    }

    // Standard cell pin labels
    expect(allTexts, contains('A'));
    expect(allTexts, contains('B'));
    expect(allTexts, contains('Y'));
    expect(allTexts, contains('VDD'));
    expect(allTexts, contains('VSS'));
  });

  test('FF_SAR_ADC.gds - SAR_Ctrl has ARef with correct structure', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final result = parseGDSII(gdsPath);

    final cell = result.cells.firstWhere((c) => c.name == 'SAR_Ctrl');
    final groups = cell.graphic.children.whereType<GroupGraphic>().toList();
    expect(groups.length, equals(5));

    // All ARef elements should be unique positions
    for (final group in groups) {
      final positions = group.children.map((c) => (c as RootRefGraphic).position).toSet();
      expect(positions.length, equals(group.children.length));
    }
  });

  test('FF_SAR_ADC.gds - path cells have correct widths', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    final raw = gdsii.readGDSII(gdsPath);
    final result = parseGDSII(gdsPath);

    // WSPSet cells are pure paths
    final pathCells = [
      'WSPSet_AN',
      'WSPSet_BIT',
      'WSPSet_DAC',
    ];

    for (final cellName in pathCells) {
      final rawCell = raw.cells.firstWhere((c) => c.name == cellName);
      final rawPaths = rawCell.srefs.whereType<PathStruct>().toList();
      final cell = result.cells.firstWhere((c) => c.name == cellName);
      final parsedPaths = cell.graphic.children.whereType<PolylineGraphic>().toList();
      expect(parsedPaths.length, equals(rawPaths.length));
      for (int i = 0; i < parsedPaths.length; i++) {
        final expectedHalfWidth = (rawPaths[i].width * kEditorUnits) / 2.0;
        expect(parsedPaths[i].halfWidth, closeTo(expectedHalfWidth, 1e-12));
      }
      for (final child in cell.graphic.children) {
        expect(child, isA<PolylineGraphic>());
        final polyline = child as PolylineGraphic;
        expect(polyline.halfWidth, greaterThan(0));
      }
    }
  });

  test('FF_SAR_ADC.gds - layersCubit is populated', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';
    parseGDSII(gdsPath);

    expect(layersCubit.layers.length, equals(45));
    expect(layersCubit.layers.map((l) => '${l.layer}/${l.datatype}'),
        containsAll(['1/0', '2/0', '7/0', '90/0']));
  });

  test('FF_SAR_ADC.gds - propattr records do not break parsing', () {
    const gdsPath = 'test/FF_SAR_ADC.gds';

    // The mere fact this parses without UnimplementedError proves
    // propattr/propvalue records are handled correctly.
    final result = parseGDSII(gdsPath);

    expect(result.cells.length, equals(357));
    expect(result.layers.length, equals(45));
  });
}
