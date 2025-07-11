// import 'package:blueprint_master/extensions/extensions.dart';
// import 'package:blueprint_master/layouts/cubits/cubits.dart';
// import 'package:flutter/material.dart';

// import '../editors.dart';
// import '../graphics/base_graphic.dart';
// import 'state_machines.dart';

// class RectangleStateMachine extends BaseStateMachine {
//   RectangleStateMachine({required this.world});

//   final World world;

//   late _DrawState _state = _DrawInitState(this);

//   late final _RectangleDraftComponent _component = _RectangleDraftComponent();

//   @override
//   void onTapDown(TapDownDetails info) {
//     world;
//     // if (!game.world.contains(_component)) game.world.add(_component);
//     // super.onTapDown(info);
//     // _state.onTapDown(info);
//   }

//   @override
//   void onMouseMove(PointerHoverInfo info) {
//     super.onMouseMove(info);
//     _state.onMouseMove(info);
//   }

//   @override
//   void done() {
//     super.done();

//     final rectangle = RectangleShape.fromRect(_component.rect!);
//     game.world.add(rectangle);

//     _component.reset();
//     game.world.remove(_component);

//     _state = _DrawInitState(this);
//   }

//   @override
//   void exit() {
//     super.exit();

//     if (game.world.contains(_component)) {
//       _component.reset();
//       game.world.remove(_component);
//     }

//     drawCubit.enterSelection();
//   }
// }

// class _DrawState {
//   _DrawState(this.stateMachine);

//   final RectangleStateMachine stateMachine;

//   StateMachineGame get game => stateMachine.game;

//   _RectangleDraftComponent get component => stateMachine._component;

//   void onTapDown(TapDownInfo info) {}

//   void onMouseMove(PointerHoverInfo info) {}
// }

// class _DrawInitState extends _DrawState {
//   _DrawInitState(super.stateMachine);

//   @override
//   void onTapDown(TapDownInfo info) {
//     super.onTapDown(info);

//     final Vector2 position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
//     component.start = position;
//     component.end = position;

//     stateMachine._state = _DrawStartedState(stateMachine);
//   }
// }

// class _DrawStartedState extends _DrawInitState {
//   _DrawStartedState(super.stateMachine);

//   @override
//   void onTapDown(TapDownInfo info) {
//     stateMachine.done();
//   }

//   @override
//   void onMouseMove(PointerHoverInfo info) {
//     super.onMouseMove(info);
//     final position = game.camera.viewfinder.globalToLocal(info.eventPosition.widget);
//     component.end = position;
//   }
// }

// class _RectangleDraftComponent extends Component with HasGameRef<EditorGame> {
//   _RectangleDraftComponent();

//   Vector2? start;

//   Vector2? end;

//   Rect? get rect => start != null && end != null ? Rect.fromPoints(start!.toOffset(), end!.toOffset()) : null;

//   final Paint _paint =
//       Paint()
//         ..style = PaintingStyle.stroke
//         ..color = Colors.black;

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     if (start == null || end == null) return;

//     _paint.strokeWidth = game.camera.viewfinder.getLogicSize(1);
//     final Rect rect = Rect.fromPoints(start!.toOffset(), end!.toOffset());
//     canvas.drawRect(rect, _paint);
//   }

//   void reset() {
//     start = null;
//     end = null;
//   }
// }
