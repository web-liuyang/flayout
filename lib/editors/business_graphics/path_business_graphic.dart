import 'dart:ui';

import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';
import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/layers/layers.dart';

import 'base_business_graphic.dart';

class PathBusinessGraphic extends BaseBusinessGraphic {
  PathBusinessGraphic({required this.vertices, required this.layer, required this.halfWidth});

  final List<Offset> vertices;

  final Layer layer;

  final double halfWidth;

  // PolylineGraphic? cache;

  // @override
  // PolylineGraphic? toGraphic() {
  //   cache ??= PolylineGraphic(graphic: this, halfWidth: halfWidth, vertices: vertices);
  //   return cache!;
  // }

  Path? path;

  Path getPath() {
    final path = Path();
    final [first, ...remining] = vertices;
    Offset renderVertex = first * kEditorUnits;
    path.moveTo(renderVertex.dx, renderVertex.dy);
    for (final vertex in remining) {
      Offset renderVertex = vertex * kEditorUnits;
      path.lineTo(renderVertex.dx, renderVertex.dy);
    }

    return path;
  }

  final List<Offset> _vertices = [];

  void updateVertices() {
    // final path = Path();

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
    // collection.path.moveTo(first.dx, first.dy);
    // for (final vertex in remining) {
    //   collection.path.lineTo(vertex.dx, vertex.dy);
    // }

    // return Path();
    // if (path == null) {
    //   print("Path Create");
    //   path = getPath();
    // } else {
    //   print("Path Cache");
    // }

    path ??= getPath();
    dependency.path.addPath(path!, Offset.zero);
    return path!;
  }
}
