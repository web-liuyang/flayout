import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayerPalette {
  double outlineWidth = 1;

  int outlineColor = Colors.black.toARGB32();

  int fillColor = Colors.transparent.toARGB32();
}

class Layer {
  Layer({required this.name, required this.layer, required this.datatype, LayerPalette? palette}) {
    this.palette = palette ?? LayerPalette();
  }

  String name;

  int layer;

  int datatype;

  late LayerPalette palette;
}

class LayersCubitState {
  List<Layer> layers;

  Layer? current;

  LayersCubitState({required this.layers, this.current}) {
    current ??= layers.firstOrNull;
  }

  LayersCubitState copyWith({required Layer current}) {
    return LayersCubitState(
      layers: layers,
      current: current,
    );
  }
}

class LayersCubit extends Cubit<LayersCubitState> {
  LayersCubit(super.initialState);

  List<Layer> get layers => state.layers;

  Layer? get current => state.current;

  void setCurrent(Layer layer) {
    emit(state.copyWith(current: layer));
  }

  // void add(Layer cell) {
  //   // emit([...state, cell]);
  // }

  // Layer? find(String name) {
  //   // return state.firstWhereOrNull((item) => item.name == name);
  // }

  // bool contains(String name) {
  //   // return state.any((item) => item.name == name);
  // }
}

final LayersCubit layersCubit = LayersCubit(
  LayersCubitState(
    layers: [
      Layer(
        name: "Layer_1",
        layer: 1,
        datatype: 1,
      ),
      Layer(
        name: "Layer_2",
        layer: 1,
        datatype: 2,
      ),
    ],
  ),
);
