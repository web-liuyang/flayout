import 'dart:math';

import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../editors.dart';
import '../shapes/shapes.dart';
import 'state_machines.dart';

class CircleStateMachine extends BaseStateMachine {
  CircleStateMachine(super.game);

  late _DrawState _state = _DrawInitState(this);

  late final _CircleDraftComponent _component = _CircleDraftComponent();

  @override
  void onTapDown(TapDownInfo info) {
    if (!game.world.contains(_component)) game.world.add(_component);
    super.onTapDown(info);
    _state.onTapDown(info);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    _state.onMouseMove(info);
  }

  @override
  void done() {
    super.done();

    final position = _component.center! - Vector2.all(_component.radius);

    final CircleShape circle = CircleShape(position: position, radius: _component.radius);
    game.world.add(circle);

    _component.reset();
    game.world.remove(_component);

    _state = _DrawInitState(this);
  }

  @override
  void exit() {
    super.exit();

    if (game.world.contains(_component)) {
      _component.reset();
      game.world.remove(_component);
    }

    drawCubit.enterSelection();
  }
}

class _DrawState {
  _DrawState(this.stateMachine);

  final CircleStateMachine stateMachine;

  StateMachineGame get game => stateMachine.game;

  _CircleDraftComponent get component => stateMachine._component;

  void onTapDown(TapDownInfo info) {}

  void onMouseMove(PointerHoverInfo info) {}
}

class _DrawInitState extends _DrawState {
  _DrawInitState(super.stateMachine);

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    final Vector2 position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    component.center = position;

    stateMachine._state = _DrawStartedState(stateMachine);
  }
}

class _DrawStartedState extends _DrawInitState {
  _DrawStartedState(super.stateMachine);

  @override
  void onTapDown(TapDownInfo info) {
    stateMachine.done();
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    final Vector2 position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    final Vector2 delta = component.center! - position;
    final double radius = max(delta.x.abs(), delta.y.abs());
    component.radius = radius;
  }
}

class _CircleDraftComponent extends Component with HasGameRef<EditorGame> {
  _CircleDraftComponent();

  Vector2? center;

  double radius = 0;

  final Paint _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (center == null || radius <= 0) return;

    _paint.strokeWidth = game.camera.viewfinder.getLogicSize(1);
    canvas.drawCircle(center!.toOffset(), radius, _paint);
  }

  void reset() {
    center = null;
    radius = 0;
  }
}
