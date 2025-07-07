import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blueprint_master/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:thread/thread.dart';

import 'package:blueprint_master/benchmark.dart';
import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:blueprint_master/layers/layers.dart';
import 'package:flutter/rendering.dart' hide Layer;
import 'package:flutter/widgets.dart';
// import 'package:flame/components.dart';
// import 'package:flame/extensions.dart';
// import 'package:flame/game.dart';
// import 'package:flame/palette.dart';
// import 'package:flame/text.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:vector_math/vector_math_64.dart';
// import 'package:vector_math/vector_math_64.dart';
// import 'package:vector_math/vector_math.dart';

import '../gdsii/builder.dart';
import '../gdsii/gdsii.dart';
import 'editor_config.dart';
import 'state_machines/state_machines.dart';

abstract class BaseCustomPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size);

  @override
  bool shouldRepaint(covariant BaseCustomPainter oldDelegate) {
    // print("${runtimeType} shouldRepaint");
    return false;
  }
}

class Viewport {
  Viewport({this.size = Size.zero}) {
    final halfSize = size / 2;
    matrix4 = Matrix4Transform().translate(x: halfSize.width, y: halfSize.height);
  }

  Rect get visibleWorldRect {
    final translation = getTranslation();
    final zoom = getZoom();

    final tx = -translation.dx / zoom;
    final ty = -translation.dy / zoom;

    final width = size.width / zoom;
    final height = size.height / zoom;

    return Rect.fromLTWH(tx, ty, width, height);
  }

  Size size;

  late Matrix4Transform matrix4;

  void setZoom(double zoom, {Offset? origin}) {
    final newZoom = zoom.clamp(kMinZoom, kMaxZoom);
    matrix4 = matrix4.setZoom(newZoom, origin: origin);
  }

  void zoomIn(Offset origin) {
    final zoom = getZoom() + 0.01;
    setZoom(zoom, origin: origin);
  }

  void zoomOut(Offset origin) {
    final zoom = getZoom() - 0.01;
    setZoom(zoom, origin: origin);
  }

  void moveToCenter() {}

  void fitToWindow() {}

  double getLogicSize(double size) {
    final zoom = getZoom();
    return switch (zoom) {
      < 1.0 => size / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => size / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };
  }

  Vector3 localToGlobal(Vector3 position) {
    return matrix4.localToGlobal(position);
  }

  Vector3 windowToWorld(Vector3 position) {
    final m = matrix4.m;
    final tx = m[12];
    final ty = m[13];
    final tz = m[14];
    final x = (position.x - tx) / m[0];
    final y = (position.y - ty) / m[5];
    final z = (position.z - tz) / m[10];

    return Vector3(x, y, z);
  }

  double getZoom() {
    return max(matrix4.m.entry(0, 0), matrix4.m.entry(1, 1));
  }

  void translate(Offset offset) {
    matrix4 = matrix4.translate(x: offset.dx, y: offset.dy);
  }

  void setTranslation(Offset offset) {
    matrix4 = Matrix4Transform.from(
      matrix4.matrix4
        ..[4] = offset.dx
        ..[8] = offset.dy,
    );
  }

  Offset getTranslation() {
    return matrix4.getTranslation();
  }

  // void setTranslation(double tx, double ty) {
  //   matrix4.setTranslation(tx, ty);
  // }
}

class World {
  void init(Size size) {
    viewport = Viewport(size: size);
  }

  late Viewport viewport;

  late Element context;

  void render() async {
    context.markNeedsBuild();
  }

  bool canSee(Rect aabb) {
    return viewport.visibleWorldRect.overlaps(aabb);
  }

  bool canSeePoint(Offset offset) {
    return viewport.visibleWorldRect.contains(offset);
  }

  final List<Path> paths = [];
  final int count = 1000_0000_000;
  final List<Float32List> vertices = [];
  final List<ui.Vertices> vertices2 = [];
}

CellBusinessGraphic? cell;

List<BaseBusinessGraphic> flattenCell(CellBusinessGraphic graphic) {
  final List<BaseBusinessGraphic> children = [];

  void resursive(List<BaseBusinessGraphic> graphics) {
    for (final BaseBusinessGraphic graphic in graphics) {
      if (graphic is CellBusinessGraphic) {
        children.add(graphic);
        children.addAll(flattenCell(graphic));
      } else if (graphic is InstanceBusinessGraphic) {
        children.add(graphic);
        children.addAll(flattenCell(graphic.cell));
      } else if (graphic is ArrayBusinessGraphic) {
        children.add(graphic);
        children.addAll(flattenCell(graphic.cell));
      } else {
        children.add(graphic);
      }
    }
  }

  resursive(graphic.children);

  return children;
}

void buildBitmap(BaseBusinessGraphic graphic) {
  compute((_) {
    buildBitmap(cell!);

    print(ui.Color(0xFF000000));
  }, null);
}

