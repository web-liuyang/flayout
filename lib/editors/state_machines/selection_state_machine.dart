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

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scaleFactor = info.scale.global;
    if (!scaleFactor.isIdentity()) {
      final worldOffset = info.eventPosition.widget;
      final newZoom = (startZoom * scaleFactor.x).clamp(kMinZoom, kMaxZoom);

      zoomCubit.zoomAt(newZoom, startPivot, worldOffset);
    } else {
      throw RangeError("scaleFactor: $scaleFactor");
    }
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {}

  void zoomAtPoint(Viewfinder viewfinder, double newZoom, Vector2 pivot, Vector2 offset) {
    final newPosition = pivot - (offset / newZoom);
    viewfinder.zoom = newZoom;
    viewfinder.position = newPosition;
  }
}
