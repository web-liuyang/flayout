import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'cell_pane.dart';
import 'layer_pane.dart';

class ResourcePanel extends StatefulWidget {
  const ResourcePanel({super.key});

  @override
  State<ResourcePanel> createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("Resources")])),
        Divider(height: 1),
        Expanded(
          child: MultiSplitView(
            axis: Axis.vertical,
            initialAreas: [
              Area(
                flex: 1,
                builder: (context, area) {
                  return Container(
                    decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
                    child: CellPane(),
                  );
                },
              ),
              Area(
                flex: 1,
                builder: (context, area) {
                  return Container(
                    decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context))),
                    child: LayerPane(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
