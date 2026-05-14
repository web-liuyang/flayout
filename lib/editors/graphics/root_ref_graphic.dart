import 'dart:math';
import 'dart:ui';

import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:flutter/rendering.dart';

import 'base_graphic.dart';
import 'root_graphic.dart';

class RootRefGraphic extends BaseGraphic {
  RootRefGraphic({
    required super.position,
    required this.name,
    required this.vMirror,
    required this.magnification,
    required this.angle,
  });

  final bool vMirror;

  final num magnification;

  final num angle;

  String name;

  RootGraphic? _graphic;

  @override
  void paint(Context ctx, Offset offset) {
    final cell = cellsCubit.cells.firstWhere((cell) => cell.name == name);
    _graphic = cell.graphic;

    ctx.canvas.save();

    // GDSII SRef 变换：V' = T(pos) * S_mirror * R_angle * S_mag * V
    // 使用从左到右的调用顺序，避免平移被旋转/缩放污染。
    ctx.canvas.translate(offset.dx + position.dx, offset.dy + position.dy);
    if (vMirror) {
      ctx.canvas.scale(1, -1);
    }
    ctx.canvas.rotate(angle * pi / 180);
    ctx.canvas.scale(magnification.toDouble(), magnification.toDouble());

    _graphic!.paint(ctx, Offset.zero);
    ctx.canvas.restore();
  }

  @override
  bool contains(Offset position) {
    return _graphic?.contains(position) ?? false;
  }

  @override
  RootRefGraphic clone() {
    return RootRefGraphic(position: position, name: name, vMirror: vMirror, magnification: magnification, angle: angle);
  }

  @override
  Rect aabb() {
    final aabb = _graphic?.aabb() ?? Rect.zero;
    return aabb;
  }
}
