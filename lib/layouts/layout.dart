import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/extensions/list_extension.dart';
import 'package:blueprint_master/layouts/canvas_area.dart';
import 'package:blueprint_master/layouts/menubar.dart';
import 'package:blueprint_master/layouts/resource_panel.dart';
import 'package:blueprint_master/layouts/statusbar.dart';
import 'package:blueprint_master/layouts/toolbar.dart';
import 'package:blueprint_master/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart' hide Axis;
import 'cubits/cubits.dart';
import 'property_panel.dart';

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
        Container(child: Menubar(), alignment: Alignment.centerLeft),
        Divider(height: 1),
        Container(child: Toolbar()),
        Divider(height: 1),
        Expanded(
          child: Splitter(
            axis: Axis.horizontal,
            items: [
              SplitterItem(child: ResourcePanel(), min: 100, size: 300),
              SplitterItem(child: CanvasArea(), min: 100),
              SplitterItem(child: PropertyPanel(), min: 100, size: 300),
            ],
          ),
        ),

        Divider(height: 1),
        Container(child: Statusbar()),
      ],
    );
  }
}
