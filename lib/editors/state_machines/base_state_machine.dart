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

class DragCanvasEvent {
  const DragCanvasEvent({required this.position, required this.delta});

  final Offset position;

  final Offset delta;
}

class MoveCanvasEvent {
  const MoveCanvasEvent({required this.position});

  final Offset position;
}

enum ScrollDirection { up, down }

class ScrollCanvasEvent {
  const ScrollCanvasEvent({required this.position, required this.direction});

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

  void onDrag(DragCanvasEvent event) {}

  void onMove(MoveCanvasEvent event) {}

  void onScroll(ScrollCanvasEvent info) {}

  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // print(event);
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        print("escape");
        exit();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.delete) {
        print("delete");
        delete();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.handled;
  }

  void done() {}

  void exit() {}

  void delete() {}
}
