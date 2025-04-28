import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:blueprint_master/editors/shapes/shapes.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../gdsii/builder.dart';
import '../gdsii/gdsii.dart';
import 'editor_config.dart';
import 'state_machines/state_machines.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    print("Editor Builder");

    final drawCubit = context.watch<DrawCubit>();

    return GameWidget(game: drawCubit.game);
  }
}

class Background extends CustomPainterComponent {}

class EditorGame extends StateMachineGame {
  EditorGame({super.children, super.world, super.camera});

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = -camera.visibleWorldRect.center.toVector2();
    camera.viewfinder.zoom = zoomCubit.state;

    // camera.viewfinder.position = Vector2(-8200, -1000);

    add(FpsTextComponent(position: camera.viewport.size..[0] = 0, textRenderer: TextPaint(style: TextStyle(color: Colors.black))));
    print("EditorGame onLoad");
  }

  @override
  Color backgroundColor() => kEditorBackgroundColor;
}

class EditorWorld extends World with HasGameReference<EditorGame> {
  final Grid grid = Grid(dotGap: kEditorDotGap, dotSize: kEditorDotSize);

  final Axis axis = Axis(axisLength: kEditorAxisLength, axisWidth: kEditorAxisWidth);

  @override
  FutureOr<void> onLoad() {
    addAll([grid, axis]);

    paintGdsii();
    return super.onLoad();
  }

  late double units;

  late Gdsii gdsii;

  Map<String, Cell> cells = {};

  void paintGdsii() async {
    final prefix = Platform.isWindows ? r"C:\Users\xiaoyao\Desktop\ansys" : "/Users/liuyang/Desktop/xiaoyao/ansys/";

    gdsii = readGdsii('$prefix/mmi.gds');
    // gdsii = readGdsii('$prefix/MZI_SYSTEM_FOR_2X2.py.gds');
    // gdsii = readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/WBBC2017_top_180531.gds');
    gdsii = readGdsii('$prefix/MZI_SYSTEM_FOR_8X8.py.gds');
    units = gdsii.units;
    print("units: $units");

    gdsii.cells.indexed.forEach((item) {
      final (int index, Cell element) = item;
      cells[element.name] = element;
      // print("$index: ${element.name}");
    });

    final int cellCount = gdsii.cells.map((item) => item.name).toSet().length;

    Stopwatch stopwatch = Stopwatch()..start();
    final component = paintCell(gdsii.cells[0], 0);
    addAll(component);

    print("cellCount: $cellCount");
    stopwatch.stop();

    print('init speed: ${stopwatch.elapsedMilliseconds}ms');
  }

  final Map<String, List<PositionComponent>> shapes = {};

  // final Paint _paint = BasicPalette.black.paint();
  final Paint _paint =
      BasicPalette.black.paint()
        ..filterQuality = FilterQuality.low
        ..style = PaintingStyle.stroke;

  final List<PositionComponent> comps = [];

