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

  @override
  bool contains(Offset position) {
    for (final child in children) {
      if (child.contains(position)) {
        return true;
      }
    }
    return false;
  }

  @override
  RootGraphic clone() {
    return RootGraphic(children: children.map((e) => e.clone()).toList());
  }
}
