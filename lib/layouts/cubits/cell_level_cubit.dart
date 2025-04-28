import 'package:flutter_bloc/flutter_bloc.dart';

class Range<T> {
  Range({required this.min, required this.max});

  T min;

  T max;

  Range<T> clone() {
    return Range(min: min, max: max);
  }
}

class CellLevelCubit extends Cubit<Range<int>> {
  CellLevelCubit(Range<int> initialState) : super(initialState) {
    this.initialState = initialState.clone();
  }

  late final Range<int> initialState;

  void setMin(int min) {
    state.min = min;
    emit(state);
  }

  void setMax(int max) {
    state.max = max;
    emit(state);
  }

  void reset() {
    emit(initialState.clone());
  }
}

final CellLevelCubit cellLevelCubit = CellLevelCubit(Range(min: 0, max: 100));
