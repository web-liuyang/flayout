import 'package:flame/game.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class MouseCubit extends Cubit<Vector2> {
  MouseCubit() : super(Vector2.zero());

  void update(Vector2 position) {
    emit(position);
  }
}

final MouseCubit mouseCubit = MouseCubit();
