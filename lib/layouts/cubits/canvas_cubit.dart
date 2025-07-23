import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubitState {
  const CanvasCubitState({
    required this.position,
    required this.zoom,
  });

  final Offset position;

  final double zoom;

  CanvasCubitState copyWith({Offset? position, double? zoom}) {
    return CanvasCubitState(
      position: position ?? this.position,
      zoom: zoom ?? this.zoom,
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
}

final CanvasCubit canvasCubit = CanvasCubit(
  const CanvasCubitState(
    position: Offset.zero,
    zoom: 1.0,
  ),
);
