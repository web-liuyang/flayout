import 'package:blueprint_master/editors/editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TapDownCanvasEvent {
  const TapDownCanvasEvent({required this.position});

  final Offset position;
}

class TapUpCanvasEvent {
  const TapUpCanvasEvent({required this.position});

  final Offset position;
}

class DragStartCanvasEvent {
  const DragStartCanvasEvent({required this.position});

  final Offset position;
}

class DragDownCanvasEvent {
  const DragDownCanvasEvent({required this.position});

  final Offset position;
}

class DragUpdateCanvasEvent {
  const DragUpdateCanvasEvent({required this.position});

  final Offset position;
}

class DragEndCanvasEvent {
  const DragEndCanvasEvent({required this.position});

  final Offset position;
}

class ScaleStartCanvasEvent {
  const ScaleStartCanvasEvent({required this.position});

  final Offset position;
}

class ScaleUpdateCanvasEvent {
  const ScaleUpdateCanvasEvent({required this.position, required this.scale, required this.delta});

  final Offset position;

  final double scale;

  final Offset delta;
}

class ScaleEndCanvasEvent {
  const ScaleEndCanvasEvent({required this.position});

  final Offset position;
}

enum ScrollDirection { up, down }

class PointerScrollCanvasEvent {
  const PointerScrollCanvasEvent({required this.position, required this.direction});

  final Offset position;

  final ScrollDirection direction;
}

class MouseMoveCanvasEvent {
  const MouseMoveCanvasEvent({required this.position});

  final Offset position;
}

abstract class BaseStateMachine {
  BaseStateMachine({required this.context});

  final EditorContext context;

  void onTap() {}

  void onTapDown(TapDownCanvasEvent event) {}

  void onTapUp(TapUpCanvasEvent info) {}

  void onTapCancel() {}

  void onSecondaryTapDown(TapDownCanvasEvent info) {}

  void onSecondaryTapUp(TapUpCanvasEvent info) {}

  void onSecondaryTapCancel() {}

  void onPanStart(DragStartCanvasEvent info) {}

  void onPanDown(DragDownCanvasEvent info) {}

  void onPanUpdate(DragUpdateCanvasEvent info) {}

  void onPanEnd(DragEndCanvasEvent info) {}

  void onPanCancel() {}

  void onScaleStart(ScaleStartCanvasEvent info) {}

  void onScaleUpdate(ScaleUpdateCanvasEvent info) {}

  void onScaleEnd(ScaleEndCanvasEvent info) {}

  void onMouseMove(MouseMoveCanvasEvent event) {
    // final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    // mouseCubit.update(position);
  }
  void onScroll(PointerScrollCanvasEvent info) {}

  // void onDragStart(DragStartEvent event) {}

  // void onDragUpdate(DragUpdateEvent event) {}

  // void onDragEnd(DragEndEvent event) {}

  // void onDragCancel(DragCancelEvent event) {}

  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        print("escape");
        exit();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.handled;
  }

  void done() {}

  void exit() {}
}
