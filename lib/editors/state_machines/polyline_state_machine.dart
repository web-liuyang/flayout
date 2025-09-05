import 'package:flayout/commands/commands.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../layouts/cubits/cubits.dart';
import 'state_machines.dart';

class PolylineStateMachine extends BaseStateMachine {
  PolylineStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitState(context: context, state: this);

  late final _PolylineStateMachineGraphicDraft _draft = _PolylineStateMachineGraphicDraft();

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

  final PolylineStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    state._draft.vertices.add(event.position);
    context.graphic.children.add(state._draft);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final PolylineStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    super.onPrimaryTapDown(event);
    state._draft.vertices.add(state._draft.auxiliary!);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }

  @override
  void onSecondaryTapDown(event) {
    super.onSecondaryTapDown(event);
    state.done();
  }

  @override
  void onMove(event) {
    super.onMove(event);
    final isShift =
        HardwareKeyboard.instance.logicalKeysPressed
            .intersection(LogicalKeyboardKey.expandSynonyms({LogicalKeyboardKey.shift}))
            .isNotEmpty;

    state._draft.auxiliary = isShift ? state._draft.vertices.last.snapTo45Degree(event.position) : event.position;
    context.render();
  }
}

class _PolylineStateMachineGraphicDraft extends BaseGraphic {
  _PolylineStateMachineGraphicDraft();

  List<Offset> vertices = [];

  double halfWidth = 1;

  Offset? auxiliary;

  void reset() {
    vertices.clear();
    auxiliary = null;
  }

  Path _path = Path();

  @override
  void paint(Context context, Offset offset) {
    if (vertices.isEmpty || auxiliary == null) return;
    final layer = context.context.currentLayer;
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer, context);
    if (paint == null) return;
    _path
      ..reset()
      ..moveTo(vertices.first.dx, vertices.first.dy);
    for (int i = 1; i < vertices.length; i++) {
      _path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    _path.lineTo(auxiliary!.dx, auxiliary!.dy);
    context.canvas.drawPath(_path, paint);
  }

  PolylineGraphic toGraphic() {
    return PolylineGraphic(
      layer: layersCubit.current!,
      vertices: [...vertices, auxiliary!],
      halfWidth: 1,
    );
  }

  @override
  bool contains(Offset position) => false;

  @override
  BaseGraphic clone() {
    return _PolylineStateMachineGraphicDraft()
      ..layer = layer
      ..position = position
      ..vertices = vertices
      ..halfWidth = halfWidth;
  }

  @override
  Rect aabb() => throw UnimplementedError("_PolylineStateMachineGraphicDraft aabb()");
}
