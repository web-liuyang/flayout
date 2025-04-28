import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../editor_config.dart';
import 'base_state_machine.dart';

class SelectionStateMachine extends BaseStateMachine {
  SelectionStateMachine(super.game);

  late double startZoom;

  late Vector2 startPivot;

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final Viewfinder viewfinder = game.camera.viewfinder;
    viewfinder.position -= info.delta.global / viewfinder.zoom;
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    startPivot = game.camera.globalToLocal(info.eventPosition.widget);
    startZoom = game.camera.viewfinder.zoom;
  }

  final defaultFactor = Vector2.all(1);

  final step = 0.05;

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scaleFactor = info.scale.global;
    // if (scaleFactor == defaultFactor) return;

    final worldOffset = info.eventPosition.widget;
    final newZoom = (startZoom * scaleFactor.x).clamp(kMinZoom, kMaxZoom);

    zoomCubit.zoomAt(newZoom, startPivot, worldOffset);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // - Zoom In
    // + Zoom Out
    final sign = info.scrollDelta.global.y.sign;
    final delta = (-sign) * step;
    final pivot = game.camera.globalToLocal(info.eventPosition.widget);
    final worldOffset = info.eventPosition.widget;
    final newZoom = (zoomCubit.state + delta).clamp(kMinZoom, kMaxZoom);
    // print(newZoom);
    zoomCubit.zoomAt(newZoom, pivot, worldOffset);
  }
}
