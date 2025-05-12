import 'dart:math';
import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layers/layers.dart';

import 'base_business_graphic.dart';

class PathBusinessGraphic extends BaseBusinessGraphic {
  PathBusinessGraphic({required this.vertices, required this.layer, required this.halfWidth}) {
    Offset leftTop = vertices.first * kEditorUnits;
    Offset rightBottom = vertices.first * kEditorUnits;

    for (final vertex in vertices.sublist(1)) {
      final renderVertex = vertex * kEditorUnits;
      leftTop = Offset(min(leftTop.dx, renderVertex.dx), min(leftTop.dy, renderVertex.dy));
      rightBottom = Offset(max(rightBottom.dx, renderVertex.dx), max(rightBottom.dy, renderVertex.dy));
      _renderVertices.add(renderVertex);
    }

    _renderAabb = Rect.fromPoints(leftTop, rightBottom);
  }

  final List<Offset> vertices;

  final Layer layer;

  final double halfWidth;

  final List<Offset> _renderVertices = [];

  late Rect _renderAabb;

  @override
  PolylineGraphic? toGraphic(world) {
    if (!world.canSee(_renderAabb)) return null;

    return PolylineGraphic(vertices: vertices);
  }
}
