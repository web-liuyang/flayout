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
  void onScroll(info) {
    super.onScroll(info);
    final zoomFn = switch (info.direction) {
      ScrollDirection.up => context.viewport.zoomIn,
      ScrollDirection.down => context.viewport.zoomOut,
    };

    zoomFn(info.position);
    context.render();
  }
}
