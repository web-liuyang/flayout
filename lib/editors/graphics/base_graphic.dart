import 'dart:math';

import 'package:flayout/editors/editor.dart';
import 'package:flayout/editors/editor_config.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

import '../../layouts/cubits/layers_cubit.dart';

class Viewport {
  Viewport();

  Size size = Size.zero;

  void setSize(Size size) {
    if (size == this.size) return;
    this.size = size;
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

  /// 平面坐标系的矩阵
  Matrix4Transform matrix4 = Matrix4Transform();

  /// 屏幕坐标系 转换到 平面坐标系的矩阵。
  ///
  /// 在每次渲染时重新赋值
  Matrix4Transform transform = Matrix4Transform();

  void setZoom(double zoom, {Offset? origin}) {
    final newZoom = zoom.clamp(kMinZoom, kMaxZoom);
    matrix4 = matrix4.setZoom(newZoom, origin: origin);
  }

  void zoomIn(Offset origin) {
    final zoom = getZoom() + 0.1;
    setZoom(zoom, origin: origin);
  }

  void zoomOut(Offset origin) {
    final zoom = getZoom() - 0.1;
    setZoom(zoom, origin: origin);
  }

  double getZoom() {
    return max(matrix4.m.entry(0, 0), matrix4.m.entry(1, 1));
  }

  void translate(Offset offset) {
    matrix4 = matrix4.translate(x: offset.dx, y: offset.dy);
  }

  Offset getTranslation() {
    return matrix4.getTranslation();
  }

  double getLogicSize(double size) {
    final zoom = getZoom();
    return switch (zoom) {
      < 1.0 => size / ((zoom * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => size / zoom.floorToDouble(),
      double() => throw UnimplementedError("zoom: $zoom"),
    };
  }

  Offset windowToCanvas(Offset position) {
    // 获取当前的变换矩阵
    final m = matrix4.m;

    // 取出平移和缩放分量
    final tx = m[12];
    final ty = m[13];
    final scaleX = m[0];
    final scaleY = m[5];

    // 先减去平移，再除以缩放，得到平面坐标
    final x = (position.dx - tx) / scaleX;
    final y = ((size.height - position.dy) - ty) / scaleY;

    return Offset(x, y);
  }

  bool canSee(Rect rect) {
    final worldRect = visibleWorldRect;
    return worldRect.overlaps(rect);
  }
}

class Context {
  final EditorContext context;

  final PaintingContext paintingContext;

  Canvas get canvas => paintingContext.canvas;

  Viewport get viewport => context.viewport;

  const Context({required this.paintingContext, required this.context});
}

abstract class BaseGraphic {
  BaseGraphic({this.position = Offset.zero, this.layer});

  Offset position;

  Layer? layer;

  void paint(Context ctx, Offset offset);

  bool contains(Offset position);

  BaseGraphic clone();

  Rect aabb();
}
