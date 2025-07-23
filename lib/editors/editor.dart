import 'dart:ui' as ui;

import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flutter/widgets.dart' hide Viewport;
import 'package:matrix4_transform/matrix4_transform.dart';
import 'editor_config.dart';
import 'state_machines/state_machines.dart';

class EditorContext {
  late RootGraphic graphic;

  late SceneRenderObject renderObject;

  late final ValueNotifier<BaseStateMachine> stateMachineNotifier = ValueNotifier<BaseStateMachine>(
    SelectionStateMachine(context: this),
  );
  BaseStateMachine get stateMachine => stateMachineNotifier.value;

  final ValueNotifier<List<BaseGraphic>> selectedGraphicsNotifier = ValueNotifier<List<BaseGraphic>>([]);
  List<BaseGraphic> get selectedGraphics => selectedGraphicsNotifier.value;

  late BuildContext buildContext;

  Layer? get currentLayer => layersCubit.current;

  final Viewport viewport = Viewport();

  final CommandManager commands = CommandManager();

  void render() {
    canvasCubit.setZoom(viewport.getZoom());
    renderObject.markNeedsPaint();
  }

  bool canSee(Rect aabb) {
    return viewport.visibleWorldRect.overlaps(aabb);
  }

  bool canSeePoint(Offset offset) {
    return viewport.visibleWorldRect.contains(offset);
  }
}

class Editor extends StatefulWidget {
  const Editor({super.key, required this.context});

  final EditorContext context;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("Editor Builder");
    widget.context.buildContext = context;
    return StateMachine(context: widget.context, child: Scene(context: widget.context));
  }
}

class SceneRenderObject extends RenderBox {
  SceneRenderObject({required this.context}) {
    context.renderObject = this;
  }

  final EditorContext context;

  final Grid grid = Grid(dotGap: kEditorDotGap, dotSize: kEditorDotSize);

  final Axis axis = Axis(axisLength: kEditorAxisLength, axisWidth: kEditorAxisWidth);

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final Viewport viewport = this.context.viewport;
    final Matrix4Transform matrix = Matrix4Transform()
        .translate(x: offset.dx, y: offset.dy + viewport.size.height)
        .scaleVertically(-1);

    viewport.transform = matrix;

    context.pushTransform(needsCompositing, Offset.zero, matrix.m, (PaintingContext context, ui.Offset offset) {
      context.pushClipRect(needsCompositing, Offset.zero, Offset.zero & viewport.size, (
        PaintingContext context,
        ui.Offset offset,
      ) {
        context.pushTransform(needsCompositing, offset, viewport.matrix4.m, (
          PaintingContext context,
          ui.Offset offset,
        ) {
          final ctx = Context(context: this.context, paintingContext: context);
          grid.paint(ctx, Offset.zero);
          axis.paint(ctx, Offset.zero);
          this.context.graphic.paint(ctx, Offset.zero);

          Selection(graphics: this.context.selectedGraphics).paint(ctx, Offset.zero);
        });
      });
    });

    final paragraph =
        (ui.ParagraphBuilder(ui.ParagraphStyle())
              ..pushStyle(kEditorTextStyle)
              ..addText("${viewport.getLogicSize(kEditorDotGap)}"))
            .build()
          ..layout(ui.ParagraphConstraints(width: double.infinity));

    context.canvas.drawParagraph(paragraph, Offset(offset.dx + 50, offset.dy + viewport.size.height - 50));
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }
}

class Selection extends BaseGraphic {
  Selection({required this.graphics});

  final List<BaseGraphic> graphics;

  final Paint _paint =
      Paint()
        ..color = kEditorSelectedColor
        ..style = PaintingStyle.stroke;

  @override
  Selection clone() {
    return Selection(graphics: graphics);
  }

  @override
  bool contains(ui.Offset position) => false;

  @override
  void paint(Context ctx, ui.Offset offset) {
    for (final graphic in graphics) {
      final rect = graphic.aabb();
      _paint.strokeWidth = ctx.viewport.getLogicSize(kEditorSelectedStrokeWidth);
      ctx.canvas.drawRect(rect, _paint);
    }
  }

  @override
  Rect aabb() => Rect.zero;
}

class Scene extends LeafRenderObjectWidget {
  const Scene({super.key, required this.context});

  final EditorContext context;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SceneRenderObject(context: this.context);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
  }
}

class Grid extends BaseGraphic {
  Grid({required this.dotGap, required this.dotSize});

  final double dotGap;

  final double dotSize;

  final Paint _paint = Paint();

  void renderGrid(Context ctx) {
    final gap = ctx.viewport.getLogicSize(dotGap);

    final visibleWorldRect = ctx.viewport.visibleWorldRect;
    final dots = createGridDots(visibleWorldRect, gap);
    final strokeWidth = ctx.viewport.getLogicSize(dotSize);

    _paint.strokeWidth = strokeWidth;
    ctx.canvas.drawPoints(ui.PointMode.points, dots, _paint);
  }

  List<Offset> createGridDots(Rect rect, double gap) {
    final topLeft = rect.topLeft;
    final bottomRight = rect.bottomRight;

    final Set<Offset> dots = {};

    final start = topLeft - (topLeft % gap) + Offset(gap, gap);
    for (double dx = start.dx; dx <= bottomRight.dx; dx += gap) {
      for (double dy = start.dy; dy <= bottomRight.dy; dy += gap) {
        dots.add(Offset(dx, dy));
      }
    }

    return dots.toList();
  }

  @override
  void paint(Context ctx, Offset offset) {
    renderGrid(ctx);
  }

  @override
  bool contains(ui.Offset position) => false;

  @override
  Grid clone() {
    return Grid(dotGap: dotGap, dotSize: dotSize);
  }

  @override
  Rect aabb() => throw UnimplementedError("Axis");
}

class Axis extends BaseGraphic {
  Axis({required this.axisLength, required this.axisWidth});

  final double axisLength;

  final double axisWidth;

  final Paint _paint = Paint()..color = kEditorAxisColor;

  void renderAxis(Context ctx) {
    final double strokeWidth = ctx.viewport.getLogicSize(axisWidth);
    final double length = ctx.viewport.getLogicSize(axisLength);

    _paint.strokeWidth = strokeWidth;
    ctx.canvas.drawLine(Offset(-length, 0), Offset(length, 0), _paint);
    ctx.canvas.drawLine(Offset(0, -length), Offset(0, length), _paint);
  }

  @override
  void paint(Context ctx, Offset offset) {
    renderAxis(ctx);
  }

  @override
  bool contains(ui.Offset position) => false;

  @override
  Axis clone() {
    return Axis(axisLength: axisLength, axisWidth: axisWidth);
  }

  @override
  Rect aabb() => throw UnimplementedError("Axis");
}
