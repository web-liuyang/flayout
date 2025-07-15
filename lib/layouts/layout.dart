import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layouts/resource_panel.dart';
import 'package:blueprint_master/layouts/toolbar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart';
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
          // child: MultiBlocProvider(providers: [BlocProvider.value(value: drawCubit)], child: ToolBar()),
          child: Toolbar(),
        ),
        Expanded(
          child: Row(
            children: [
              Container(width: 200, decoration: BoxDecoration(border: Border(right: BorderSide(width: 1))), child: ResourcePanel()),
              // Expanded(child: MultiBlocProvider(providers: [], child: Editor())),
              Expanded(child: DrawingArea()),
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

class DrawingArea extends StatefulWidget {
  const DrawingArea({super.key});

  @override
  DrawingAreaState createState() => DrawingAreaState();
}

class CustomDirectionalFocusAction extends DirectionalFocusAction {
  @override
  void invoke(DirectionalFocusIntent intent) {
    print(intent);
    // super.invoke(intent);
  }
}

final Map<Type, Action<Intent>> actions = {DirectionalFocusIntent: CustomDirectionalFocusAction()};

class DrawingAreaState extends State<DrawingArea> with SingleTickerProviderStateMixin {
  // controller: TabController(length: tabs.length, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: ListenableBuilder(
        listenable: editorManager.tabsNotifier,
        builder: (context, child) {
          final List<EditorTab> tabs = editorManager.tabs;

          return DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                TabBar(tabs: tabs.map((tab) => Text(tab.title)).toList(growable: false)),
                Expanded(child: TabBarView(children: tabs.map((tab) => tab.editor).toList(growable: false))),
              ],
            ),
          );
        },
      ),
    );
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

    // final Vector2 mousePosition = mouseCubit.state;
    final String zoomPercentage = scaleCubit.percentage();

    return Center(
      child: Row(
        children: [
          // Text("$mousePosition"),
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
