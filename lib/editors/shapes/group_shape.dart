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
}
