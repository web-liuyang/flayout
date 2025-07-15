import 'package:blueprint_master/editors/state_machines/state_machine.dart';
import 'package:flutter/gestures.dart';

import 'base_state_machine.dart';

class SelectionStateMachine extends BaseStateMachine {
  SelectionStateMachine({required super.context});

  late double startZoom;

  late ScaleStartDetails scaleStartDetails;

  late double prevZoom;

  @override
  void onTap() {
    // super.onTap();
  }

  @override
  void onPanUpdate(info) {
    // world.viewport.matrix4;
    // print(info.delta);
    // final Viewfinder viewfinder = game.camera.viewfinder;
    // viewfinder.position -= info.delta.global / viewfinder.zoom;
  }

  @override
  void onScaleStart(info) {
    scaleStartDetails = info;
    prevZoom = 1;
  }

  @override
  void onScaleUpdate(info) {
    // scale
    if (prevZoom != info.scale) {
      final zoomFn = prevZoom < info.scale ? context.viewport.zoomIn : context.viewport.zoomOut;
      final point = context.viewport.windowToCanvas(info.localFocalPoint);
      zoomFn(point);
      prevZoom = info.scale;
    }

    context.viewport.translate(info.focalPointDelta);
    context.render();
  }

  @override
  void onScroll(info) {
    final point = context.viewport.windowToCanvas(info.localPosition);
    final zoomFn = switch (info.direction) {
      ScrollDirection.up => context.viewport.zoomIn,
      ScrollDirection.down => context.viewport.zoomOut,
    };
    zoomFn(point);
    context.render();
  }
}