class Editor extends StatelessWidget {
  Editor({super.key});

  final World world = World();

  late BaseStateMachine stateMachine = SelectionStateMachine(world: world);

  @override
  Widget build(BuildContext context) {
    print("Editor Builder");

    // final drawCubit = context.watch<DrawCubit>();

    // return GameWidget(game: drawCubit.game);
    return LayoutBuilder(
      builder: (context, c) {
        world.init(c.biggest);

        // final cells = parseGdsii("/Users/liuyang/Desktop/xiaoyao/ansys/mmi.gds");
        final result = parseGdsii("/Users/liuyang/Desktop/xiaoyao/ansys/MZI_SYSTEM_FOR_8X8.py.gds");
        print(result.layers.map((e) => e.identity()).toList());
        cell = result.cells[0];
        final graphics = Benchmark.run(() {
          final graphics = flattenCell(cell!);

          print(graphics.length);

          return graphics;
        }, "flattenCell");

        // cell.collect(collection);
        // for (final element in cells.indexed) {
        //   print("${element.$1}: ${element.$2.name}");
        // }

        // viewport.matrix4.setTranslation(Vector3(viewport.size.width / 2, viewport.size.height / 2, 1));
        // world.viewport.matrix4.setTranslation(Vector3(100, 0, 1));

        // final List<BaseGraphic> children = [];
        // void add(GroupGraphic gg, Offset offset) {
        //   for (final element in gg.children) {
        //     if (element is GroupGraphic) {
        //       add(element, element.position * kEditorUnits);
        //     } else {
        //       element.position += offset;
        //       children.add(element);
        //     }
        //   }
        // }

        // add(cell.toGraphic(), Offset.zero);
        // print("count: ${children.length}");
        return Builder(
          builder: (context) {
            world.context = context as Element;
            return Container(
              width: world.viewport.size.width,
              height: world.viewport.size.height,
              child: StateMachine(
                state: stateMachine,
                child: CustomPaint(painter: Scene(world: world, cell: cell!, graphics: [])),
                // child: ListView.builder(
                //   itemCount: children.length,
                //   itemBuilder: (context, index) {
                //     // print(index);
                //     // return CustomPaint(painter: Scene(world: world, cell: cells[0]));
                //     return CustomPaint(painter: children[index]);
                //   },
                // ),
              ),
            );
          },
        );
      },
    );
  }
}

final globalPath = Path();

ui.Image? imageCache;

Float32List? f32;

class Scene extends BaseCustomPainter {
  Scene({required this.world, required this.cell, required this.graphics}) {
    // final List<BaseGraphic> children = [];
    // void add(GroupGraphic gg, Offset offset) {
    //   for (final element in gg.children) {
    //     if (element is GroupGraphic) {
    //       add(element, element.position * kEditorUnits);
    //     } else {
    //       element.position += offset;
    //       children.add(element);
    //     }
    //   }
    // }

    // add(cell.toGraphic(world), Offset.zero);

    // _graphics = children;
  }

  final List<BaseGraphic> graphics;

  final CellBusinessGraphic cell;

  late Grid grid = Grid(dotGap: kEditorDotGap, dotSize: kEditorDotSize, world: world);

  late Axis axis = Axis(axisLength: kEditorAxisLength, axisWidth: kEditorAxisWidth, world: world);

  final World world;

  // 多次调用 drawPath 可以充分利用 GPU

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    print("Scene paint");

    canvas.clipRect(Offset.zero & size);

    final pr = RendererBinding.instance.createPictureRecorder();
    final innerCanvas = RendererBinding.instance.createCanvas(pr);

    innerCanvas.transform(world.viewport.matrix4.storage);
    print(world.viewport.matrix4.storage);
    // const int width = 100;
    // const int height = 100;
    // final bitmap = createBitmap(width, height);

    // // 绘制光滑的斜线
    // drawLine(bitmap, width, height, 0, 0, 100, 100, [0, 0, 255, 255]); // 蓝色线条

    if (imageCache == null) {
      print("1");
      drawTest().then((image) {
        imageCache = image;
        world.render();
      });
      // createLineImage(100, 100, Offset(0, 0), Offset(100, 100)).then((image) async {
      //   // final byteData = await image.toByteData();
      //   // f32 = Float32List.fromList([0, 0, 100, 100]);
      //   print("A");
      //   imageCache = image;
      //   world.render();
      // });
    } else {
      print("2");

      // innerCanvas.drawRawPoints(
      //   ui.PointMode.points,
      //   f32!,
      //   Paint()
      //     ..color = Color(0xFFFF4500)
      //     ..strokeWidth = 1
      //     ..isAntiAlias = false,
      // );

      innerCanvas.drawLine(
        Offset(0, 0),
        Offset(100, 100),
        Paint()
          ..color = Color(0xFFFF4500)
          ..strokeWidth = 1,
      );

      innerCanvas.drawImage(imageCache!, Offset(100, 0), Paint());
    }

