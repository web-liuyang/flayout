import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayerPalette {
  const LayerPalette({
    this.outlineWidth = 1,
    this.outlineColor = const Color(0xFF000000),
    this.fillColor = const Color(0xFFFFFFFF),
  });

  final double outlineWidth;

  final Color outlineColor;

  final Color fillColor;

  LayerPalette copyWith({double? outlineWidth, Color? outlineColor, Color? fillColor}) {
    return LayerPalette(
      outlineWidth: outlineWidth ?? this.outlineWidth,
      outlineColor: outlineColor ?? this.outlineColor,
      fillColor: fillColor ?? this.fillColor,
    );
  }
}

class Layer {
  Layer({required this.name, required this.layer, required this.datatype, this.palette = const LayerPalette()});

  String name;

  int layer;

  int datatype;

  String get id => "$name-$layer-$datatype";

  LayerPalette palette;

  Layer copyWith({String? name, int? layer, int? datatype, LayerPalette? palette}) {
    return Layer(
      name: name ?? this.name,
      layer: layer ?? this.layer,
      datatype: datatype ?? this.datatype,
      palette: palette ?? this.palette,
    );
  }
}

const Object freeze = Object();

class LayersCubitState {
  List<Layer> layers;

  Layer? current;

  LayersCubitState({required this.layers, this.current}) {
    current ??= layers.firstOrNull;
  }

  LayersCubitState copyWith({Object? current = freeze, List<Layer>? layers}) {
    return LayersCubitState(
      current: current == freeze ? this.current : current as Layer?,
      layers: layers ?? this.layers,
    );
  }
}

class LayersCubit extends Cubit<LayersCubitState> {
  LayersCubit(super.initialState) {
    setLayers(state.layers);
  }

  List<Layer> get layers => state.layers;

  Layer? get current => state.current;

  Map<String, Paint> paints = {};

  void setCurrent(Layer layer) {
    emit(state.copyWith(current: layer));
  }

  void setLayers(List<Layer> layers) {
    paints = {};
    for (final item in layers) {
      paints[item.id] ??= Paint();
      final paint = paints[item.id]!;
      if (paint.strokeWidth != item.palette.outlineWidth) paint.strokeWidth = item.palette.outlineWidth;
      if (paint.color != item.palette.outlineColor) paint.color = item.palette.outlineColor;
      if (paint.color != item.palette.fillColor) paint.color = item.palette.fillColor;
    }

    emit(state.copyWith(layers: layers));
  }
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
