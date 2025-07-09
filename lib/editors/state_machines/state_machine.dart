import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'state_machines.dart';

class StateMachine extends StatelessWidget {
  StateMachine({required this.state, required this.child});

  final BaseStateMachine state;

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
    state.onTap();
  }

  void onTapDown(TapDownDetails info) {
    state.onTapDown(info);
  }

  void onTapUp(TapUpDetails info) {
    state.onTapUp(info);
  }

  void onTapCancel() {
    state.onTapCancel();
  }

  // SecondaryTapDetector
  void onSecondaryTapDown(TapDownDetails info) {
    state.onSecondaryTapDown(info);
  }

  void onSecondaryTapUp(TapUpDetails info) {
    state.onSecondaryTapUp(info);
  }

  void onSecondaryTapCancel() {
    state.onSecondaryTapCancel();
  }

  // PanDetector
  void onPanStart(DragStartDetails info) {
    state.onPanStart(info);
  }

  void onPanDown(DragDownDetails info) {
    state.onPanDown(info);
  }

  void onPanUpdate(DragUpdateDetails info) {
    state.onPanUpdate(info);
  }

  void onPanEnd(DragEndDetails info) {
    state.onPanEnd(info);
  }

  void onPanCancel() {
    state.onPanCancel();
  }

  // ScaleDetector
  void onScaleStart(ScaleStartDetails info) {
    state.onScaleStart(info);
  }

  void onScaleUpdate(ScaleUpdateDetails info) {
    print("onScaleUpdate");
    state.onScaleUpdate(info);
  }

  void onScaleEnd(ScaleEndDetails info) {
    state.onScaleEnd(info);
  }

  // MouseMovementDetector
  void onMouseMove(PointerHoverEvent info) {
    // final position = camera.viewfinder.globalToLocal(info.eventPosition.widget);
    // mouseCubit.update(position);

    state.onMouseMove(info);
  }

  void onScroll(PointerScrollEvent info) {
    state.onScroll(info);
  }

  // DragCallbacks
  // void onDragStart(DragStartEvent event) {
  //   state.onDragStart(event);
  // }

  // void onDragUpdate(DragUpdateEvent event) {
  //   state.onDragUpdate(event);
  // }

  // void onDragEnd(DragEndEvent event) {
  //   state.onDragEnd(event);
  // }

  // void onDragCancel(DragCancelEvent event) {
  //   state.onDragCancel(event);
  // }

  // KeyboardEvents
  // KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    // Set<LogicalKeyboardKey> keysPressed;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    return state.onKeyEvent(event, keysPressed);
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
