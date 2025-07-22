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

  void onPrimaryTapDown(PointerDownEvent event) {
    final position = widget.context.viewport.windowToCanvas(event.localPosition);
    widget.context.stateMachine.onPrimaryTapDown(TapDownCanvasEvent(position: position));
  }

  void onSecondaryTapDown(PointerDownEvent event) {
    final position = widget.context.viewport.windowToCanvas(event.localPosition);
    widget.context.stateMachine.onSecondaryTapDown(TapDownCanvasEvent(position: position));
  }

  void onTertiaryTapDown(PointerDownEvent event) {
    final position = widget.context.viewport.windowToCanvas(event.localPosition);
    widget.context.stateMachine.onTertiaryTapDown(TapDownCanvasEvent(position: position));
  }

  void onPan(PointerMoveEvent event) {
    final position = widget.context.viewport.windowToCanvas(event.localPosition);
    final delta = widget.context.viewport.transform.rotateOffset(event.delta);
    widget.context.stateMachine.onPan(PanCanvasEvent(position: position, delta: delta));
  }

  // MouseMovementDetector
  void onMouseMove(PointerHoverEvent info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
    widget.context.stateMachine.onMouseMove(MouseMoveCanvasEvent(position: position));
  }

  void onScroll(PointerScrollEvent info) {
    final position = widget.context.viewport.windowToCanvas(info.localPosition);
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
          child: Listener(
            onPointerMove: (event) {
              if (event.buttons == kTertiaryButton) {
                onPan(event);
              }
            },
            onPointerDown: (event) {
              if (event.buttons == kPrimaryButton) {
                onPrimaryTapDown(event);
              } else if (event.buttons == kSecondaryButton) {
                onSecondaryTapDown(event);
              } else if (event.buttons == kTertiaryButton) {
                onTertiaryTapDown(event);
              }
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                onScroll(event);
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
