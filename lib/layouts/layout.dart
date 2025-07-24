import 'package:blueprint_master/layouts/canvas_area.dart';
import 'package:blueprint_master/layouts/menubar.dart';
import 'package:blueprint_master/layouts/resource_panel.dart';
import 'package:blueprint_master/layouts/statusbar.dart';
import 'package:blueprint_master/layouts/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Menubar(),
        Divider(height: 1),
        Toolbar(),
        Divider(height: 1),
        Expanded(
          child: MultiSplitView(
            initialAreas: [
              Area(
                min: 100,
                size: 300,
                builder: (context, area) {
                  return Container(
                    decoration: BoxDecoration(border: Border(right: Divider.createBorderSide(context))),
                    child: ResourcePanel(),
                  );
                },
              ),
              Area(
                flex: 1,
                builder: (context, area) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(vertical: Divider.createBorderSide(context)),
                    ),
                    child: CanvasArea(),
                  );
                },
              ),
              Area(
                min: 100,
                size: 300,
                builder: (context, area) {
                  return Container(
                    decoration: BoxDecoration(border: Border(left: Divider.createBorderSide(context))),
                    child: PropertyPanel(),
                  );
                },
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Statusbar(),
      ],
    );
  }
}
