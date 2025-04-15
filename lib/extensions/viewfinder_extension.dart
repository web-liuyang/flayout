import 'package:flame/camera.dart';
import 'package:flame/game.dart';

import '../editors/editor_config.dart';

extension ViewfinderExtension on Viewfinder {
  double getLogicSize(double value) {
    return switch (zoom) {
      < 1.0 => value / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => value / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };
  }

  // pivot 是鼠标在 canvas 画布中的位置
  // offset 是鼠标在 canvas 组件上的位置
  void zoomAt(double newZoom, Vector2 pivot, Vector2 offset) {
    final newPosition = pivot - (offset / newZoom);
    zoom = newZoom;
    position = newPosition;
  }
}
