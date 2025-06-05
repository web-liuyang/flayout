import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';

import 'base_graphic.dart';

class TextGraphic extends BaseGraphic {
  TextGraphic({required super.graphic, super.position, required this.text, required this.paragraph});

  final String text;

  final Paragraph paragraph;

  @override
  void paint(Canvas canvas, Size size) {
    // final paragraph =
    //     (ParagraphBuilder(ParagraphStyle())
    //           ..pushStyle(kEditorTextStyle)
    //           ..addText(text))
    //         .build()
    //       ..layout(ParagraphConstraints(width: double.infinity));

    // final offset = position * kEditorUnits;
    canvas.drawParagraph(paragraph, position);
  }
}
