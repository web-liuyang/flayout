import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../layouts/cubits/cubits.dart';
import 'state_machine_game.dart';

abstract class BaseStateMachine {
  BaseStateMachine(this.game);

  final StateMachineGame game;

  void onTap() {}

  void onTapDown(TapDownInfo info) {}

  void onTapUp(TapUpInfo info) {}

  void onTapCancel() {}

  void onSecondaryTapDown(TapDownInfo info) {
    done();
  }

  void onSecondaryTapUp(TapUpInfo info) {}

  void onSecondaryTapCancel() {}

  void onPanStart(DragStartInfo info) {}

  void onPanDown(DragDownInfo info) {}

  void onPanUpdate(DragUpdateInfo info) {}

  void onPanEnd(DragEndInfo info) {}

  void onPanCancel() {}

  void onScaleStart(ScaleStartInfo info) {}

  void onScaleUpdate(ScaleUpdateInfo info) {}

  void onScaleEnd(ScaleEndInfo info) {}

  void onMouseMove(PointerHoverInfo info) {
    final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    mouseCubit.update(position);
  }

  void onDragStart(DragStartEvent event) {}

  void onDragUpdate(DragUpdateEvent event) {}

  void onDragEnd(DragEndEvent event) {}

  void onDragCancel(DragCancelEvent event) {}

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
