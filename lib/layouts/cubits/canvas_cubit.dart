import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../editors/editor_config.dart';

class CanvasCubitState {
  const CanvasCubitState({
    required this.position,
    required this.zoom,
    required this.grid,
  });

  final Offset position;

  final double zoom;

  final double grid;

  CanvasCubitState copyWith({Offset? position, double? zoom, double? grid}) {
    return CanvasCubitState(
      position: position ?? this.position,
      zoom: zoom ?? this.zoom,
      grid: grid ?? this.grid,
    );
  }
}

class CanvasCubit extends Cubit<CanvasCubitState> {
  CanvasCubit(super.initialState);

  void setPosition(Offset position) {
    if (position == state.position) return;
    emit(state.copyWith(position: position));
  }

  void setZoom(double zoom) {
    if (zoom == state.zoom) return;
    emit(state.copyWith(zoom: zoom));
  }

  void setGrid(double grid) {
    if (grid == state.grid) return;
    emit(state.copyWith(grid: grid));
  }

  void set({Offset? position, double? zoom, double? grid}) {
    emit(state.copyWith(position: position, zoom: zoom, grid: grid));
  }
}

final CanvasCubit canvasCubit = CanvasCubit(
  const CanvasCubitState(
    position: Offset.zero,
    zoom: 1.0,
    grid: kEditorDotGap,
  ),
);
