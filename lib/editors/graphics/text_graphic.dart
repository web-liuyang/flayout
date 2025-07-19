import 'dart:ui';

import 'base_graphic.dart';

class TextGraphic extends BaseGraphic {
  TextGraphic({required super.position, required this.text, required this.paragraph});

  final String text;

  final Paragraph paragraph;

  @override
  void paint(Context ctx, Offset offset) {
    // final paragraph =
    //     (ParagraphBuilder(ParagraphStyle())
    //           ..pushStyle(kEditorTextStyle)
    //           ..addText(text))
    //         .build()
    //       ..layout(ParagraphConstraints(width: double.infinity));

    // final offset = position * kEditorUnits;

    ctx.canvas.drawParagraph(paragraph, position + offset);
  }

  @override
  bool contains(Offset position) {
    return false;
  }

  @override
  TextGraphic clone() {
    return TextGraphic(position: position, text: text, paragraph: paragraph);
  }

  @override
  Rect aabb() {
    return Rect.fromLTWH(position.dx, position.dy, paragraph.width, paragraph.height);
  }
}
