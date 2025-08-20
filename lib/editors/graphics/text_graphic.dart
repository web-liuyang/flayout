import 'dart:ui';

import 'package:flayout/editors/editor_config.dart';

import 'base_graphic.dart';

class TextGraphic extends BaseGraphic {
  TextGraphic({
    required super.position,
    required super.layer,
    required this.text,
    // required this.paragraph,
  });

  final String text;

  late Paragraph paragraph;

  @override
  void paint(Context ctx, Offset offset) {
    paragraph =
        (ParagraphBuilder(ParagraphStyle())
              ..pushStyle(kEditorTextStyle)
              ..addText(text))
            .build()
          ..layout(ParagraphConstraints(width: double.infinity));

    // final offset = position * kEditorUnits;

    ctx.canvas.drawParagraph(paragraph, position + offset);
    // ctx.canvas.drawParagraph(paragraph, position + offset);
  }

  @override
  bool contains(Offset position) {
    return false;
  }

  @override
  TextGraphic clone() {
    return TextGraphic(position: position, text: text, layer: layer);
  }

  @override
  Rect aabb() {
    return Rect.fromLTWH(position.dx, position.dy, paragraph.width, paragraph.height);
  }
}
