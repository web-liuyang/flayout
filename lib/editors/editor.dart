import 'dart:ui' as ui;

import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/widgets.dart' hide Viewport;
import 'editor_config.dart';
import 'state_machines/state_machines.dart';

class EditorContext {
  late RootGraphic graphic;

  final Viewport viewport = Viewport();

  late SceneRenderObject renderObject;

  late final ValueNotifier<BaseStateMachine> stateMachineNotifier = ValueNotifier<BaseStateMachine>(SelectionStateMachine(context: this));

  late BuildContext buildContext;

  BaseStateMachine get stateMachine => stateMachineNotifier.value;

  void render() => renderObject.markNeedsPaint();

  bool canSee(Rect aabb) {
    return viewport.visibleWorldRect.overlaps(aabb);
  }

  bool canSeePoint(Offset offset) {
    return viewport.visibleWorldRect.contains(offset);
  }

  void undo() {}

  void redo() {}
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
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    final rect = Offset.zero & this.context.viewport.size;
    context.pushClipRect(needsCompositing, Offset.zero, rect, (PaintingContext context, ui.Offset offset) {
      context.pushTransform(needsCompositing, offset, this.context.viewport.matrix4.matrix4, (PaintingContext context, ui.Offset offset) {
        final ctx = Context(context: this.context, paintingContext: context);
        grid.paint(ctx, Offset.zero);
        axis.paint(ctx, Offset.zero);
        this.context.graphic.paint(ctx, Offset.zero);
      });
    });
    context.canvas.restore();
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }
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
}

// class EditorGame extends StateMachineGame {
//   EditorGame({super.children, super.world, super.camera});

//   @override
//   bool get debugMode => false;

//   @override
//   FutureOr<void> onLoad() {
//     super.onLoad();
//     camera.viewfinder.anchor = Anchor.topLeft;
//     camera.viewfinder.position = -camera.visibleWorldRect.center.toVector2();
//     camera.viewfinder.zoom = zoomCubit.state;

//     // camera.viewfinder.position = Vector2(-8200, -1000);

//     add(FpsTextComponent(position: camera.viewport.size..[0] = 0, textRenderer: TextPaint(style: TextStyle(color: Colors.black))));
//     print("EditorGame onLoad");
//   }

//   @override
//   Color backgroundColor() => kEditorBackgroundColor;
// }

// class EditorWorld extends World with HasGameReference<EditorGame> {
//   final Grid grid = Grid(dotGap: kEditorDotGap, dotSize: kEditorDotSize);

//   final Axis axis = Axis(axisLength: kEditorAxisLength, axisWidth: kEditorAxisWidth);

//   @override
//   FutureOr<void> onLoad() {
//     addAll([grid, axis]);

//     paintGdsii();
//     return super.onLoad();
//   }

//   late double units;

//   late Gdsii gdsii;

//   Map<String, Cell> cells = {};

//   void paintGdsii() async {
//     game.pauseEngine();
//     final prefix = Platform.isWindows ? r"C:\Users\xiaoyao\Desktop\ansys" : "/Users/liuyang/Desktop/xiaoyao/ansys/";

//     gdsii = readGdsii('$prefix/mmi.gds');
//     // gdsii = readGdsii('$prefix/MZI_SYSTEM_FOR_2X2.py.gds');
//     // gdsii = readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/WBBC2017_top_180531.gds');
//     gdsii = readGdsii('$prefix/MZI_SYSTEM_FOR_8X8.py.gds');
//     units = gdsii.units;
//     print("units: $units");

//     gdsii.cells.indexed.forEach((item) {
//       final (int index, Cell element) = item;
//       cells[element.name] = element;
//       // print("$index: ${element.name}");
//     });

//     final int cellCount = gdsii.cells.map((item) => item.name).toSet().length;

//     Stopwatch stopwatch = Stopwatch()..start();
//     final component = paintCell(gdsii.cells[0], 0);
//     addAll(component);

//     print("cellCount: $cellCount");
//     stopwatch.stop();

//     print('init speed: ${stopwatch.elapsedMilliseconds}ms');
//   }

//   final Map<String, List<PositionComponent>> shapes = {};

//   // final Paint _paint = BasicPalette.black.paint();
//   final Paint _paint =
//       BasicPalette.black.paint()
//         ..filterQuality = FilterQuality.low
//         ..style = PaintingStyle.stroke;

//   final List<PositionComponent> comps = [];

//   List<PositionComponent> paintCell(Cell cell, int deep) {
//     final List<PositionComponent> graphics = [];

//     for (final struct in cell.srefs) {
//       if (struct is TextStruct) {
//         final points = struct.points;
//         assert(points.length == 1, "Text points length must be 1");
//         final position = points.first.toVector2() * units;
//         final text = struct.string;
//         final regular = TextPaint(style: TextStyle(color: _paint.color, fontSize: zoomCubit.state * 12));

