import 'dart:ui';

import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../editors/graphics/graphics.dart';

class Cell {
  const Cell({required this.name, required this.graphic});

  final String name;

  final RootGraphic graphic;
}

class CellsCubit extends Cubit<List<Cell>> {
  CellsCubit(super.initialState);

  List<Cell> filtered(String title) {
    return state.where((item) => item.name.contains(title)).toList();
  }

  void add(Cell cell) {
    emit([...state, cell]);
  }

  Cell? find(String name) {
    return state.firstWhereOrNull((item) => item.name == name);
  }

  bool contains(String name) {
    return state.any((item) => item.name == name);
  }
}

final CellsCubit cellsCubit = CellsCubit([
  Cell(
    name: "Cell_1",
    graphic: RootGraphic(
      children: [
        PolygonGraphic(
          layer: layersCubit.current!,
          vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50), Offset(-50, -50)],
        ),
        PolygonGraphic(
          layer: layersCubit.current!,
          vertices: [
            Offset(-150, -150),
            Offset(-100, -150),
            Offset(-100, -100),
            Offset(-150, -100),
            Offset(-150, -150),
          ],
        ),
      ],
    ),
  ),
  Cell(
    name: "Cell_2",
    graphic: RootGraphic(
      children: [
        PolygonGraphic(
          layer: layersCubit.current!,
          vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50), Offset(-50, -50)],
        ),
        CircleGraphic(layer: layersCubit.current!, center: Offset(0, 0), radius: 50),
      ],
    ),
  ),
]);
