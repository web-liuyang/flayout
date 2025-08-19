import 'package:flayout/extensions/extensions.dart';

import '../graphics/graphics.dart';
import 'base_state_machine.dart';

class SelectionStateMachine extends BaseStateMachine {
  SelectionStateMachine({required super.context});

  late double startZoom;

  late double prevZoom;

  @override
  void onPrimaryTapDown(TapDownCanvasEvent event) {
    super.onPrimaryTapDown(event);
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
  void onPan(PanCanvasEvent event) {
    super.onPan(event);
    context.viewport.translate(event.delta);
    context.render();
  }

  @override
  void onDrag(DragCanvasEvent event) {
    super.onDrag(event);
    for (final BaseGraphic g in context.selectedGraphics) {
      g.position += event.delta;
    }

    context.selectedGraphicsNotifier.value = [...context.selectedGraphics];
    context.render();
  }

  @override
  void onZoom(event) {
    super.onZoom(event);
    final zoomFn = switch (event.direction) {
      ZoomDirection.zoomIn => context.viewport.zoomIn,
      ZoomDirection.zoomOut => context.viewport.zoomOut,
    };

    zoomFn(event.position);
    context.render();
  }

  @override
  void delete() {
    super.delete();
    context.graphic.children.removeAll(context.selectedGraphics);
    context.selectedGraphicsNotifier.value = [];
    context.render();
  }
}
