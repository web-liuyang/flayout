import 'package:blueprint_master/editors/editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TapDownCanvasEvent {
  const TapDownCanvasEvent({required this.position});

  final Offset position;
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

  void onTapUp(TapUpDetails info) {}

  void onTapCancel() {}

  void onSecondaryTapDown(TapDownDetails info) {
    done();
  }

  void onSecondaryTapUp(TapUpDetails info) {}

  void onSecondaryTapCancel() {}

  void onPanStart(DragStartDetails info) {}

  void onPanDown(DragDownDetails info) {}

  void onPanUpdate(DragUpdateDetails info) {}

  void onPanEnd(DragEndDetails info) {}

  void onPanCancel() {}

  void onScaleStart(ScaleStartDetails info) {}

  void onScaleUpdate(ScaleUpdateDetails info) {}

  void onScaleEnd(ScaleEndDetails info) {}

  void onMouseMove(MouseMoveCanvasEvent event) {
    // final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    // mouseCubit.update(position);
  }
  void onScroll(PointerScrollEvent info) {}

  // void onDragStart(DragStartEvent event) {}

  // void onDragUpdate(DragUpdateEvent event) {}

  // void onDragEnd(DragEndEvent event) {}

  // void onDragCancel(DragCancelEvent event) {}

  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      exit();
      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  void done() {}

  void exit() {}
}
