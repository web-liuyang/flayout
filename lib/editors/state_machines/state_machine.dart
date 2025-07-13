import 'package:blueprint_master/editors/editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'state_machines.dart';

class StateMachine extends StatelessWidget {
  const StateMachine({super.key, required this.context, required this.child});

  final EditorContext context;

  final Widget child;

  //   bloc: drawCubit,
  //   listenWhen: (previousState, newState) {
  //     if (previousState.runtimeType == newState.runtimeType) return false;

  //     return true;
  //   },
  //   onNewState: (state) {
  //     state = state;
  //   },
  // );

  void onLoad() {
    // add(drawCubitListener);
  }

  // TapDetector
  void onTap() {
    context.stateMachine.onTap();
  }

  void onTapDown(TapDownDetails info) {
    print(context.stateMachine);
    final position = context.viewport.windowToCanvas(info.localPosition);
    context.stateMachine.onTapDown(TapDownCanvasEvent(position: position));
  }

  void onTapUp(TapUpDetails info) {
    context.stateMachine.onTapUp(info);
  }

  void onTapCancel() {
    context.stateMachine.onTapCancel();
  }

  // SecondaryTapDetector
  void onSecondaryTapDown(TapDownDetails info) {
    context.stateMachine.onSecondaryTapDown(info);
  }

  void onSecondaryTapUp(TapUpDetails info) {
    context.stateMachine.onSecondaryTapUp(info);
  }

  void onSecondaryTapCancel() {
    context.stateMachine.onSecondaryTapCancel();
  }

  // PanDetector
  void onPanStart(DragStartDetails info) {
    context.stateMachine.onPanStart(info);
  }

  void onPanDown(DragDownDetails info) {
    context.stateMachine.onPanDown(info);
  }

  void onPanUpdate(DragUpdateDetails info) {
    context.stateMachine.onPanUpdate(info);
  }

  void onPanEnd(DragEndDetails info) {
    context.stateMachine.onPanEnd(info);
  }

  void onPanCancel() {
    context.stateMachine.onPanCancel();
  }

  // ScaleDetector
  void onScaleStart(ScaleStartDetails info) {
    context.stateMachine.onScaleStart(info);
  }

  void onScaleUpdate(ScaleUpdateDetails info) {
    context.stateMachine.onScaleUpdate(info);
  }

  void onScaleEnd(ScaleEndDetails info) {
    context.stateMachine.onScaleEnd(info);
  }

  // MouseMovementDetector
  void onMouseMove(PointerHoverEvent info) {
    final position = context.viewport.windowToCanvas(info.localPosition);
    context.stateMachine.onMouseMove(MouseMoveCanvasEvent(position: position));
  }

  void onScroll(PointerScrollEvent info) {
    context.stateMachine.onScroll(info);
  }

  // DragCallbacks
  // void onDragStart(DragStartEvent event) {
  //   context.stateMachine.onDragStart(event);
  // }

  // void onDragUpdate(DragUpdateEvent event) {
  //   context.stateMachine.onDragUpdate(event);
  // }

  // void onDragEnd(DragEndEvent event) {
  //   context.stateMachine.onDragEnd(event);
  // }

  // void onDragCancel(DragCancelEvent event) {
  //   context.stateMachine.onDragCancel(event);
  // }

  // KeyboardEvents
  // KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    // Set<LogicalKeyboardKey> keysPressed;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    return context.stateMachine.onKeyEvent(event, keysPressed);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: onKeyEvent,
      child: MouseRegion(
        onHover: onMouseMove,
        child: GestureDetector(
          onTap: onTap,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTapCancel: onTapCancel,

          // onPanDown: onPanDown,
          // onPanUpdate: onPanUpdate,
          // onPanEnd: onPanEnd,
          // onPanCancel: onPanCancel,
          onSecondaryTapDown: onSecondaryTapDown,
          onSecondaryTapUp: onSecondaryTapUp,
          onSecondaryTapCancel: onSecondaryTapCancel,

          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,

          child: Listener(
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent) return;
              onScroll(event);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

enum ScrollDirection { up, down }

extension PointerScrollEventExtension on PointerScrollEvent {
  ScrollDirection get direction => scrollDelta.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
}
