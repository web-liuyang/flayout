import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  void onChanged(EditorContext editorContext, List<BaseGraphic> graphics) {
    editorContext.selectedGraphicsNotifier.value = graphics;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([editorManager.currentEditorNotifier]),
      builder: (context, child) {
        final EditorContext? editorContext = editorManager.currentEditor?.context;
        return Column(
          children: [
            Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("Properties")])),
            Divider(height: 1),
            if (editorContext != null)
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([editorContext.selectedGraphicsNotifier]),
                  builder: (context, child) {
                    final graphics = editorContext.selectedGraphics;
                    if (graphics.isEmpty) return Container();
                    final rectangleGraphics = graphics.whereType<RectangleGraphic>().toList(growable: false);
                    final polygonGraphics = graphics.whereType<PolygonGraphic>().toList(growable: false);
                    final circleGraphics = graphics.whereType<CircleGraphic>().toList(growable: false);
                    return Column(
                      children: [
                        if (rectangleGraphics.isNotEmpty)
                          Expanded(
                            child: _RectanglePropertyPane(
                              graphics: rectangleGraphics,
                              onChanged: (graphics) => onChanged(editorContext, graphics),
                            ),
                          ),
                        if (polygonGraphics.isNotEmpty) Expanded(child: _PolygonPropertyPane(graphics: polygonGraphics)),
                        if (circleGraphics.isNotEmpty)
                          Expanded(
                            child: _CirclePropertyPane(
                              graphics: circleGraphics,
                              onChanged: (graphics) => onChanged(editorContext, graphics),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
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

class _CirclePropertyPane extends StatefulWidget {
  const _CirclePropertyPane({required this.graphics, required this.onChanged});

  final List<CircleGraphic> graphics;

  final ValueSetter<List<CircleGraphic>> onChanged;

  @override
  _CirclePropertyPaneState createState() => _CirclePropertyPaneState();
}

class _CirclePropertyPaneState extends State<_CirclePropertyPane> {
  bool isExpandedLocations = true;

  void onChanged(List<CircleGraphic> graphics) {
    widget.onChanged(graphics);
  }

  void onChangedCenter(Offset center) {
    widget.graphics.first.center = center;
    onChanged(widget.graphics);
  }

  void onChangedRadius(double radius) {
    widget.graphics.first.radius = radius;
    onChanged(widget.graphics);
  }

  @override
  Widget build(BuildContext context) {
    final CircleGraphic graphic = widget.graphics.first;
    final decoration = BoxDecoration(border: Border(top: Divider.createBorderSide(context)));

    return SingleChildScrollView(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            if (panelIndex == 0) isExpandedLocations = isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: isExpandedLocations,
            headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Locations")),
            body: Container(
              decoration: decoration,
              padding: EdgeInsets.all(8),
              child: Column(
                spacing: 8,
                children: [
                  CellTile(
                    title: "Center:",
                    trailing: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: InputBox(
                            defaultValue: "${graphic.center.dx}",
                            onAction: (String value) => onChangedCenter(Offset(double.parse(value), graphic.center.dy)),
                          ),
                        ),
                        Expanded(
                          child: InputBox(
                            defaultValue: "${graphic.center.dy}",
                            onAction: (String value) => onChangedCenter(Offset(graphic.center.dx, double.parse(value))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CellTile(
                    title: "Radius:",
                    trailing: InputBox(
                      defaultValue: "${graphic.radius}",
                      onAction: (String value) => onChangedRadius(double.parse(value)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RectanglePropertyPane extends StatefulWidget {
  const _RectanglePropertyPane({required this.graphics, required this.onChanged});

  final List<RectangleGraphic> graphics;

  final ValueSetter<List<RectangleGraphic>> onChanged;

  @override
  _RectanglePropertyPaneState createState() => _RectanglePropertyPaneState();
}

class _RectanglePropertyPaneState extends State<_RectanglePropertyPane> {
  bool isExpandedLocations = true;

  void onChanged(List<RectangleGraphic> graphics) {
    widget.onChanged(graphics);
  }

  void onChangedPosition(Offset position) {
    widget.graphics.first.position = position;
    onChanged(widget.graphics);
  }

  void onChangedWidth(double width) {
    widget.graphics.first.width = width;
    onChanged(widget.graphics);
  }

  void onChangedHeight(double height) {
    widget.graphics.first.height = height;
    onChanged(widget.graphics);
  }

  @override
  Widget build(BuildContext context) {
    final RectangleGraphic graphic = widget.graphics.first;
    final decoration = BoxDecoration(border: Border(top: Divider.createBorderSide(context)));

    return SingleChildScrollView(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            if (panelIndex == 0) isExpandedLocations = isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: isExpandedLocations,
            headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Locations")),
            body: Container(
              decoration: decoration,
              padding: EdgeInsets.all(8),
              child: Column(
                spacing: 8,
                children: [
                  CellTile(
                    title: "Position:",
                    trailing: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: InputBox(
                            defaultValue: "${graphic.position.dx}",
                            onAction: (String value) => onChangedPosition(Offset(double.parse(value), graphic.position.dy)),
                          ),
                        ),
                        Expanded(
                          child: InputBox(
                            defaultValue: "${graphic.position.dy}",
                            onAction: (String value) => onChangedPosition(Offset(graphic.position.dx, double.parse(value))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CellTile(
                    title: "Width:",
                    trailing: InputBox(
                      defaultValue: "${graphic.width}",
                      onAction: (String value) => onChangedWidth(double.parse(value)),
                    ),
                  ),
                  CellTile(
                    title: "Height:",
                    trailing: InputBox(
                      defaultValue: "${graphic.height}",
                      onAction: (String value) => onChangedHeight(double.parse(value)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
