import 'dart:async';
import 'dart:ui' as ui;

import 'package:flayout/commands/commands.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:flutter/widgets.dart' hide Viewport;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'editor_config.dart';
import 'state_machines/state_machines.dart';
import 'package:image/image.dart' as img;

class EditorContext {
  late RootGraphic graphic;

  late SceneRenderObject renderObject;

  late BuildContext buildContext;

  late final ValueNotifier<BaseStateMachine> stateMachineNotifier = ValueNotifier<BaseStateMachine>(
    SelectionStateMachine(context: this),
  );
  BaseStateMachine get stateMachine => stateMachineNotifier.value;

  final ValueNotifier<List<BaseGraphic>> selectedGraphicsNotifier = ValueNotifier<List<BaseGraphic>>([]);
  List<BaseGraphic> get selectedGraphics => selectedGraphicsNotifier.value;

  Layer? get currentLayer => buildContext.read<LayersCubit>().current;

  final Viewport viewport = Viewport();

  final CommandManager commands = CommandManager();

  void render() {
    renderObject.markNeedsPaint();
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

Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd =
        img.Command()
          ..image(image)
          ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

  ui.ImageDescriptor id = ui.ImageDescriptor.raw(
    buffer,
    height: image.height,
    width: image.width,
    pixelFormat: ui.PixelFormat.rgba8888,
  );

  ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);
  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image uiImage = fi.image;

  return uiImage;
}

ui.Image? flutterImage;

class SceneRenderObject extends RenderBox {
  SceneRenderObject({required this.context}) {
    context.renderObject = this;
    (() async {
      final t = img.Image(width: 100, height: 100, backgroundColor: img.ColorUint1.rgb(255, 0, 255));
      img.drawCircle(t, x: 50, y: 50, radius: 50, color: img.ColorUint1.rgb(255, 255, 255), antialias: true);
      // final pngBytes = image.encodePng(img);
      flutterImage = await convertImageToFlutterUi(t);
    })();
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
          // if (flutterImage != null) {
          //   ctx.canvas.drawImage(flutterImage!, Offset.zero, Paint());
          // }
        });
      });
    });

    canvasCubit.set(zoom: viewport.getZoom(), grid: viewport.getLogicSize(kEditorDotGap));
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
