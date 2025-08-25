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
    // print("RootRefGraphic ${name}");
    final cell = cellsCubit.cells.firstWhere((cell) => cell.name == name);
    _graphic = cell.graphic;
    _graphic!.paint(ctx, offset + position);
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
