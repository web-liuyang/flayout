import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';

class TextShape<T extends TextRenderer> extends TextComponent<T> with HasVisibility, HasGameReference<EditorGame> {
  TextShape({super.text, super.textRenderer, super.position, super.size, super.scale, super.angle, super.anchor, super.children, super.priority, super.key}) {
    _absoluteRect = toAbsoluteRect();
    _length = text.length;
    _width = _absoluteRect.width;
    _height = _absoluteRect.height;
  }

  late Rect _absoluteRect;
  late int _length;
  late double _width;
  late double _height;

  @override
  bool get isVisible {
    final zoom = zoomCubit.state;
    if (_width / _length * zoom < 2) return false;
    if (_height * zoom < 1) return false;

    // final canSee = game.camera.canSee(this);
    final canSee = game.camera.visibleWorldRect.overlaps(_absoluteRect);
    return canSee;
  }
}
