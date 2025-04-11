import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = CameraComponent(
      //
      world: EditorWorld(),
      backdrop: Background(),
    );

    return Center(
      child: Container(constraints: BoxConstraints.loose(Size.square(500)), child: GameWidget(game: EditorGame(world: camera.world, camera: camera))),
    );
  }
}

class Background extends CustomPainterComponent {}

class EditorGame extends FlameGame with PanDetector, ScaleDetector, KeyboardEvents, PointerMoveCallbacks {
  EditorGame({super.children, super.world, super.camera});

  @override
  bool get debugMode => true;

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = -camera.visibleWorldRect.center.toVector2();

    add(FpsTextComponent(position: camera.viewport.size..[0] = 0));

    return super.onLoad();
  }

  @override
  Color backgroundColor() => Color(0xffffffff);

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
  }

  late double startZoom;
  late Vector2 startPivot;

  @override
  void onScaleStart(ScaleStartInfo info) {
    startPivot = camera.globalToLocal(info.eventPosition.widget);
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scaleFactor = info.scale.global;
    if (!scaleFactor.isIdentity()) {
      final worldOffset = info.eventPosition.widget;
      final newZoom = startZoom * scaleFactor.x;

      zoomAtPoint(camera.viewfinder, newZoom.clamp(0.1, 10), startPivot, worldOffset);
    } else {
      throw RangeError("scaleFactor: $scaleFactor");
    }
  }

  // pivot 是鼠标在 canvas 画布中的位置
  // offset 是鼠标在 canvas 组件上的位置
  void zoomAtPoint(Viewfinder viewfinder, double newZoom, Vector2 pivot, Vector2 offset) {
    final newPosition = pivot - (offset / newZoom);
    viewfinder.zoom = newZoom;
    viewfinder.position = newPosition;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // print("onKeyEvent");
    // print(keysPressed);
    if (event is KeyDownEvent && keysPressed.containsAll(LogicalKeyboardKey.meta.synonyms)) {
      if (event.logicalKey == LogicalKeyboardKey.equal) {
        print("ADD");
      }

      if (event.logicalKey == LogicalKeyboardKey.minus) {
        print("SUB");
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  Vector2 mousePosition = Vector2.zero();

  @override
  void onPointerMove(event) async {
    mousePosition = camera.globalToLocal(event.canvasPosition);
    super.onPointerMove(event);
  }
}

class EditorWorld extends World with HasGameReference<EditorGame> {
  final Grid grid = Grid(gap: 20, dotSize: 1);
  final Axis axis = Axis(axisLength: 40, axisWidth: 1);

  @override
  FutureOr<void> onLoad() {
    addAll([grid, axis]);
    return super.onLoad();
  }

  // void renderMousePosition(Canvas canvas) {
  //   final paragraphBuilder =
  //       ui.ParagraphBuilder(ui.ParagraphStyle())
  //         ..pushStyle(ui.TextStyle(color: Color(0xffff4500)))
  //         ..addText(game.mousePosition.toString());

  //   final paragraph = paragraphBuilder.build();
  //   paragraph.layout(ui.ParagraphConstraints(width: game.canvasSize.x));
  //   canvas.drawParagraph(paragraph, game.mousePosition.toOffset());
  // }
}

class Grid extends PositionComponent with HasGameReference<EditorGame> {
  Grid({required this.gap, required this.dotSize});

  final double gap;

  final double dotSize;

  final Paint _paint = Paint();

  void renderGrid(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;

    final double gap = switch (zoom) {
      < 1.0 => this.gap / ((zoom * 10).floorToDouble() / 10),
      >= 1.0 => this.gap / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

    final visibleWorldRect = game.camera.visibleWorldRect;

    final dots = createGridDots(visibleWorldRect, gap);

    final double strokeWidth = switch (zoom) {
      < 1.0 => dotSize / ((zoom * 10).floorToDouble() / 10),
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

  final Paint _paint = Paint()..color = Color(0xffff4500);

  void renderAxis(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;

    final double strokeWidth = switch (zoom) {
      < 1.0 => axisWidth / ((zoom * 10).floorToDouble() / 10),
      >= 1.0 => axisWidth / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };

    final double length = switch (zoom) {
      < 1.0 => axisLength / ((zoom * 10).floorToDouble() / 10),
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
