import 'package:blueprint_master/editors/editors.dart';
import 'package:flutter/material.dart';

import '../editors/state_machines/state_machines.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    // final DrawCubit drawCubit = context.watch<DrawCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            final context = editorManager.currentEditor?.context;
            if (context == null) return;
            context.stateMachine = SelectionStateMachine(context: context);
          },
          isSelected: editorManager.currentEditor?.context.stateMachine is SelectionStateMachine,
          icon: const Icon(Icons.north_west),
          tooltip: "Selection",
        ),
        IconButton(
          onPressed: () {
            final context = editorManager.currentEditor?.context;
            if (context == null) return;
            context.stateMachine = RectangleStateMachine(context: context);
          },
          isSelected: editorManager.currentEditor?.context.stateMachine is RectangleStateMachine,
          icon: const Icon(Icons.rectangle_outlined),
          tooltip: "Rectange",
        ),
        // IconButton(onPressed: drawCubit.enterPolygon, isSelected: drawCubit.state is PolygonStateMachine, icon: const Icon(Icons.tab), tooltip: "Polygon"),
        // IconButton(
        //   onPressed: drawCubit.enterCircle,
        //   isSelected: drawCubit.state is CircleStateMachine,
        //   icon: const Icon(Icons.circle_outlined),
        //   tooltip: "Circle",
        // ),
      ],
    );
  }
}
