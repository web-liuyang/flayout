import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
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
  void onMouseMove(event) {
    super.onMouseMove(event);
    _state.onMouseMove(event);
  }

  @override
  void onPan(PanCanvasEvent event) {
    super.onPan(event);
    context.viewport.translate(event.delta);
    context.render();
  }

  @override
  void onScroll(info) {
    super.onScroll(info);
    final zoomFn = switch (info.direction) {
      ScrollDirection.up => context.viewport.zoomIn,
      ScrollDirection.down => context.viewport.zoomOut,
    };

    zoomFn(info.position);
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
  void onPrimaryTapDown(info) {
    super.onPrimaryTapDown(info);
    state._draft.center = info.position;
    context.graphic.children.add(state._draft);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final CircleStateMachine state;

  @override
  void onPrimaryTapDown(info) {
    super.onPrimaryTapDown(info);
    state.done();
  }

  @override
  void onMouseMove(event) {
    super.onMouseMove(event);
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
    final layer = layersCubit.current;
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
