import 'dart:async';
import 'dart:ui' as ui;

import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'editor_config.dart';
import 'state_machines/state_machines.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    // final camera = CameraComponent(
    //   //
    //   world: EditorWorld(),
    //   backdrop: Background(),
    // );

    final drawCubit = context.watch<DrawCubit>();

    return GameWidget(game: drawCubit.game);
  }
}

class Background extends CustomPainterComponent {}

class EditorGame extends StateMachineGame {
  EditorGame({super.children, super.world, super.camera});

  @override
  bool get debugMode => true;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = -camera.visibleWorldRect.center.toVector2();
    camera.viewfinder.zoom = zoomCubit.state;

    add(FpsTextComponent(position: camera.viewport.size..[0] = 0, textRenderer: TextPaint(style: TextStyle(color: Colors.black))));
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
    return super.onLoad();
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
