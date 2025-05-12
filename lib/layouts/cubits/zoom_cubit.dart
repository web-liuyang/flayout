import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
// import 'package:flame/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZoomCubit extends Cubit<double> {
  ZoomCubit(this.initialState) : super(initialState);

  late final double initialState;

  void update(double zoom) {
    emit(zoom);
  }

  String percentage() {
    return "${(state * 100).toInt()}%";
  }

  void zoomAt(double newZoom, Offset pivot, Offset worldOffset) {
    // drawCubit.game.camera.viewfinder.zoomAt(newZoom, pivot, worldOffset);
    // zoomCubit.update(newZoom);
  }

  double getLogicSize(double value) {
    return switch (state) {
      < 1.0 => value / ((state * kMaxZoom).floorToDouble() / kMaxZoom),
      >= 1.0 => value / state.floorToDouble(),
      double() => throw UnimplementedError(),
    };
  }

  void reset() {
    // final Vector2 pivot = drawCubit.game.camera.visibleWorldRect.center.toVector2();
    // final Vector2 worldOffset = drawCubit.game.size / 2;
    // zoomAt(initialState, pivot, worldOffset);
  }
}

final ZoomCubit zoomCubit = ZoomCubit(1);
// final ZoomCubit zoomCubit = ZoomCubit(0.06);
