import 'dart:ui' hide kEditorTextStyle;

import 'package:flayout/editors/editor_config.dart';
import 'package:flayout/layers/layers.dart';

import 'base_business_graphic.dart';

class TextBusinessGraphic extends BaseBusinessGraphic {
  TextBusinessGraphic({required this.position, required this.text, required this.layer});

  final Offset position;

  final String text;

  final Layer layer;

  // TextGraphic? cache;

  // @override
  // TextGraphic? toGraphic(world) {
  //   cache ??= TextGraphic(graphic: this, position: _renderPosition, text: text, paragraph: _renderParagraph);
  //   return cache;
  // }

  TextParagraph? textParagraph;

  TextParagraph getTextParagraph() {
    final paragraph =
        (ParagraphBuilder(ParagraphStyle())
              ..pushStyle(kEditorTextStyle)
              ..addText(text))
            .build()
          ..layout(ParagraphConstraints(width: double.infinity));
    return TextParagraph(paragraph: paragraph, offset: position * kEditorUnits);
  }

  @override
  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath) {
  Path collect(Collection collection) {
    final Dependency dependency = collection.layerDependency[layer] ??= Dependency.empty();
    textParagraph ??= getTextParagraph();
    dependency.textParagraphs.add(textParagraph!);

    return Path();
  }
}
