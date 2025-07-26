import 'dart:ui';

import 'package:flayout/editors/graphics/base_graphic.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayerPalette {
  const LayerPalette({
    this.outlineWidth = 1,
    this.outlineColor = const Color(0xFF000000),
  });

  final double outlineWidth;

  final Color outlineColor;

  LayerPalette copyWith({double? outlineWidth, Color? outlineColor}) {
    return LayerPalette(
      outlineWidth: outlineWidth ?? this.outlineWidth,
      outlineColor: outlineColor ?? this.outlineColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LayerPalette) return false;
    return outlineWidth == other.outlineWidth && outlineColor == other.outlineColor;
  }

  @override
  int get hashCode => outlineWidth.hashCode ^ outlineColor.hashCode;
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

  LayersCubitState({required this.layers, this.current});

  LayersCubitState copyWith({List<Layer>? layers, Object? current = freeze}) {
    return LayersCubitState(
      layers: layers ?? this.layers,
      current: current == freeze ? this.current : current as Layer?,
    );
  }
}

class LayersCubit extends Cubit<LayersCubitState> {
  LayersCubit(super.initialState);

  List<Layer> get layers => state.layers;

  Layer? get current => state.current;

  Map<String, Paint> paints = {};

  List<Layer> filteredLayers(String title) {
    return layers.where((item) => item.name.contains(title)).toList();
  }

  void setCurrent(Layer layer) {
    if (layer == state.current) return;
    emit(state.copyWith(current: layer));
  }

  void addLayer(Layer layer) {
    if (layers.any((item) => item == layer)) return;
    emit(state.copyWith(layers: [...state.layers, layer]));
  }

  Paint getPaint(Layer layer, Context context) {
    final paint = paints[layer.id] ??= Paint();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = context.viewport.getLogicSize(layer.palette.outlineWidth);
    paint.color = layer.palette.outlineColor;
    return paint;
  }

  bool contains(String name) {
    return layers.any((item) => item.name == name);
  }

  void removeLayer(Layer layer) {
    final int index = layers.indexOf(layer);
    if (index < 0) return;
    final current = layers[index] == this.current ? null : this.current;
    emit(state.copyWith(layers: layers.removedAt(index), current: current));
  }

  void updateLayer(Layer layer) {
    paints = {};
    final int index = layers.indexOf(layer);
    if (index < 0) return;
    emit(state.copyWith(layers: layers.replacedAt(index, layer)));
  }
}

final LayersCubit layersCubit = LayersCubit(
  LayersCubitState(
    layers: [] ?? [
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
