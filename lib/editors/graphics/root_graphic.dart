import 'dart:ui';

import 'package:flutter/rendering.dart';

import 'base_graphic.dart';

class RootGraphic extends BaseGraphic {
  RootGraphic({required this.name, required this.children});

  String name;

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
    return RootGraphic(name: name, children: children.map((e) => e.clone()).toList());
  }

  @override
  Rect aabb() {
    if (children.isEmpty) return Rect.zero;

    Rect aabb = children.first.aabb();
    for (final child in children.skip(1)) {
      aabb = aabb.expandToInclude(child.aabb());
    }
    return aabb;
  }
}
