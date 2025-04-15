import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart';
import '../editors/state_machines/state_machines.dart';
import 'cubits/cubits.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // //
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
          child: MultiBlocProvider(providers: [BlocProvider.value(value: drawCubit)], child: ToolBar()),
        ),
        Expanded(
          child: Row(
            children: [
              Container(decoration: BoxDecoration(border: Border(right: BorderSide(width: 1))), child: ResourcePanel()),
              Expanded(child: MultiBlocProvider(providers: [BlocProvider.value(value: drawCubit)], child: Editor())),
              Container(decoration: BoxDecoration(border: Border(left: BorderSide(width: 1))), child: PropertyPanel()),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1))),
          child: MultiBlocProvider(providers: [BlocProvider.value(value: mouseCubit), BlocProvider.value(value: zoomCubit)], child: StatusBar()),
        ),
      ],
    );
  }
}

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    final DrawCubit drawCubit = context.watch<DrawCubit>();
    // print("_ToolBarState");

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //
        IconButton(
          onPressed: drawCubit.enterSelection,
          isSelected: drawCubit.state is SelectionStateMachine,
          icon: const Icon(Icons.north_west),
          tooltip: "Selection",
        ),
        IconButton(
          onPressed: drawCubit.enterRectangle,
          isSelected: drawCubit.state is RectangleStateMachine,
          icon: const Icon(Icons.rectangle_outlined),
          tooltip: "Rectange",
        ),
        IconButton(onPressed: drawCubit.enterPolygon, isSelected: drawCubit.state is PolygonStateMachine, icon: const Icon(Icons.tab), tooltip: "Polygon"),
      ],
    );
  }
}

class ResourcePanel extends StatefulWidget {
  const ResourcePanel({super.key});

  @override
  State<ResourcePanel> createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Resource Panel"));
  }
}

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Property Panel"));
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    final MouseCubit mouseCubit = context.watch<MouseCubit>();
    final ZoomCubit scaleCubit = context.watch<ZoomCubit>();

    final Vector2 mousePosition = mouseCubit.state;
    final String zoomPercentage = scaleCubit.percentage();

    return Center(
      child: Row(
        children: [
          Text("$mousePosition"),
          TextButton(
            onPressed: () {
              scaleCubit.reset();
            },
            child: Text(zoomPercentage),
          ),
        ],
      ),
    );
  }
}
