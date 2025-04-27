import 'dart:async';
import 'dart:ui' as ui;

import 'package:blueprint_master/editors/shapes/shapes.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
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

  void paintGdsii() {
    // gdsii = readGdsii('/Users/liuyang/Desktop/store/blueprint_master/test/mmi.gds');
    // TODO
    // gdsii = readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/MZI_SYSTEM_FOR_2X2.py.gds');
    // gdsii = readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/WBBC2017_top_180531.gds');
    gdsii = readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/MZI_SYSTEM_FOR_8X8.py.gds');
    units = gdsii.units;
    // final String cellName = Utf8Codec().decode([77, 109, 105, 0]); // "Mmi";
    // final Cell cell = gdsii.cells.firstWhere((item) => item.name == cellName);
    // paintCell(cell, Vector2.zero());

    gdsii.cells.indexed.forEach((item) {
      final (int index, Cell element) = item;
      print("$index: ${element.name}");
    });

    // paintCell(gdsii.cells[287], Vector2.zero());
    // paintCell(gdsii.cells[477], Vector2.zero());
    Stopwatch stopwatch = Stopwatch()..start();
    final PositionComponent component = PositionComponent(position: Vector2.zero());
    paintCell(gdsii.cells[0], component);

    // ClipComponent clipComponent = ClipComponent.rectangle(position: Vector2.zero(), size: Vector2(2000, 1000));
    // clipComponent.add(component);
    // add(clipComponent);

    add(component);

    stopwatch.stop();
    print('init speed: ${stopwatch.elapsedMilliseconds}ms');
  }

  final Map<String, Component> shapes = {};

  final Paint _paint = BasicPalette.black.paint();

  void paintCell(Cell cell, Component parent) {
    final PositionComponent component = PositionComponent();
    parent.add(component);
    shapes[cell.name] = component;

    cell.srefs.forEach((struct) {
      // if (struct is TextStruct) {
      //   final points = struct.points;
      //   assert(points.length == 1, "Text points length must be 1");
      //   final position = points.first.toVector2() * units;
      //   final text = struct.string;
      //   final regular = TextPaint(style: TextStyle(color: _paint.color, fontSize: zoomCubit.state * 12));

      //   component.add(TextShape(text: text, position: position, textRenderer: regular));
      // }

      if (struct is BoundaryStruct) {
        final vertices = struct.points.toVector2s().map((e) => e * units).toList(growable: false);

        component.add(PolygonShape(vertices, paint: _paint));
      }

      // if (struct is PathStruct) {
      //   final vertices = struct.points.toVector2s().map((e) => e * units).toList();

      //   component.add(PolylineShape(vertices.getRange(0, 4).toList(growable: false), paint: _paint));
      // }

      if (struct is SRefStruct) {
        final cell = gdsii.cells.firstWhere((item) => item.name == struct.name);
        if (cell.srefs.isNotEmpty) {
          final shape = shapes[cell.name];
          final position = struct.points.first.toVector2();
          if (shape != null) {
            final group = PositionComponent(position: position * units);
            group.add(shape);
            component.add(group);
          } else {
            final group = PositionComponent(position: position * units);
            paintCell(cell, group);
            component.add(group);
          }
        }
      }

      if (struct is ARefStruct) {
        // print("ARefStruct");
        // final cell = gdsii.cells.firstWhere((item) => item.name == struct.name);
        // paintCell(cell, struct.points.first.toVector2() + offset);
      }
    });
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