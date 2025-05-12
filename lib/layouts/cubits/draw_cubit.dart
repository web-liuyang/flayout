// import 'package:flame/components.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../editors/editors.dart';
// import '../../editors/state_machines/state_machines.dart';

// final CameraComponent _camera = CameraComponent(world: EditorWorld(), backdrop: Background());
// final EditorGame _editorGame = EditorGame(world: _camera.world, camera: _camera);

// class DrawCubit extends Cubit<BaseStateMachine> {
//   DrawCubit() : super(SelectionStateMachine(_editorGame));

//   StateMachineGame get game => state.game;

//   void enterSelection() {
//     emit(SelectionStateMachine(game));
//   }

//   void enterRectangle() {
//     emit(RectangleStateMachine(game));
//   }

//   void enterPolygon() {
//     emit(PolygonStateMachine(game));
//   }

//   void enterCircle() {
//     emit(CircleStateMachine(game));
//   }
// }

// final DrawCubit drawCubit = DrawCubit();
