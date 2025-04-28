import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';

class PolygonShape extends PolygonComponent with HasVisibility, HasGameReference<EditorGame> {
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
  }) {
    _absoluteRect = toAbsoluteRect();
  }

  late Rect _absoluteRect;

  @override
  bool get isVisible {
    // final range = cellLevelCubit.state;
    // if (priority < range.min || priority > range.max) return false;

    final canSee = game.camera.canSee(this);
    // final canSee = game.camera.visibleWorldRect.overlaps(_absoluteRect);
    return canSee;
  }
}
