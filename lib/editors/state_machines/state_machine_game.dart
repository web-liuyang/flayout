import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../../layouts/cubits/cubits.dart';
import 'state_machines.dart';

class StateMachineGame extends FlameGame
    with TapDetector, SecondaryTapDetector, PanDetector, ScaleDetector, MouseMovementDetector, ScrollDetector, DragCallbacks, KeyboardEvents {
  StateMachineGame({super.children, super.world, super.camera});

  late BaseStateMachine stateMachine = SelectionStateMachine(this);

  late final drawCubitListener = FlameBlocListener<DrawCubit, BaseStateMachine>(
    bloc: drawCubit,
    listenWhen: (previousState, newState) {
      if (previousState.runtimeType == newState.runtimeType) return false;

      return true;
    },
    onNewState: (state) {
      stateMachine = state;
    },
  );

  @override
  void onLoad() {
    super.onLoad();
    add(drawCubitListener);
  }

  // TapDetector
  @override
  void onTap() {
    super.onTap();
    stateMachine.onTap();
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    stateMachine.onTapDown(info);
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    stateMachine.onTapUp(info);
  }

  @override
  void onTapCancel() {
    super.onTapCancel();
    stateMachine.onTapCancel();
  }

  // SecondaryTapDetector
  @override
  void onSecondaryTapDown(TapDownInfo info) {
    super.onSecondaryTapDown(info);
    stateMachine.onSecondaryTapDown(info);
  }

  @override
  void onSecondaryTapUp(TapUpInfo info) {
    super.onSecondaryTapUp(info);
    stateMachine.onSecondaryTapUp(info);
  }

  @override
  void onSecondaryTapCancel() {
    super.onSecondaryTapCancel();
    stateMachine.onSecondaryTapCancel();
  }

  // PanDetector
  @override
  void onPanStart(DragStartInfo info) {
    super.onPanStart(info);
    stateMachine.onPanStart(info);
  }

  @override
  void onPanDown(DragDownInfo info) {
    super.onPanDown(info);
    stateMachine.onPanDown(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    stateMachine.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    stateMachine.onPanEnd(info);
  }

  @override
  void onPanCancel() {
    super.onPanCancel();
    stateMachine.onPanCancel();
  }

  // ScaleDetector
  @override
  void onScaleStart(ScaleStartInfo info) {
    super.onScaleStart(info);
    stateMachine.onScaleStart(info);
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    super.onScaleUpdate(info);
    stateMachine.onScaleUpdate(info);
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    super.onScaleEnd(info);
    stateMachine.onScaleEnd(info);
  }

  // MouseMovementDetector
  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);

    final position = camera.viewfinder.globalToLocal(info.eventPosition.widget);
    mouseCubit.update(position);

    stateMachine.onMouseMove(info);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    stateMachine.onScroll(info);
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
