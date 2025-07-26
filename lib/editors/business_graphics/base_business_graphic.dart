import 'dart:ui';

import 'package:flayout/layers/layers.dart';

class TextParagraph {
  TextParagraph({required this.paragraph, required this.offset});

  final Paragraph paragraph;

  final Offset offset;
}

class Dependency {
  Dependency.empty() : path = Path(), textParagraphs = [];

  Dependency({required this.path, required this.textParagraphs});

  final Path path;

  final List<TextParagraph> textParagraphs;
}

class Collection {
  Collection();

  Map<Layer, Dependency> layerDependency = {};

  final Map<String, Dependency> cellNameDependency = {};
}

abstract class BaseBusinessGraphic {
  BaseBusinessGraphic();

  // BaseGraphic? toGraphic();

  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath);
  Path collect(Collection collection);
}
