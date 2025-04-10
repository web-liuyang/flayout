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

    return Container(
      //
      width: 500,
      height: 300,
      child: GameWidget(game: EditorGame(world: camera.world, camera: camera)),
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

    FpsTextComponent(position: camera.visibleWorldRect.bottomLeft.toVector2()).addToParent(this);
    return super.onLoad();
  }

  @override
  Color backgroundColor() => Color(0xffffffff);

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // print(a);

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
      zoomAtPoint(camera.viewfinder, newZoom, startPivot, worldOffset);
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
  @override
  void render(Canvas canvas) {
    renderGrid(canvas);
    renderCenterAxis(canvas);
    renderMousePosition(canvas);

    super.render(canvas);
  }

  void renderGrid(Canvas canvas) {
    final Paint paint = Paint();
    final double gap = 125;

    final visibleWorldRect = game.camera.visibleWorldRect;

    final topLeft = visibleWorldRect.topLeft;
    final bottomRight = visibleWorldRect.bottomRight;

    final start = topLeft - (topLeft % gap) + Offset(gap, gap);
    for (double dx = start.dx; dx <= bottomRight.dx; dx += gap) {
      canvas.drawLine(Offset(dx, topLeft.dy), Offset(dx, bottomRight.dy), paint);
    }

    for (double dy = start.dy; dy <= bottomRight.dy; dy += gap) {
      canvas.drawLine(Offset(topLeft.dx, dy), Offset(bottomRight.dx, dy), paint);
    }
  }

  void renderCenterAxis(Canvas canvas) {
    final paint =
        Paint()
          ..color = Color(0xffff4500)
          ..strokeWidth = 2;

    canvas.drawLine(Offset(-125, 0), Offset(125, 0), paint);
    canvas.drawLine(Offset(0, -125), Offset(0, 125), paint);
  }

  void renderMousePosition(Canvas canvas) {
    final paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle())
          ..pushStyle(ui.TextStyle(color: Color(0xffff4500)))
          ..addText(game.mousePosition.toString());

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: game.canvasSize.x));
    canvas.drawParagraph(paragraph, game.mousePosition.toOffset());
  }
}