  List<PositionComponent> paintCell(Cell cell, int deep) {
    final List<PositionComponent> graphics = [];

    for (final struct in cell.srefs) {
      if (struct is TextStruct) {
        final points = struct.points;
        assert(points.length == 1, "Text points length must be 1");
        final position = points.first.toVector2() * units;
        final text = struct.string;
        final regular = TextPaint(style: TextStyle(color: _paint.color, fontSize: zoomCubit.state * 12));

        final component = (TextShape(text: text, position: position, textRenderer: regular, priority: deep));
        graphics.add(component);
      }

      if (struct is BoundaryStruct) {
        final vertices = struct.points.toVector2s().map((e) => e * units).toList(growable: false);
        final component = (PolygonShape(vertices, paint: _paint, priority: deep));
        graphics.add(component);
      }

      if (struct is PathStruct) {
        final vertices = struct.points.toVector2s().map((e) => e * units).toList();
        final component = (PolylineShape(vertices, paint: _paint, priority: deep));
        graphics.add(component);
      }

      if (struct is SRefStruct) {
        final position = struct.points.first.toVector2() * units;
        final shape = shapes[struct.name];
        if (shape != null) {
          final List<PositionComponent> children = shapes[struct.name]!;
          final GroupShape groupShape = GroupShape(position: position, children: children, priority: deep);
          graphics.add(groupShape);
        } else {
          final Cell cell = cells[struct.name]!;
          final List<PositionComponent> children = paintCell(cell, deep + 1);
          shapes[struct.name] = children;
          final GroupShape groupShape = GroupShape(position: position, children: children, priority: deep);
          graphics.add(groupShape);
        }
      }

      if (struct is ARefStruct) {
        final String cellName = struct.name;
        final shape = shapes[cellName];

        List<PositionComponent> children = [];

        if (shape != null) {
          children = shapes[cellName]!;
        } else {
          final Cell cell = cells[cellName]!;
          children = paintCell(cell, deep + 1);
          shapes[cellName] = children;
        }

        final int col = struct.col;
        final int row = struct.row;
        final List<GroupShape> repetitions = [];
        for (int i = 0; i < col; i++) {
          final double colOffset = (i) * struct.colSpacing;
          for (int j = 0; j < row; j++) {
            final double rowOffset = (j) * struct.rowSpacing;
            final Vector2 pos = Vector2(colOffset, rowOffset) * units;
            repetitions.add(GroupShape(position: pos, children: children, priority: deep + 1));
          }
        }

        final localPosition = struct.offset.toVector2() * units;
        final GroupShape groupShape = GroupShape(position: localPosition, children: repetitions, priority: deep);

        graphics.add(groupShape);
      }
    }

    return graphics;
  }
}

class Grid extends PositionComponent with HasGameReference<EditorGame> {
  Grid({required this.dotGap, required this.dotSize});

  final double dotGap;

  final double dotSize;

  final Paint _paint = Paint();

  void renderGrid(Canvas canvas) {
    final double gap = game.camera.viewfinder.getLogicSize(dotGap);
    final visibleWorldRect = game.camera.visibleWorldRect;

    final dots = createGridDots(visibleWorldRect, gap);
    final double strokeWidth = game.camera.viewfinder.getLogicSize(dotSize);

    _paint.strokeWidth = strokeWidth;
    canvas.drawPoints(ui.PointMode.points, dots, _paint);
  }

  List<Offset> createGridDots(Rect rect, double gap) {
    final topLeft = rect.topLeft;
    final bottomRight = rect.bottomRight;

    final Set<Offset> dots = {};

    final start = topLeft - (topLeft % gap) + Offset(gap, gap);
    for (double dx = start.dx; dx <= bottomRight.dx; dx += gap) {
      for (double dy = start.dy; dy <= bottomRight.dy; dy += gap) {
        dots.add(Offset(dx, dy));
      }
    }

    return dots.toList();
  }

  @override
  void render(Canvas canvas) {
    renderGrid(canvas);
    super.render(canvas);
  }
}

class Axis extends PositionComponent with HasGameReference<EditorGame> {
  Axis({required this.axisLength, required this.axisWidth});

  final double axisLength;

  final double axisWidth;

  final Paint _paint = Paint()..color = kEditorAxisColor;

  void renderAxis(Canvas canvas) {
    final double strokeWidth = game.camera.viewfinder.getLogicSize(axisWidth);
    final double length = game.camera.viewfinder.getLogicSize(axisLength);

    _paint.strokeWidth = strokeWidth;

    canvas.drawLine(Offset(-length, 0), Offset(length, 0), _paint);
    canvas.drawLine(Offset(0, -length), Offset(0, length), _paint);
  }

  @override
  void render(Canvas canvas) {
    renderAxis(canvas);
    super.render(canvas);
  }
}





// 1. 属性栏重排
// 2. 资源栏
//   2.1 搜索框 后面加个有无符号的筛选
//   2.2 PDK Design 增加搜索框
//   2.3 Symbol Parameters 无法点击添加参数

// 3. 扫描
//   3.1 添加参数后可以进行删除