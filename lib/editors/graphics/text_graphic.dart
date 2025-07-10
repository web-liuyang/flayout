import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class TextGraphic extends BaseGraphic {
  TextGraphic({required this.position, required this.text, required this.paragraph});

  final Offset position;

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

    ctx.canvas.drawParagraph(paragraph, position);
  }
}
