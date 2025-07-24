import 'dart:math';
import 'dart:ui' as ui;

import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../layouts/cubits/cubits.dart';
import 'state_machines.dart';

class PolygonStateMachine extends BaseStateMachine {
  PolygonStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitFirstPointState(context: context, state: this);

  late final _PolygonStateMachineGraphicDraft _draft = _PolygonStateMachineGraphicDraft();

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
  void onScroll(event) {
    super.onScroll(event);
    final zoomFn = switch (event.direction) {
      ScrollDirection.up => context.viewport.zoomIn,
      ScrollDirection.down => context.viewport.zoomOut,
    };

    zoomFn(event.position);
    context.render();
  }

  @override
  void done() {
    super.done();
    _state = _DrawInitFirstPointState(context: context, state: this);
    context.graphic.children.remove(_draft);
    context.render();
    Actions.invoke(context.buildContext, AddGraphicIntent(context, [_draft.toGraphic()]));

    _draft.reset();
  }

  @override
  void exit() {
    super.exit();
    _state = _DrawInitFirstPointState(context: context, state: this);
    final result = context.graphic.children.remove(_draft);
    context.render();
    if (!result) context.stateMachineNotifier.value = SelectionStateMachine(context: context);

    _draft.reset();
  }
}

class _DrawInitFirstPointState extends BaseStateMachine {
  _DrawInitFirstPointState({required super.context, required this.state});

  final PolygonStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    state._draft.vertices.add(event.position);
    context.graphic.children.add(state._draft);
    context.render();
    state._state = _DrawInitSecondPointState(context: context, state: state);
  }
}

class _DrawInitSecondPointState extends BaseStateMachine {
  _DrawInitSecondPointState({required super.context, required this.state});

  final PolygonStateMachine state;

  @override
  void onPrimaryTapDown(event) {
    super.onPrimaryTapDown(event);
    state._draft.vertices.add(state._draft.auxiliary!);
    context.render();
    state._state = _DrawStartedState(context: context, state: state);
  }

  @override
  void onMove(event) {
    super.onMove(event);
    final isShift =
        HardwareKeyboard.instance.logicalKeysPressed
            .intersection(LogicalKeyboardKey.expandSynonyms({LogicalKeyboardKey.shift}))
            .isNotEmpty;

    state._draft.auxiliary = isShift ? snapTo45Degree(state._draft.vertices.last, event.position) : event.position;
    context.render();
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final PolygonStateMachine state;

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

    state._draft.auxiliary = isShift ? snapTo45Degree(state._draft.vertices.last, event.position) : event.position;
    context.render();
  }
}

class _PolygonStateMachineGraphicDraft extends BaseGraphic {
  _PolygonStateMachineGraphicDraft();

  List<Offset> vertices = [];

  Offset? auxiliary;

  void reset() {
    vertices.clear();
    auxiliary = null;
  }

  @override
  void paint(Context context, Offset offset) {
    if (vertices.isEmpty || auxiliary == null) return;
    final layer = layersCubit.current;
    if (layer == null) return;
    final paint = layersCubit.getPaint(layer, context);

    if (vertices.length == 1) {
      context.canvas.drawLine(vertices.first, auxiliary!, paint);
    } else {
      context.canvas.drawPoints(ui.PointMode.polygon, [...vertices, auxiliary!, vertices.first], paint);
    }
  }

  PolygonGraphic toGraphic() {
    return PolygonGraphic(
      layer: layersCubit.current!,
      vertices: [...vertices, auxiliary!],
      close: true,
    );
  }

  @override
  bool contains(Offset position) => false;

  @override
  BaseGraphic clone() {
    return _PolygonStateMachineGraphicDraft()
      ..layer = layer
      ..position = position
      ..vertices = vertices;
  }

  @override
  Rect aabb() => throw UnimplementedError("_PolygonStateMachineGraphicDraft aabb()");
}

Offset snapTo45Degree(Offset start, Offset end) {
  final delta = end - start;
  final angle = delta.direction;
  // 45度 = pi/4
  final snappedAngle = (angle / (pi / 4)).round() * (pi / 4);
  final length = delta.distance;
  return start + Offset.fromDirection(snappedAngle, length);
}