    // canvas.transform(world.viewport.matrix4.storage);
    // final c = Collection();

    // Benchmark.run(() {
    //   cell.collect(c);
    // }, cell.name);

    // print(c.layerDependency.length);
    // print(c.cellNameDependency.length);

    Benchmark.run(() {
      // 700ms 330ms 20ms
      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   final path = Path();
      //   path.addRect(rect);
      //   paths.add(path);
      // }

      // 800ms 350ms 20ms
      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   final path = Path();
      //   path.moveTo(rect.left, rect.top);
      //   path.lineTo(rect.right, rect.top);
      //   path.lineTo(rect.right, rect.bottom);
      //   path.lineTo(rect.left, rect.bottom);
      //   path.close();
      //   paths.add(path);
      // }

      // 366ms 0ms 20ms 实际渲染其实于 path 差不多
      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   innerCanvas.drawPoints(ui.PointMode.polygon, [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft, rect.topLeft], kEditorPaint);
      // // }

      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   final list = Float32List.fromList([
      //     rect.topLeft.dx,
      //     rect.topLeft.dx,
      //     rect.topRight.dx,
      //     rect.topRight.dy,
      //     rect.bottomRight.dx,
      //     rect.bottomRight.dy,
      //     rect.bottomLeft.dx,
      //     rect.bottomLeft.dy,
      //     rect.topLeft.dx,
      //     rect.topLeft.dx,
      //   ]);
      //   vertices.add(list);
      // }

      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   final list = Float32List.fromList([
      //     rect.topLeft.dx,
      //     rect.topLeft.dx,
      //     rect.topRight.dx,
      //     rect.topRight.dy,
      //     rect.bottomRight.dx,
      //     rect.bottomRight.dy,
      //     rect.bottomLeft.dx,
      //     rect.bottomLeft.dy,
      //     rect.topLeft.dx,
      //     rect.topLeft.dx,
      //   ]);

      //   vertices2.add(ui.Vertices.raw(VertexMode.triangles, list));
      // }

      // 118ms 卡死
      // final path = Path();
      // for (int i = 0; i < count; i++) {
      //   final rect = Rect.fromLTWH(-100, -100, 200, 200);
      //   path.addRect(rect);
      // }
      // paths.add(path);

      // innerCanvas.drawPath(globalPath, kEditorPaint);
    }, "Compute");

    Benchmark.run(() {
      for (final path in world.paths) {
        innerCanvas.drawPath(path, kEditorPaint);
      }

      for (final list in world.vertices) {
        innerCanvas.drawRawPoints(ui.PointMode.polygon, list, kEditorPaint);
      }

      for (final list in world.vertices2) {
        innerCanvas.drawVertices(list, BlendMode.clear, kEditorPaint);
      }

      // for (final item in world.cellNameDependency.values) {
      //   innerCanvas.drawPath(item.path, kEditorPaint);

      //   // for (final text in item.textParagraphs) {
      //   //   innerCanvas.drawParagraph(text.paragraph, text.offset);
      //   // }
      // }
    }, "Paint");

    grid.paint(innerCanvas, size);
    axis.paint(innerCanvas, size);

    final p = pr.endRecording();

    // Benchmark.run(() {
    //   canvas.drawImage(image, Offset.zero, Paint());

    //   // canvas.drawRawPoints(image, Offset.zero, Paint());
    // }, "drawImage");

    Benchmark.run(() {
      canvas.drawPicture(p);
    }, "drawPicture");
  }
}

class Grid extends BaseCustomPainter {
  Grid({required this.dotGap, required this.dotSize, required this.world});

  final double dotGap;

  final double dotSize;

  final World world;

  final Paint _paint = Paint();

  void renderGrid(Canvas canvas) {
    final gap = world.viewport.getLogicSize(dotGap);

    final visibleWorldRect = world.viewport.visibleWorldRect;
    final dots = createGridDots(visibleWorldRect, gap);
    final strokeWidth = world.viewport.getLogicSize(dotSize);

    _paint.strokeWidth = strokeWidth;
    canvas.drawPoints(ui.PointMode.points, dots, _paint);
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
  void paint(ui.Canvas canvas, ui.Size size) {
    renderGrid(canvas);
  }
}

class Axis extends BaseCustomPainter {
  Axis({required this.axisLength, required this.axisWidth, required this.world});

  final double axisLength;

  final double axisWidth;

  final World world;

  final Paint _paint = Paint()..color = kEditorAxisColor;

  void renderAxis(Canvas canvas) {
    final double strokeWidth = world.viewport.getLogicSize(axisWidth);
    final double length = world.viewport.getLogicSize(axisLength);

    _paint.strokeWidth = strokeWidth;

    canvas.drawLine(Offset(-length, 0), Offset(length, 0), _paint);
    canvas.drawLine(Offset(0, -length), Offset(0, length), _paint);
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    renderAxis(canvas);
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
