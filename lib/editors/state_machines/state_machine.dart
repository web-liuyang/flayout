import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/extensions/matrix4_extension.dart';
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
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onTapUp(TapUpCanvasEvent(position: position));
  }

  void onTapCancel() {
    widget.context.stateMachine.onTapCancel();
  }

  // SecondaryTapDetector
  void onSecondaryTapDown(TapDownDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onSecondaryTapDown(TapDownCanvasEvent(position: position));
  }

  void onSecondaryTapUp(TapUpDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onSecondaryTapUp(TapUpCanvasEvent(position: position));
  }

  void onSecondaryTapCancel() {
    widget.context.stateMachine.onSecondaryTapCancel();
  }

  // PanDetector
  void onPanStart(DragStartDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onPanStart(DragStartCanvasEvent(position: position));
  }

  void onPanDown(DragDownDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onPanDown(DragDownCanvasEvent(position: position));
  }

  void onPanUpdate(DragUpdateDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onPanUpdate(DragUpdateCanvasEvent(position: position));
  }

  void onPanEnd(DragEndDetails info) {
    // final position = widget.context.viewport.windowToCanvas(info.velocity.pixelsPerSecond);
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onPanEnd(DragEndCanvasEvent(position: position));
  }

  void onPanCancel() {
    widget.context.stateMachine.onPanCancel();
  }

  // ScaleDetector
  void onScaleStart(ScaleStartDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localFocalPoint);
    widget.context.stateMachine.onScaleStart(ScaleStartCanvasEvent(position: position));
  }

  void onScaleUpdate(ScaleUpdateDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.localFocalPoint);
    final scale = info.scale;
    final delta = widget.context.viewport.transform.rotateOffset(info.focalPointDelta);
    widget.context.stateMachine.onScaleUpdate(ScaleUpdateCanvasEvent(position: position, scale: scale, delta: delta));
  }

  void onScaleEnd(ScaleEndDetails info) {
    final position = widget.context.viewport.windowToCanvas(info.velocity.pixelsPerSecond);
    widget.context.stateMachine.onScaleEnd(ScaleEndCanvasEvent(position: position));
  }

  // MouseMovementDetector
  void onMouseMove(PointerHoverEvent info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onMouseMove(MouseMoveCanvasEvent(position: position));
  }

  void onScroll(PointerScrollEvent info) {
    final position = widget.context.viewport.windowToCanvas(info.position);
    final direction = info.scrollDelta.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
    widget.context.stateMachine.onScroll(PointerScrollCanvasEvent(position: position, direction: direction));
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
