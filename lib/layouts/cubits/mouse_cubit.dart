import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

class MouseCubit extends Cubit<Offset> {
  MouseCubit(super.initialState);

  // void update(Vector2 position) {
  //   emit(position);
  // }
}

final MouseCubit mouseCubit = MouseCubit(Offset.zero);
