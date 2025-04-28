import 'dart:ui';

import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';

class TextShape<T extends TextRenderer> extends TextComponent<T> with HasVisibility, HasGameReference<EditorGame> {
  TextShape({super.text, super.textRenderer, super.position, super.size, super.scale, super.angle, super.anchor, super.children, super.priority, super.key});

  // @override
  // bool get isVisible {
  //   final canSee = game.camera.canSee(this);
  //   return canSee;
  // }

  // @override
  // void render(Canvas canvas) {
  //   final zoom = zoomCubit.state;
  //   if (width * zoom < 1 || height * zoom < 1) {
  //     // print("Hidden");
  //   } else {
  //     super.render(canvas);
  //   }
  // }
}
