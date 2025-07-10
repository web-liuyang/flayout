import 'dart:ui';

import 'package:flutter/rendering.dart';

import 'base_graphic.dart';

class RootGraphic extends BaseGraphic {
  RootGraphic({this.children = const []});

  final List<BaseGraphic> children;

  void addChild(BaseGraphic child) {
    children.add(child);
  }

  void removeChild(BaseGraphic child) {
    children.remove(child);
  }

  @override
  void paint(Context ctx, Offset offset) {
    for (final child in children) {
      child.paint(ctx, offset);
    }
  }
}
