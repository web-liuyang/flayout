import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layers/layers.dart';

import 'base_business_graphic.dart';

class TextBusinessGraphic extends BaseBusinessGraphic {
  TextBusinessGraphic({required this.position, required this.text, required this.layer}) {
    _renderParagraph =
        (ParagraphBuilder(ParagraphStyle())
              ..pushStyle(kEditorTextStyle)
              ..addText(text))
            .build()
          ..layout(ParagraphConstraints(width: double.infinity));

    _renderPosition = position * kEditorUnits;
    _renderAabb = Rect.fromPoints(_renderPosition, Offset(_renderParagraph.width, _renderParagraph.height));
  }

  final Offset position;

  final String text;

  final Layer layer;

  late Paragraph _renderParagraph;

  late Offset _renderPosition;

  late Rect _renderAabb;

  @override
  TextGraphic? toGraphic(world) {
    if (!world.canSee(_renderAabb)) return null;

    return TextGraphic(position: _renderPosition, text: text, paragraph: _renderParagraph);
  }
}
