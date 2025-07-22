import 'package:blueprint_master/editors/editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'state_machines.dart';

class StateMachine extends StatefulWidget {
  const StateMachine({super.key, required this.context, required this.child});

  final EditorContext context;

  final Widget child;

  @override
  State<StateMachine> createState() => _StateMachineState();
}

class _StateMachineState extends State<StateMachine> {
  final FocusNode focusNode = FocusNode(debugLabel: "StateMachine");

  @override
  void initState() {
    focusNode.requestFocus();
    // HardwareKeyboard.instance.a(focusNode);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  //   bloc: drawCubit,
  void onLoad() {
    // add(drawCubitListener);
  }

  // TapDetector
  void onTap() {
    widget.context.stateMachine.onTap();
  }

  void onTapDown(TapDownDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onTapDown(TapDownCanvasEvent(position: position));
  }

  void onTapUp(TapUpDetails info) {
    widget.context.stateMachine.onTapUp(info);
  }

  void onTapCancel() {
    widget.context.stateMachine.onTapCancel();
  }

  // SecondaryTapDetector
  void onSecondaryTapDown(TapDownDetails info) {
    widget.context.stateMachine.onSecondaryTapDown(info);
  }

  void onSecondaryTapUp(TapUpDetails info) {
    widget.context.stateMachine.onSecondaryTapUp(info);
  }

  void onSecondaryTapCancel() {
    widget.context.stateMachine.onSecondaryTapCancel();
  }

  // PanDetector
  void onPanStart(DragStartDetails info) {
    widget.context.stateMachine.onPanStart(info);
  }

  void onPanDown(DragDownDetails info) {
    widget.context.stateMachine.onPanDown(info);
  }

  void onPanUpdate(DragUpdateDetails info) {
    widget.context.stateMachine.onPanUpdate(info);
  }

  void onPanEnd(DragEndDetails info) {
    widget.context.stateMachine.onPanEnd(info);
  }

  void onPanCancel() {
    widget.context.stateMachine.onPanCancel();
  }

  // ScaleDetector
  void onScaleStart(ScaleStartDetails info) {
    widget.context.stateMachine.onScaleStart(info);
  }

  void onScaleUpdate(ScaleUpdateDetails info) {
    widget.context.stateMachine.onScaleUpdate(info);
  }

  void onScaleEnd(ScaleEndDetails info) {
    widget.context.stateMachine.onScaleEnd(info);
  }

  // MouseMovementDetector
  void onMouseMove(PointerHoverEvent info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onMouseMove(MouseMoveCanvasEvent(position: position));
  }

  void onScroll(PointerScrollEvent info) {
    widget.context.stateMachine.onScroll(info);
  }

  // DragCallbacks
  // KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
  KeyEventResult onKeyEvent(KeyEvent event) {
    // Set<LogicalKeyboardKey> keysPressed;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    return widget.context.stateMachine.onKeyEvent(event, keysPressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });
      },
      child: KeyboardListener(
        focusNode: focusNode,
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
              child: widget.child,
            ),
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
