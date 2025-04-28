import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';

class GroupShape extends PositionComponent with HasVisibility, HasGameReference<EditorGame> {
  GroupShape({
    //
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  bool get isVisible {
    // game.camera.visibleWorldRect.overlaps(toAbsoluteRect());
    // final intersect = game.camera.visibleWorldRect.intersect(toAbsoluteRect());
    // if (intersect.width <= 0 || intersect.height <= 0) {
    //   print(game.camera.visibleWorldRect);
    //   print(toAbsoluteRect());
    // }
    final canSee = game.camera.canSee(this);
    return canSee;
    return true;
  }

  // @override
  // void updateTree(double dt) {
  //   // TODO: implement updateTree
  //   // super.updateTree(dt);
  // }

  // @override
  // void renderTree(Canvas canvas) {
  //   // TODO: implement renderTree
  //   // super.renderTree(canvas);
  //   final canSee = game.camera.canSee(this);

  //   if (canSee) {
  //     super.renderTree(canvas);
  //   }
  // }
}
