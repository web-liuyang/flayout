import 'package:blueprint_master/editors/state_machines/state_machine.dart';
import 'package:flutter/gestures.dart';

import 'base_state_machine.dart';

class SelectionStateMachine extends BaseStateMachine {
  SelectionStateMachine({required super.context});

  late double startZoom;

  late double prevZoom;

  @override
  void onTapDown(TapDownCanvasEvent event) {
    for (int i = context.graphic.children.length - 1; i >= 0; i--) {
      final g = context.graphic.children[i];
      if (g.contains(event.position)) {
        final selected = context.selectedGraphics.contains(g);
        if (!selected) context.selectedGraphicsNotifier.value = [g];
        return;
      }
    }

    context.selectedGraphicsNotifier.value = [];
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
    prevZoom = 1;
  }

  @override
  void onScaleUpdate(info) {
    print(1);
    // scale
    if (prevZoom != info.scale) {
      final zoomFn = prevZoom < info.scale ? context.viewport.zoomIn : context.viewport.zoomOut;
      zoomFn(info.position);
      prevZoom = info.scale;
    }

    context.viewport.translate(info.delta);
    context.render();
  }

  @override
  void onScroll(info) {
    final zoomFn = switch (info.direction) {
      ScrollDirection.up => context.viewport.zoomIn,
      ScrollDirection.down => context.viewport.zoomOut,
    };
    zoomFn(info.position);
    context.render();
  }
}
