import 'dart:ui';

import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/cubits.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../editors/graphics/graphics.dart';

class Cell {
  const Cell({required this.name, required this.graphic});

  final String name;

  final RootGraphic graphic;
}

class CellsCubitState {
  CellsCubitState({required this.cells, this.current});

  List<Cell> cells;

  Cell? current;

  CellsCubitState copyWith({List<Cell>? cells, Object? current = freeze}) {
    return CellsCubitState(
      cells: cells ?? this.cells,
      current: current == freeze ? this.current : current as Cell?,
    );
  }
}

class CellsCubit extends Cubit<CellsCubitState> {
  CellsCubit(super.initialState);

  List<Cell> get cells => state.cells;

  Cell? get current => state.current;

  List<Cell> filteredCells(String title) {
    return cells.where((item) => item.name.contains(title)).toList();
  }

  void addCell(Cell cell) {
    if (cells.any((item) => item == cell)) return;
    emit(state.copyWith(cells: [...state.cells, cell]));
  }

  void removeCell(Cell cell) {
    final int index = cells.indexOf(cell);
    if (index < 0) return;
    emit(state.copyWith(cells: cells.removedAt(index)));
  }

  Cell? findCell(String name) {
    return cells.firstWhereOrNull((item) => item.name == name);
  }

  void setCurrent(Cell cell) {
    if (cell == current) return;
    emit(state.copyWith(current: cell));
  }

  bool contains(String name) {
    return state.cells.any((item) => item.name == name);
  }
}

final CellsCubit cellsCubit = CellsCubit(
  CellsCubitState(
    cells: [
      Cell(
        name: "Cell_1",
        graphic: RootGraphic(
          children: [
            PolygonGraphic(
              layer: layersCubit.current!,
              vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50)],
              close: true,
            ),
            PolygonGraphic(
              layer: layersCubit.current!,
              close: true,
              vertices: [
                Offset(-150, -150),
                Offset(-100, -150),
                Offset(-100, -100),
                Offset(-150, -100),
              ],
            ),
            RectangleGraphic(layer: layersCubit.current!, width: 100, height: 100),
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
    ],
  ),
);
