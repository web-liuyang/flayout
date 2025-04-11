import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../editors.dart';

abstract class BaseStateMachine {
  BaseStateMachine(this.game);

  final EditorStateMachineGame game;

  void onTap() {}

  void onTapDown(TapDownInfo info) {}

  void onTapUp(TapUpInfo info) {}

  void onTapCancel() {}

  void onSecondaryTapDown(TapDownInfo info) {}

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

  void onMouseMove(PointerHoverInfo info) {}

  void onDragStart(DragStartEvent event) {}

  void onDragUpdate(DragUpdateEvent event) {}

  void onDragEnd(DragEndEvent event) {}

  void onDragCancel(DragCancelEvent event) {}

  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) => KeyEventResult.handled;
}
