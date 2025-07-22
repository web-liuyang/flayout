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

class PanCanvasEvent {
  const PanCanvasEvent({required this.position, required this.delta});

  final Offset position;

  final Offset delta;
}

class MouseMoveCanvasEvent {
  const MouseMoveCanvasEvent({required this.position});

  final Offset position;
}

enum ScrollDirection { up, down }

class PointerScrollCanvasEvent {
  const PointerScrollCanvasEvent({required this.position, required this.direction});

  final Offset position;

  final ScrollDirection direction;
}

abstract class BaseStateMachine {
  BaseStateMachine({required this.context});

  final EditorContext context;

  void onPrimaryTapDown(TapDownCanvasEvent event) {}

  void onSecondaryTapDown(TapDownCanvasEvent event) {}

  void onTertiaryTapDown(TapDownCanvasEvent event) {}

  void onPan(PanCanvasEvent event) {}

  void onMouseMove(MouseMoveCanvasEvent event) {
    // final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    // mouseCubit.update(position);
  }

  void onScroll(PointerScrollCanvasEvent info) {}

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
