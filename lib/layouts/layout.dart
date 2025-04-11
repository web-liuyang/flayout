import 'package:flutter/material.dart';

import '../editors/editors.dart';

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
        //
        Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))), child: ToolBar()),
        Expanded(
          child: Row(
            children: [
              Container(decoration: BoxDecoration(border: Border(right: BorderSide(width: 1))), child: ResourcePanel()),
              Expanded(child: Editor()),
              Container(decoration: BoxDecoration(border: Border(left: BorderSide(width: 1))), child: PropertyPanel()),
            ],
          ),
        ),
        Container(decoration: BoxDecoration(border: Border(top: BorderSide(width: 1))), child: StatusBar()),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //
        IconButton(onPressed: () {}, icon: const Icon(Icons.north_west)),
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
    return Center(child: Text("Status Bar"));
  }
}
