import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layers/layers.dart';

import 'base_business_graphic.dart';

class BoundaryBusinessGraphic extends BaseBusinessGraphic {
  BoundaryBusinessGraphic({required this.vertices, required this.layer}) {
    Offset leftTop = vertices.first * kEditorUnits;
    Offset rightBottom = vertices.first * kEditorUnits;
    // final List<Offset> renderVertices = [];
    final List<double> renderVertices = [];
    for (final vertex in vertices.sublist(1)) {
      final renderVertex = vertex * kEditorUnits;
      leftTop = Offset(min(leftTop.dx, renderVertex.dx), min(leftTop.dy, renderVertex.dy));
      rightBottom = Offset(max(rightBottom.dx, renderVertex.dx), max(rightBottom.dy, renderVertex.dy));
      renderVertices.addAll([renderVertex.dx, renderVertex.dy]);
      // renderVertices.add(renderVertex);
    }

    _renderVertices = Float32List.fromList(renderVertices);
    // _renderVertices = renderVertices;
    _renderAabb = Rect.fromPoints(leftTop, rightBottom);
  }

  final List<Offset> vertices;

  final Layer layer;

  // late List<Offset> _renderVertices = [];
  late Float32List _renderVertices;

  late Rect _renderAabb;

  @override
  PolygonGraphic? toGraphic(world) {
    if (!world.canSee(_renderAabb)) return null;

    return PolygonGraphic(vertices: _renderVertices);
  }
}
