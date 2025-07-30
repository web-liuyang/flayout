import 'dart:math';

import 'package:flayout/commands/commands.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../layouts/cubits/cubits.dart';
import 'state_machines.dart';

class RectangleStateMachine extends BaseStateMachine {
  RectangleStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitState(context: context, state: this);

  late final _RectangleGraphicDraft _draft = _RectangleGraphicDraft();

  @override
  void onPrimaryTapDown(event) {
    super.onPrimaryTapDown(event);
    _state.onPrimaryTapDown(event);
  }

  @override
  void onSecondaryTapDown(event) {
    super.onSecondaryTapDown(event);
    _state.onSecondaryTapDown(event);
  }

  @override
  void onMove(event) {
    super.onMove(event);
    _state.onMove(event);
  }

  @override
  void onPan(PanCanvasEvent event) {
    super.onPan(event);
    context.viewport.translate(event.delta);
    context.render();
  }

  @override
  void onZoom(event) {
    super.onZoom(event);
    final zoomFn = switch (event.direction) {
      ZoomDirection.zoomIn => context.viewport.zoomIn,
      ZoomDirection.zoomOut => context.viewport.zoomOut,
    };

    zoomFn(event.position);
    context.render();
  }

  @override
  void done() {
    super.done();
    _state = _DrawInitState(context: context, state: this);
    context.graphic.children.remove(_draft);
    context.render();
    Actions.invoke(context.buildContext, AddGraphicIntent(context, [_draft.toGraphic()]));

    _draft.reset();
  }

  @override
  void exit() {
    super.exit();
    _state = _DrawInitState(context: context, state: this);
    final result = context.graphic.children.remove(_draft);
    context.render();
    if (!result) context.stateMachineNotifier.value = SelectionStateMachine(context: context);

    _draft.reset();
  }
}

class _DrawInitState extends BaseStateMachine {
  _DrawInitState({required super.context, required this.state});

  final RectangleStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    state._draft.start = event.position;
    context.graphic.children.add(state._draft);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final RectangleStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    state.done();
  }

  @override
  void onSecondaryTapDown(event) {
    state.done();
  }

  @override
  void onMove(event) {
    super.onMove(event);
    final isShift =
        HardwareKeyboard.instance.logicalKeysPressed
            .intersection(
              LogicalKeyboardKey.expandSynonyms({LogicalKeyboardKey.shift}),
            )
            .isNotEmpty;

    if (isShift) {
      final dx = event.position.dx - state._draft.start!.dx;
      final dy = event.position.dy - state._draft.start!.dy;
      final size = min(dx.abs(), dy.abs());
      final end = Offset(state._draft.start!.dx + size * dx.sign, state._draft.start!.dy + size * dy.sign);
      state._draft.end = end;
    } else {
      state._draft.end = event.position;
    }

    context.render();
  }
}

class _RectangleGraphicDraft extends BaseGraphic {
  _RectangleGraphicDraft();

  Offset? start;

  Offset? end;

  Rect? get rect => start != null && end != null ? Rect.fromPoints(start!, end!) : null;

  void reset() {
    start = null;
    end = null;
  }

  @override
  void paint(Context context, Offset offset) {
    if (start == null || end == null) return;
    final layer = context.context.currentLayer;
    if (layer == null) return;

    final paint = layersCubit.getPaint(layer, context);

    final Rect rect = Rect.fromPoints(start!, end!);
    context.canvas.drawRect(rect, paint);
  }

  RectangleGraphic toGraphic() {
    final rect = this.rect!;
    return RectangleGraphic(
      layer: layersCubit.current!,
      position: rect.topLeft,
      width: rect.width,
      height: rect.height,
    );
  }

  @override
  bool contains(Offset position) => false;

  @override
  BaseGraphic clone() {
    return _RectangleGraphicDraft()
      ..layer = layer
      ..position = position
      ..start = start
      ..end = end;
  }

  @override
  Rect aabb() => Rect.fromPoints(start!, end!);
}
