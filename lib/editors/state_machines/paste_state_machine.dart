import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';

import 'state_machines.dart';

class PasteStateMachine extends BaseStateMachine {
  PasteStateMachine({required super.context, required List<BaseGraphic> graphics}) {
    _aabb = graphics.fold(
      graphics.first.aabb(),
      (previousValue, element) => previousValue.expandToInclude(element.aabb()),
    );
    _draft = GroupGraphic(children: graphics.map((e) => e.clone()).toList(growable: false));
    context.graphic.children.add(_draft);
    context.render();
  }

  late Rect _aabb;

  late GroupGraphic _draft;

  @override
  void onPrimaryTapDown(event) {
    done();
  }

  @override
  void onMove(event) {
    super.onMove(event);
    _draft.position = event.position - _aabb.center;
    context.render();
  }

  @override
  void done() {
    super.done();
    final List<BaseGraphic> children = _draft.children
        .map((child) => child.clone()..position = child.position + _draft.position)
        .toList(growable: false);
    Actions.invoke(context.buildContext, AddGraphicIntent(context, children));
    context.render();
  }

  @override
  void exit() {
    super.exit();
    context.graphic.children.remove(_draft);
    context.render();
    context.stateMachineNotifier.value = SelectionStateMachine(context: context);
  }
}