//         final component = (TextShape(text: text, position: position, textRenderer: regular, priority: deep));
//         graphics.add(component);
//       }

//       if (struct is BoundaryStruct) {
//         final vertices = struct.points.toVector2s().map((e) => e * units).toList(growable: false);
//         final component = (PolygonShape(vertices, paint: _paint, priority: deep));
//         graphics.add(component);
//       }

//       if (struct is PathStruct) {
//         final vertices = struct.points.toVector2s().map((e) => e * units).toList();
//         final component = (PolylineShape(vertices, paint: _paint, priority: deep));
//         graphics.add(component);
//       }

//       if (struct is SRefStruct) {
//         final position = struct.points.first.toVector2() * units;
//         final shape = shapes[struct.name];
//         if (shape != null) {
//           final List<PositionComponent> children = shapes[struct.name]!;
//           final GroupShape groupShape = GroupShape(position: position, children: children, priority: deep);
//           graphics.add(groupShape);
//         } else {
//           final Cell cell = cells[struct.name]!;
//           final List<PositionComponent> children = paintCell(cell, deep + 1);
//           shapes[struct.name] = children;
//           final GroupShape groupShape = GroupShape(position: position, children: children, priority: deep);
//           graphics.add(groupShape);
//         }
//       }

//       if (struct is ARefStruct) {
//         final String cellName = struct.name;
//         final shape = shapes[cellName];

//         List<PositionComponent> children = [];

//         if (shape != null) {
//           children = shapes[cellName]!;
//         } else {
//           final Cell cell = cells[cellName]!;
//           children = paintCell(cell, deep + 1);
//           shapes[cellName] = children;
//         }

//         final int col = struct.col;
//         final int row = struct.row;
//         final List<GroupShape> repetitions = [];
//         for (int i = 0; i < col; i++) {
//           final double colOffset = (i) * struct.colSpacing;
//           for (int j = 0; j < row; j++) {
//             final double rowOffset = (j) * struct.rowSpacing;
//             final Vector2 pos = Vector2(colOffset, rowOffset) * units;
//             repetitions.add(GroupShape(position: pos, children: children, priority: deep + 1));
//           }
//         }

//         final localPosition = struct.offset.toVector2() * units;
//         final GroupShape groupShape = GroupShape(position: localPosition, children: repetitions, priority: deep);

//         graphics.add(groupShape);
//       }
//     }

//     return graphics;
//   }
// }

// class Grid extends PositionComponent with HasGameReference<EditorGame> {
//   Grid({required this.dotGap, required this.dotSize});

//   final double dotGap;

//   final double dotSize;

//   final Paint _paint = Paint();

//   void renderGrid(Canvas canvas) {
//     final double gap = game.camera.viewfinder.getLogicSize(dotGap);
//     final visibleWorldRect = game.camera.visibleWorldRect;

//     final dots = createGridDots(visibleWorldRect, gap);
//     final double strokeWidth = game.camera.viewfinder.getLogicSize(dotSize);

//     _paint.strokeWidth = strokeWidth;
//     canvas.drawPoints(ui.PointMode.points, dots, _paint);
//   }

//   List<Offset> createGridDots(Rect rect, double gap) {
//     final topLeft = rect.topLeft;
//     final bottomRight = rect.bottomRight;

//     final Set<Offset> dots = {};

//     final start = topLeft - (topLeft % gap) + Offset(gap, gap);
//     for (double dx = start.dx; dx <= bottomRight.dx; dx += gap) {
//       for (double dy = start.dy; dy <= bottomRight.dy; dy += gap) {
//         dots.add(Offset(dx, dy));
//       }
//     }

//     return dots.toList();
//   }

//   @override
//   void render(Canvas canvas) {
//     renderGrid(canvas);
//     super.render(canvas);
//   }
// }

// class Axis extends PositionComponent with HasGameReference<EditorGame> {
//   Axis({required this.axisLength, required this.axisWidth});

//   final double axisLength;

//   final double axisWidth;

//   final Paint _paint = Paint()..color = kEditorAxisColor;

//   void renderAxis(Canvas canvas) {
//     final double strokeWidth = game.camera.viewfinder.getLogicSize(axisWidth);
//     final double length = game.camera.viewfinder.getLogicSize(axisLength);

//     _paint.strokeWidth = strokeWidth;

//     canvas.drawLine(Offset(-length, 0), Offset(length, 0), _paint);
//     canvas.drawLine(Offset(0, -length), Offset(0, length), _paint);
//   }

//   @override
//   void render(Canvas canvas) {
//     renderAxis(canvas);
//     super.render(canvas);
//   }
// }
