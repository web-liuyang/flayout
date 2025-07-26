import 'package:flayout/editors/editor.dart';
import 'package:flayout/extensions/matrix4_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:flutter/services.dart';

import '../../layouts/cubits/cubits.dart';
import '../graphics/graphics.dart';
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

  Viewport get viewport => widget.context.viewport;

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void onPrimaryTapDown(TapDownCanvasEvent event) {
    widget.context.stateMachine.onPrimaryTapDown(event);
  }

  void onSecondaryTapDown(TapDownCanvasEvent event) {
    widget.context.stateMachine.onSecondaryTapDown(event);
  }

  void onTertiaryTapDown(TapDownCanvasEvent event) {
    widget.context.stateMachine.onTertiaryTapDown(event);
  }

  void onPan(PanCanvasEvent event) {
    widget.context.stateMachine.onPan(event);
  }

  void onDrag(DragCanvasEvent event) {
    widget.context.stateMachine.onDrag(event);
  }

  // MouseMovementDetector
  void onMove(MoveCanvasEvent event) {
    canvasCubit.setPosition(event.position);
    widget.context.stateMachine.onMove(event);
  }

  void onScroll(ScrollCanvasEvent event) {
    widget.context.stateMachine.onScroll(event);
  }

  // DragCallbacks
  // KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
  KeyEventResult onKeyEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    return widget.context.stateMachine.onKeyEvent(event, keysPressed);
  }

  double prevScale = 1;

  Offset position = Offset.zero;

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
        child: Listener(
          onPointerHover: (event) {
            final position = viewport.windowToCanvas(event.localPosition);
            onMove(MoveCanvasEvent(position: position));
          },
          onPointerPanZoomStart: (event) {
            position = viewport.windowToCanvas(event.localPosition);
          },
          onPointerPanZoomUpdate: (event) {
            if (event.panDelta != Offset.zero) {
              final position = viewport.windowToCanvas(event.localPosition);
              final delta = viewport.transform.screenToPlane(event.panDelta);
              onPan(PanCanvasEvent(position: position, delta: delta));
              return;
            }
            if (event.scale != 1) {
              // 缩放的位置不能改变
              // final position = viewport.windowToCanvas(event.localPosition);
              final direction = event.scale < prevScale ? ScrollDirection.down : ScrollDirection.up;
              prevScale = event.scale;
              onScroll(ScrollCanvasEvent(position: position, direction: direction));
              return;
            }
          },

          onPointerDown: (event) {
            final position = viewport.windowToCanvas(event.localPosition);
            if (event.buttons == kPrimaryButton) {
              onPrimaryTapDown(TapDownCanvasEvent(position: position));
            } else if (event.buttons == kSecondaryButton) {
              onSecondaryTapDown(TapDownCanvasEvent(position: position));
            } else if (event.buttons == kTertiaryButton) {
              onTertiaryTapDown(TapDownCanvasEvent(position: position));
            }
          },
          onPointerMove: (event) {
            final position = viewport.windowToCanvas(event.localPosition);
            final delta = viewport.transform.screenToPlane(event.delta);
            if (event.buttons == kPrimaryButton) {
              onDrag(DragCanvasEvent(position: position, delta: delta / viewport.getZoom()));
            }

            if (event.buttons == kTertiaryButton) {
              onPan(PanCanvasEvent(position: position, delta: delta));
            }
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final position = viewport.windowToCanvas(event.localPosition);
              final direction = event.scrollDelta.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
              onScroll(ScrollCanvasEvent(position: position, direction: direction));
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
