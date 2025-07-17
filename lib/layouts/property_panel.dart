import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/editors/graphics/base_graphic.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([editorManager.currentEditorNotifier]),
      builder: (context, child) {
        final editorContext = editorManager.currentEditor?.context;
        if (editorContext == null) return Container();

        return ListenableBuilder(
          listenable: Listenable.merge([editorContext.selectedGraphicsNotifier]),
          builder: (context, child) {
            final graphics = editorContext.selectedGraphics;
            if (graphics.isEmpty) return Container();
            final polygonGraphics = graphics.whereType<PolygonGraphic>().toList(growable: false);
            return Column(children: [Text('Properties'), Expanded(child: _PolygonPropertyPane(graphics: polygonGraphics))]);
          },
        );
      },
    );
  }
}

class _PolygonPropertyPane extends StatefulWidget {
  const _PolygonPropertyPane({required this.graphics});

  final List<PolygonGraphic> graphics;

  @override
  _PolygonPropertyPaneState createState() => _PolygonPropertyPaneState();
}

class _PolygonPropertyPaneState extends State<_PolygonPropertyPane> {
  bool isExpandedVertices = true;

  bool isExpandedLocations = true;

  @override
  Widget build(BuildContext context) {
    final PolygonGraphic graphic = widget.graphics.first;
    final decoration = BoxDecoration(border: Border(top: Divider.createBorderSide(context)));

    return SingleChildScrollView(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            if (panelIndex == 0) isExpandedVertices = isExpanded;
            if (panelIndex == 1) isExpandedLocations = isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: isExpandedVertices,
            headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Vertices")),
            body: Container(
              decoration: decoration,
              padding: EdgeInsets.all(8),
              child: Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{0: FixedColumnWidth(32), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
                children: <TableRow>[
                  TableRow(children: [TableCell(child: Text("#")), TableCell(child: Text("X")), TableCell(child: Text("Y"))]),
                  for (final (index, item) in graphic.vertices.indexed)
                    TableRow(children: [TableCell(child: Text("$index")), TableCell(child: Text("${item.dx}")), TableCell(child: Text("${item.dy}"))]),
                ],
              ),
            ),
          ),
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: isExpandedLocations,
            headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Locations")),
            body: Container(decoration: decoration, child: Text("Locations Content")),
          ),
        ],
      ),
    );
  }
}
