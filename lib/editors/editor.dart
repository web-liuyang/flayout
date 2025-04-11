import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'editor_config.dart';
import 'state_machines/selection_state_machine.dart';
import 'state_machines/state_machines.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = CameraComponent(
      //
      world: EditorWorld(),
      backdrop: Background(),
    );

    return GameWidget(game: EditorGame(world: camera.world, camera: camera));
  }
}

class Background extends CustomPainterComponent {}

class EditorStateMachineGame extends FlameGame
    with TapDetector, SecondaryTapDetector, PanDetector, ScaleDetector, MouseMovementDetector, DragCallbacks, KeyboardEvents {
  EditorStateMachineGame({super.children, super.world, super.camera});

  late BaseStateMachine stateMachine = SelectionStateMachine(this);

  // TapDetector
  @override
  void onTap() {
    stateMachine.onTap();
  }

  @override
  void onTapDown(TapDownInfo info) {
    stateMachine.onTapDown(info);
  }

  @override
  void onTapUp(TapUpInfo info) {
    stateMachine.onTapUp(info);
  }

  @override
  void onTapCancel() {
    stateMachine.onTapCancel();
  }

  // SecondaryTapDetector
  @override
  void onSecondaryTapDown(TapDownInfo info) {
    stateMachine.onSecondaryTapDown(info);
  }

  @override
  void onSecondaryTapUp(TapUpInfo info) {
    stateMachine.onSecondaryTapUp(info);
  }

  @override
  void onSecondaryTapCancel() {
    stateMachine.onSecondaryTapCancel();
  }

  // PanDetector
  @override
  void onPanStart(DragStartInfo info) {
    stateMachine.onPanStart(info);
  }

  @override
  void onPanDown(DragDownInfo info) {
    stateMachine.onPanDown(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    stateMachine.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    stateMachine.onPanEnd(info);
  }

  @override
  void onPanCancel() {
    stateMachine.onPanCancel();
  }

  // ScaleDetector
  @override
  void onScaleStart(ScaleStartInfo info) {
    stateMachine.onScaleStart(info);
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    stateMachine.onScaleUpdate(info);
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    stateMachine.onScaleEnd(info);
  }

  // MouseMovementDetector
  @override
  void onMouseMove(PointerHoverInfo info) {
    stateMachine.onMouseMove(info);
  }

  // DragCallbacks
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    stateMachine.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    stateMachine.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    stateMachine.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    stateMachine.onDragCancel(event);
  }

  // KeyboardEvents
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return stateMachine.onKeyEvent(event, keysPressed);
  }
}

class EditorGame extends EditorStateMachineGame {
  EditorGame({super.children, super.world, super.camera});

  @override
  bool get debugMode => true;

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = -camera.visibleWorldRect.center.toVector2();

    add(FpsTextComponent(position: camera.viewport.size..[0] = 0, textRenderer: TextPaint(style: TextStyle(color: Colors.black))));

    return super.onLoad();
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
    final double zoom = game.camera.viewfinder.zoom;

    final double gap = switch (zoom) {
      < 1.0 => dotGap / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => dotGap / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

    final visibleWorldRect = game.camera.visibleWorldRect;

    final dots = createGridDots(visibleWorldRect, gap);

    final double strokeWidth = switch (zoom) {
      < 1.0 => dotSize / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => dotSize / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

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
    final zoom = game.camera.viewfinder.zoom;

    final double strokeWidth = switch (zoom) {
      < 1.0 => axisWidth / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => axisWidth / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

    final double length = switch (zoom) {
      < 1.0 => axisLength / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => axisLength / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

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
