import 'dart:ui';

import 'package:flayout/extensions/extensions.dart';
import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../editors/graphics/graphics.dart';

class Cell {
  Cell({required this.name, required this.graphic});

  String name;

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
    final current = cells[index] == this.current ? null : this.current;
    emit(state.copyWith(cells: cells.removedAt(index), current: current));
  }

  void updateCell(Cell cell) {
    final int index = cells.indexOf(cell);
    if (index < 0) return;
    emit(state.copyWith(cells: cells.replacedAt(index, cell)));
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
    cells:
        [] ??
        [
          Cell(
            name: "Cell_1",
            graphic: RootGraphic(
              children: [
                PolygonGraphic(
                  layer: layersCubit.layers.first,
                  vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50)],
                  close: true,
                ),
                PolygonGraphic(
                  layer: layersCubit.layers.first,
                  close: true,
                  vertices: [
                    Offset(-150, -150),
                    Offset(-100, -150),
                    Offset(-100, -100),
                    Offset(-150, -100),
                  ],
                ),
                RectangleGraphic(layer: layersCubit.layers.first, width: 100, height: 100),
              ],
            ),
          ),
          Cell(
            name: "Cell_2",
            graphic: RootGraphic(
              children: [
                PolygonGraphic(
                  layer: layersCubit.layers.first,
                  close: true,
                  vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50)],
                ),
                CircleGraphic(layer: layersCubit.layers.first, center: Offset(0, 0), radius: 50),
              ],
            ),
          ),
          Cell(
            name: "big Cell_3 10000",
            graphic: RootGraphic(
              children: [
                for (double i = 0; i < 1000_0; i++)
                  PolygonGraphic(
                    layer: layersCubit.layers.first,
                    close: true,
                    position: Offset(i * 50, i * 50),
                    vertices: [
                      Offset(-50, -50),
                      Offset(50, -50),
                      Offset(50, 50),
                      Offset(-50, 50),
                    ],
                  ),
              ],
            ),
          ),
        ],
  ),
);
