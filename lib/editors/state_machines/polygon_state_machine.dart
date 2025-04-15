import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../editors.dart';
import '../shapes/shapes.dart';
import 'state_machines.dart';

class PolygonStateMachine extends BaseStateMachine {
  PolygonStateMachine(super.game);

  late _DrawState _state = _DrawInitState(this);

  late final _PolygonDraftComponent _component = _PolygonDraftComponent(vertices: []);

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
    final polygon = PolygonShape(_component.vertices.toList());
    game.world.add(polygon);

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

  final PolygonStateMachine stateMachine;

  StateMachineGame get game => stateMachine.game;

  _PolygonDraftComponent get component => stateMachine._component;

  void onTapDown(TapDownInfo info) {}

  void onMouseMove(PointerHoverInfo info) {}
}

class _DrawInitState extends _DrawState {
  _DrawInitState(super.stateMachine);

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final Vector2 position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    component.vertices.add(position);
    stateMachine._state = _DrawStartedState(stateMachine);
  }
}

class _DrawStartedState extends _DrawInitState {
  _DrawStartedState(super.stateMachine);

  late int nextIndex = component.vertices.length;

  @override
  void onTapDown(TapDownInfo info) {
    nextIndex++;
    final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    component.vertices.add(position);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
    final length = component.vertices.length;

    if (nextIndex >= length) {
      component.vertices.add(position);
    } else {
      component.vertices[nextIndex] = position;
    }
  }
}

class _PolygonDraftComponent extends Component with HasGameRef<EditorGame> {
  _PolygonDraftComponent({required this.vertices});

  final List<Vector2> vertices;

  final Paint _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _paint.strokeWidth = game.camera.viewfinder.getLogicSize(1);

    final Path path = Path();
    final Vector2 first = vertices.first;

    path.moveTo(first.x, first.y);

    for (int i = 1; i < vertices.length; i++) {
      final Vector2 p = vertices[i];
      path.lineTo(p.x, p.y);
    }

    path.close();
    canvas.drawPath(path, _paint);
  }

  void reset() {
    vertices.clear();
  }
}
