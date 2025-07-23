import 'dart:ui';

import 'package:blueprint_master/editors/graphics/base_graphic.dart';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LayerPalette) return false;
    return outlineWidth == other.outlineWidth && outlineColor == other.outlineColor && fillColor == other.fillColor;
  }

  @override
  int get hashCode => outlineWidth.hashCode ^ outlineColor.hashCode ^ fillColor.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Layer) return false;
    return name == other.name && layer == other.layer && datatype == other.datatype;
  }

  @override
  int get hashCode => name.hashCode ^ layer.hashCode ^ datatype.hashCode ^ palette.hashCode;

  @override
  String toString() {
    return 'Layer{name: $name, layer: $layer, datatype: $datatype, palette: $palette}';
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
    state.current ??= state.layers.firstOrNull;
  }

  List<Layer> get layers => state.layers;

  Layer? get current => state.current;

  Map<String, Paint> paints = {};

  void setCurrent(Layer layer) {
    if (layer == state.current) return;
    emit(state.copyWith(current: layer));
  }

  void setLayers(List<Layer> layers) {
    if (layers == state.layers) return;
    paints = {};
    emit(state.copyWith(layers: layers));
  }

  Paint getPaint(Layer layer, Context context) {
    final paint = paints[layer.id] ??= Paint();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = context.viewport.getLogicSize(layer.palette.outlineWidth);
    paint.color = layer.palette.outlineColor;
    return paint;
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
