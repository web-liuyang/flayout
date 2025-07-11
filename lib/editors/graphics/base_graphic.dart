import 'dart:math';

import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:vector_math/vector_math_64.dart';

class Viewport {
  Viewport({this.size = Size.zero}) {
    final halfSize = size / 2;
    matrix4 = Matrix4Transform().translate(x: halfSize.width, y: halfSize.height);
  }

  Rect get visibleWorldRect {
    final translation = getTranslation();
    final zoom = getZoom();

    final tx = -translation.dx / zoom;
    final ty = -translation.dy / zoom;

    final width = size.width / zoom;
    final height = size.height / zoom;

    return Rect.fromLTWH(tx, ty, width, height);
  }

  Size size;

  late Matrix4Transform matrix4;

  void setZoom(double zoom, {Offset? origin}) {
    final newZoom = zoom.clamp(kMinZoom, kMaxZoom);
    matrix4 = matrix4.setZoom(newZoom, origin: origin);
  }

  void zoomIn(Offset origin) {
    final zoom = getZoom() + 0.01;
    setZoom(zoom, origin: origin);
  }

  void zoomOut(Offset origin) {
    final zoom = getZoom() - 0.01;
    setZoom(zoom, origin: origin);
  }

  void moveToCenter() {}

  void fitToWindow() {}

  double getLogicSize(double size) {
    final zoom = getZoom();
    return switch (zoom) {
      < 1.0 => size / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => size / zoom.floorToDouble(),
      double() => throw UnimplementedError(),
    };
  }

  Vector3 localToGlobal(Vector3 position) {
    return matrix4.localToGlobal(position);
  }

  Vector3 windowToWorld(Vector3 position) {
    final m = matrix4.m;
    final tx = m[12];
    final ty = m[13];
    final tz = m[14];
    final x = (position.x - tx) / m[0];
    final y = (position.y - ty) / m[5];
    final z = (position.z - tz) / m[10];

    return Vector3(x, y, z);
  }

  double getZoom() {
    return max(matrix4.m.entry(0, 0), matrix4.m.entry(1, 1));
  }

  void translate(Offset offset) {
    matrix4 = matrix4.translate(x: offset.dx, y: offset.dy);
  }

  void setTranslation(Offset offset) {
    matrix4 = Matrix4Transform.from(
      matrix4.matrix4
        ..[4] = offset.dx
        ..[8] = offset.dy,
    );
  }

  Offset getTranslation() {
    return matrix4.getTranslation();
  }

  // void setTranslation(double tx, double ty) {
  //   matrix4.setTranslation(tx, ty);
  // }
}

class World {
  final List<BaseGraphic> _graphics = [];

  void add(BaseGraphic graphic) {
    _graphics.add(graphic);
  }

  void init(Size size) {
    viewport = Viewport(size: size);
  }

  late Viewport viewport;

  late Element context;

  late SceneRenderObject renderObject;

  void render() async {
    print("render");
    renderObject.markNeedsPaint();
  }

  bool canSee(Rect aabb) {
    return viewport.visibleWorldRect.overlaps(aabb);
  }

  bool canSeePoint(Offset offset) {
    return viewport.visibleWorldRect.contains(offset);
  }
}

class Context {
  final World world;

  final PaintingContext paintingContext;

  Canvas get canvas => paintingContext.canvas;

  Viewport get viewport => world.viewport;

  const Context({required this.world, required this.paintingContext});
}

abstract class BaseGraphic {
  BaseGraphic();

  void paint(Context ctx, Offset offset);
}
