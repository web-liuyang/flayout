import 'package:blueprint_master/editors/editors.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';

class TextShape<T extends TextRenderer> extends TextComponent<T> with HasVisibility, HasGameReference<EditorGame> {
  TextShape({super.text, super.textRenderer, super.position, super.size, super.scale, super.angle, super.anchor, super.children, super.priority, super.key});

  @override
  bool get isVisible => false;
}
