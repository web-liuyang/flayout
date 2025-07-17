import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';

import 'state_machines.dart';

class RectangleStateMachine extends BaseStateMachine {
  RectangleStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitState(context: context, state: this);

  late final _RectangleGraphicDraft _draft = _RectangleGraphicDraft();

  @override
  void onTapDown(event) {
    _state.onTapDown(event);
  }

  @override
  void onMouseMove(event) {
    super.onMouseMove(event);
    _state.onMouseMove(event);
  }

  @override
  void done() {
    super.done();

    context.graphic.children.remove(_draft);
    final graphic = _draft.toGraphic();
    // context.graphic.children.add(_draft.toGraphic());
    // print(context.buildContext);
    // print(Actions.maybeFind(context.buildContext, intent: AddGraphicIntent(context, graphic)));
    Actions.invoke(context.buildContext, AddGraphicIntent(context, [graphic]));
    _state = _DrawInitState(context: context, state: this);
  }

  @override
  void exit() {
    super.exit();
    _state = _DrawInitState(context: context, state: this);
    final result = context.graphic.children.remove(_draft);
    context.render();
    if (!result) context.stateMachineNotifier.value = SelectionStateMachine(context: context);
  }
}

class _DrawInitState extends BaseStateMachine {
  _DrawInitState({required super.context, required this.state});

  final RectangleStateMachine state;

  @override
  void onTapDown(info) {
    state._draft.start = info.position;
    context.graphic.children.add(state._draft);
    state._state = _DrawStartedState(context: context, state: state);
  }
}

class _DrawStartedState extends BaseStateMachine {
  _DrawStartedState({required super.context, required this.state});

  final RectangleStateMachine state;

  @override
  void onTapDown(info) {
    state.done();
  }

  @override
  void onMouseMove(event) {
    super.onMouseMove(event);
    state._draft.end = event.position;
    state.context.render();
  }
}

class _RectangleGraphicDraft extends BaseGraphic {
  _RectangleGraphicDraft();

  Offset? start;

  Offset? end;

  Rect? get rect => start != null && end != null ? Rect.fromPoints(start!, end!) : null;

  final Paint _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black;

  void reset() {
    start = null;
    end = null;
  }

  @override
  void paint(Context context, Offset offset) {
    if (start == null || end == null) return;
    _paint.strokeWidth = context.viewport.getLogicSize(1);
    final Rect rect = Rect.fromPoints(start!, end!);
    context.canvas.drawRect(rect, _paint);
  }

  PolygonGraphic toGraphic() {
    final rect = this.rect!;
    return PolygonGraphic(vertices: [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft, rect.topLeft]);
  }

  @override
  bool contains(Offset position) => false;

  @override
  BaseGraphic clone() {
    return _RectangleGraphicDraft()
      ..start = start
      ..end = end;
  }

  @override
  Rect aabb() => Rect.fromPoints(start!, end!);
}
