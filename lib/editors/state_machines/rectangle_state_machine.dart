import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';

import 'state_machines.dart';

class RectangleStateMachine extends BaseStateMachine {
  RectangleStateMachine({required super.context});

  late BaseStateMachine _state = _DrawInitState(context: context, state: this);

  late final _RectangleGraphicDraft _draft = _RectangleGraphicDraft(palette: context.currentLayer!.palette);

  @override
  void onTapDown(event) {
    super.onTapDown(event);
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
    _state = _DrawInitState(context: context, state: this);
    context.graphic.children.remove(_draft);
    context.render();
    Actions.invoke(context.buildContext, AddGraphicIntent(context, [_draft.toGraphic()]));
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
    context.render();
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
    context.render();
  }
}

class _RectangleGraphicDraft extends BaseGraphic {
  _RectangleGraphicDraft({required super.palette});

  Offset? start;

  Offset? end;

  Rect? get rect => start != null && end != null ? Rect.fromPoints(start!, end!) : null;

  // final Paint _paint =
  //     Paint()
  //       ..style = PaintingStyle.stroke
  //       ..color = Colors.black;

  void reset() {
    start = null;
    end = null;
  }

  @override
  void paint(Context context, Offset offset) {
    if (start == null || end == null) return;
    if (palette == null) return;

    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = context.viewport.getLogicSize(palette!.outlineWidth)
          ..color = palette!.outlineColor;

    final Rect rect = Rect.fromPoints(start!, end!);
    context.canvas.drawRect(rect, paint);
  }

  RectangleGraphic toGraphic() {
    final rect = this.rect!;
    return RectangleGraphic(palette: palette, position: rect.topLeft, width: rect.width, height: rect.height);
  }

  @override
  bool contains(Offset position) => false;

  @override
  BaseGraphic clone() {
    return _RectangleGraphicDraft(palette: palette)
      ..start = start
      ..end = end;
  }

  @override
  Rect aabb() => Rect.fromPoints(start!, end!);
}
