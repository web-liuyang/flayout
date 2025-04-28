import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:flame/components.dart';

class PolylineShape extends ShapeComponent with HasVisibility, HasGameReference<EditorGame> {
  PolylineShape(
    this.vertices, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.paint,
    super.paintLayers,
  }) {
    _path = Path();
    _path.moveTo(vertices[0].x, vertices[0].y);
    for (int i = 1; i < vertices.length; i++) {
      _path.lineTo(vertices[i].x, vertices[i].y);
    }

    _absoluteRect = toAbsoluteRect();
  }

  final List<Vector2> vertices;

  late Path _path;

  late Rect _absoluteRect;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, paint);
    super.render(canvas);
  }

  @override
  bool get isVisible {
    // final canSee = game.camera.canSee(this);
    final canSee = game.camera.visibleWorldRect.overlaps(_absoluteRect);
    return canSee;
  }
}
