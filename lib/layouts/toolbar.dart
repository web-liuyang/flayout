import 'package:flutter/material.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    // final DrawCubit drawCubit = context.watch<DrawCubit>();
    print("_ToolBarState");

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () {}, isSelected: false, icon: const Icon(Icons.north_west), tooltip: "Selection"),
        IconButton(onPressed: () {}, isSelected: true, icon: const Icon(Icons.rectangle_outlined), tooltip: "Rectange"),
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
