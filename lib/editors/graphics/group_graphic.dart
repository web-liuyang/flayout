import 'dart:ui';

import 'package:flutter/rendering.dart';

import 'base_graphic.dart';

class GroupGraphic extends BaseGraphic {
  GroupGraphic({super.position, this.children = const []});

  final List<BaseGraphic> children;

  void addChild(BaseGraphic child) {
    children.add(child);
  }

  void removeChild(BaseGraphic child) {
    children.remove(child);
  }

  @override
  void paint(Context ctx, Offset offset) {
    // ctx.canvas.save();
    // ctx.canvas.translate(position.dx, position.dy);

    for (final child in children) {
      child.paint(ctx, offset + position);
    }

    // ctx.canvas.restore();
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
  GroupGraphic clone() {
    return GroupGraphic(position: position, children: children.map((e) => e.clone()).toList());
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
