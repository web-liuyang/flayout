import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/layers/layers.dart';

import 'base_business_graphic.dart';

class BoundaryBusinessGraphic extends BaseBusinessGraphic {
  BoundaryBusinessGraphic({required this.vertices, required this.layer});

  final List<Offset> vertices;

  final Layer layer;

  // PolygonGraphic? cache;

  // @override
  // PolygonGraphic toGraphic() {
  //   cache ??= PolygonGraphic(graphic: this, vertices: vertices);
  //   return cache!;
  // }

  Path? path;

  Rect? aabb;

  Path getPath() {
    final path = Path();
    final [first, ...remining] = vertices;
    Offset renderVertex = first * kEditorUnits;
    path.moveTo(renderVertex.dx, renderVertex.dy);
    for (final vertex in remining) {
      Offset renderVertex = vertex * kEditorUnits;
      path.lineTo(renderVertex.dx, renderVertex.dy);
    }
    path.close();

    return path;
  }

  final List<Offset> _vertices = [];

  void updateVertices() {
    _vertices.clear();
    for (final vertex in vertices) {
      final renderVertex = vertex * kEditorUnits;
      _vertices.add(renderVertex);
    }
  }

  @override
  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath) {
  Path collect(Collection collection) {
    final Dependency dependency = collection.layerDependency[layer] ??= Dependency.empty();
    // if (_vertices.isEmpty) updateVertices();
    // final [first, ...remining] = _vertices;
    // dependency.path.moveTo(first.dx, first.dy);
    // for (final vertex in remining) {
    //   dependency.path.lineTo(vertex.dx, vertex.dy);
    // }

    // return Path();

    path ??= getPath();

    if (visibleRect.overlaps(path!.getBounds())) {
      path!.getBounds();
      dependency.path.addPath(path!, Offset.zero);
      return path!;
    } else {
      // print("not visible");
      // return path!;
      return Path();
    }

    return path!;
  }

  buildBitmap() {
    double minX = double.maxFinite;
    double minY = double.maxFinite;
    double maxX = -double.maxFinite;
    double maxY = -double.maxFinite;

    for (final vertex in vertices) {
      minX = min(minX, vertex.dx);
      minY = min(minY, vertex.dy);
      maxX = max(maxX, vertex.dx);
      maxY = max(maxY, vertex.dy);
    }

    final int width = (maxX - minX).round();
    final int height = (maxY - minY).round();
    final rect = Rect.fromLTWH(minX, minY, width.toDouble(), height.toDouble());

    final workspace = Uint8ClampedList(width * height * 4);

    for (final vertex in vertices) {
      final x = (vertex.dx - minX).round();
      final y = (vertex.dy - minY).round();
      workspace[y * width * 4 + x * 4] = 255;
      workspace[y * width * 4 + x * 4 + 1] = 255;
      workspace[y * width * 4 + x * 4 + 2] = 255;
      workspace[y * width * 4 + x * 4 + 3] = 255;
    }
  }
}

final visibleRect = Rect.fromLTWH(-300, -300, 600, 600);
