import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class RectangleShape extends RectangleComponent {
  RectangleShape({
    super.key,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
  });

  factory RectangleShape.fromRect(
    Rect rect, {
    Vector2? scale,
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
    Paint? paint,
    List<Paint>? paintLayers,
    ComponentKey? key,
    List<Component>? children,
  }) {
    return RectangleShape(
      position:
          anchor == Anchor.topLeft ? rect.topLeft.toVector2() : Anchor.topLeft.toOtherAnchorPosition(rect.topLeft.toVector2(), anchor, rect.size.toVector2()),
      size: rect.size.toVector2(),
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
      paint: paint,
      paintLayers: paintLayers,
      key: key,
      children: children,
    );
  }
}
