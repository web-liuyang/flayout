import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:flame/components.dart';

final a = Aabb2.minMax(Vector2(0, 0), Vector2.all(500));

class PolygonShape extends PolygonComponent with HasVisibility {
  PolygonShape(
    super.vertices, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
    super.key,
    super.shrinkToBounds,
  });

  @override
  bool get isVisible {
    // return vertices.any(a.containsVector2);

    return false;
  }
}
