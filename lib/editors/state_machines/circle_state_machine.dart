import 'package:flayout/commands/commands.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:flutter/material.dart';

import 'state_machines.dart';

class CircleStateMachine extends BaseStateMachine {
  CircleStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitState(context: context, state: this);

  late final _CircleGraphicDraft _draft = _CircleGraphicDraft();

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

  final CircleStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    super.onPrimaryTapDown(event);
    state._draft.center = event.position;
    context.graphic.children.add(state._draft);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final CircleStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    super.onPrimaryTapDown(event);
    state.done();
  }

  @override
  void onSecondaryTapDown(event) {
    super.onSecondaryTapDown(event);
    state.done();
  }

  @override
  void onMove(event) {
    super.onMove(event);
    state._draft.radius = event.position.distanceTo(state._draft.center!);
    state.context.render();
  }
}

class _CircleGraphicDraft extends BaseGraphic {
  _CircleGraphicDraft();

  Offset? center;

  double? radius;

  void reset() {
    center = null;
    radius = null;
  }

  @override
  void paint(Context context, Offset offset) {
    if (center == null || radius == null) return;
    final layer = context.context.currentLayer;
    if (layer == null) return;

    final paint = layersCubit.getPaint(layer, context);
    context.canvas.drawCircle(center!, radius!, paint);
  }

  CircleGraphic toGraphic() {
    return CircleGraphic(layer: layersCubit.current!, position: Offset.zero, radius: radius!, center: center!);
  }

  @override
  bool contains(Offset position) => false;

  @override
  _CircleGraphicDraft clone() {
    return _CircleGraphicDraft()
      ..layer = layer
      ..position = position
      ..center = center
      ..radius = radius;
  }

  @override
  Rect aabb() => Rect.fromCircle(center: center!, radius: radius!);
}
