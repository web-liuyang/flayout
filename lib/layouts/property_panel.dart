import 'package:flayout/editors/editors.dart';
import 'package:flayout/editors/graphics/graphics.dart';
import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:flayout/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("PROPERTIES")])),
            Divider(height: 1),
            if (editorContext != null)
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([editorContext.selectedGraphicsNotifier]),
                  builder: (context, child) {
                    final graphics = editorContext.selectedGraphics;
                    if (graphics.isEmpty) return Container();
                    Widget child = Container();
                    if (graphics.first is RectangleGraphic) {
                      child = _RectanglePropertyPane(
                        graphics: graphics,
                        onChanged: (graphics) => onChanged(editorContext, graphics),
                      );
                    }
                    if (graphics.first is PolygonGraphic) {
                      child = _PolygonPropertyPane(
                        graphics: graphics,
                        onChanged: (graphics) => onChanged(editorContext, graphics),
                      );
                    }
                    if (graphics.first is PolylineGraphic) {
                      child = _PolylinePropertyPane(
                        graphics: graphics,
                        onChanged: (graphics) => onChanged(editorContext, graphics),
                      );
                    }
                    if (graphics.first is CircleGraphic) {
                      child = _CirclePropertyPane(
                        graphics: graphics,
                        onChanged: (graphics) => onChanged(editorContext, graphics),
                      );
                    }

                    return child;
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PolygonPropertyPane extends _BasePropertyPane {
  const _PolygonPropertyPane({required super.graphics, required super.onChanged});

  @override
  _PolygonPropertyPaneState createState() => _PolygonPropertyPaneState();
}

class _PolygonPropertyPaneState extends _BasePropertyPaneState<PolygonGraphic> {
  @override
  List<Offset> get vertices => firstGraphic.vertices;
}

class _PolylinePropertyPane extends _BasePropertyPane {
  const _PolylinePropertyPane({required super.graphics, required super.onChanged});

  @override
  _PolylinePropertyPaneState createState() => _PolylinePropertyPaneState();
}

class _PolylinePropertyPaneState extends _BasePropertyPaneState<PolylineGraphic> {
  @override
  List<Offset> get vertices => firstGraphic.vertices;
}

class _CirclePropertyPane extends _BasePropertyPane {
  const _CirclePropertyPane({required super.graphics, required super.onChanged});

  @override
  _CirclePropertyPaneState createState() => _CirclePropertyPaneState();
}

class _CirclePropertyPaneState extends _BasePropertyPaneState<CircleGraphic> {
  @override
  List<CellTile> locationCellTiles() {
    final graphic = firstGraphic;
    return [
      CellTile(
        title: "Center:",
        trailing: Row(
          spacing: 8,
          children: [
            Expanded(
              child: InputBox(
                value: "${graphic.center.dx}",
                onAction: (String value) => onChangedCenter(Offset(double.parse(value), graphic.center.dy)),
              ),
            ),
            Expanded(
              child: InputBox(
                value: "${graphic.center.dy}",
                onAction: (String value) => onChangedCenter(Offset(graphic.center.dx, double.parse(value))),
              ),
            ),
          ],
        ),
      ),
      CellTile(
        title: "Radius:",
        trailing: InputBox(
          value: "${graphic.radius}",
          onAction: (String value) => onChangedRadius(double.parse(value)),
        ),
      ),
    ];
  }
}

class _RectanglePropertyPane extends _BasePropertyPane {
  const _RectanglePropertyPane({required super.graphics, required super.onChanged});

  @override
  _RectanglePropertyPaneState createState() => _RectanglePropertyPaneState();
}

class _RectanglePropertyPaneState extends _BasePropertyPaneState<RectangleGraphic> {
  @override
  List<CellTile> locationCellTiles() {
    final graphic = firstGraphic;
    return [
      CellTile(
        title: "Width:",
        trailing: InputBox(
          value: "${graphic.width}",
          onAction: (String value) => onChangedWidth(double.parse(value)),
        ),
      ),
      CellTile(
        title: "Height:",
        trailing: InputBox(
          value: "${graphic.height}",
          onAction: (String value) => onChangedHeight(double.parse(value)),
        ),
      ),
    ];
  }
}

abstract class _BasePropertyPane extends StatefulWidget {
  const _BasePropertyPane({required this.graphics, required this.onChanged});

  final List<BaseGraphic> graphics;

  final ValueSetter<List<BaseGraphic>> onChanged;
}

abstract class _BasePropertyPaneState<T extends BaseGraphic> extends State<_BasePropertyPane> {
  bool isExpandedLayers = true;

  bool isExpandedLocations = true;

  bool isExpandedVertices = true;

  List<Offset>? get vertices => null;

  Iterable<T> get graphics => widget.graphics.whereType<T>();

  T get firstGraphic => graphics.first;

  List<CellTile> locationCellTiles() => [];

  void onChanged(List<BaseGraphic> graphics) {
    widget.onChanged(graphics);
  }

  void onChangedLayer(Layer layer) {
    for (final item in widget.graphics) {
      item.layer = layer;
    }
    onChanged(widget.graphics);
  }

  void onChangedPosition(Offset position) {
    for (final item in widget.graphics) {
      item.position = position;
    }
    onChanged(widget.graphics);
  }

  void onChangedWidth(double width) {
    for (final item in widget.graphics) {
      if (item is RectangleGraphic) {
        item.width = width;
      }
    }
    onChanged(widget.graphics);
  }

  void onChangedHeight(double height) {
    for (final item in widget.graphics) {
      if (item is RectangleGraphic) {
        item.height = height;
      }
    }
    onChanged(widget.graphics);
  }

  void onChangedCenter(Offset center) {
    for (final item in widget.graphics) {
      if (item is CircleGraphic) {
        item.center = center;
      }
    }
    onChanged(widget.graphics);
  }

  void onChangedRadius(double radius) {
    for (final item in widget.graphics) {
      if (item is CircleGraphic) {
        item.radius = radius;
      }
    }
    onChanged(widget.graphics);
  }

  void onChangedVertex(Offset vertex, int index) {
    assert(firstGraphic is PolygonGraphic || firstGraphic is PolylineGraphic);

    if (firstGraphic is PolygonGraphic) {
      final verticesLength = (firstGraphic as PolygonGraphic).vertices.length;
      for (final item in widget.graphics) {
        if (item is PolygonGraphic && item.vertices.length == verticesLength) {
          item.vertices[index] = vertex;
        }
      }
      onChanged(widget.graphics);
    }

    if (firstGraphic is PolylineGraphic) {
      final verticesLength = (firstGraphic as PolylineGraphic).vertices.length;
      for (final item in widget.graphics) {
        if (item is PolylineGraphic && item.vertices.length == verticesLength) {
          item.vertices[index] = vertex;
        }
      }
      onChanged(widget.graphics);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LayersCubit layersCubit = context.watch<LayersCubit>();
    final List<Layer> layers = layersCubit.layers;
    final BaseGraphic graphic = widget.graphics.first;
    final BoxDecoration decoration = BoxDecoration(border: Border(top: Divider.createBorderSide(context)));

    return SingleChildScrollView(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            if (panelIndex == 0) isExpandedLayers = isExpanded;
            if (panelIndex == 1) isExpandedLocations = isExpanded;
            if (panelIndex == 2) isExpandedVertices = isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: isExpandedLayers,
            headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Layers")),
            body: Container(
              decoration: decoration,
              padding: EdgeInsets.all(8),
              child: Column(
                spacing: 8,
                children: [
                  CellTile(
                    title: "Layers:",
                    trailing: LayerSelector(value: graphic.layer!, layers: layers, onChanged: onChangedLayer),
                  ),
                ],
              ),
            ),
          ),
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
                            value: "${graphic.position.dx}",
                            onAction:
                                (String value) => onChangedPosition(Offset(double.parse(value), graphic.position.dy)),
                          ),
                        ),
                        Expanded(
                          child: InputBox(
                            value: "${graphic.position.dy}",
                            onAction:
                                (String value) => onChangedPosition(Offset(graphic.position.dx, double.parse(value))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...locationCellTiles(),
                ],
              ),
            ),
          ),
          if (vertices != null)
            ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: isExpandedVertices,
              headerBuilder: (BuildContext context, bool isExpanded) => ListTile(title: Text("Vertices")),
              body: Container(
                decoration: decoration,
                padding: EdgeInsets.all(8),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FixedColumnWidth(32),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text("#")),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text("X"),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text("Y"),
                          ),
                        ),
                      ],
                    ),
                    for (final (index, item) in vertices!.indexed)
                      TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              alignment: Alignment.center,
                              child: Text("$index"),
                            ),
                          ),
                          TableCell(
                            child: InputBox(
                              value: "${item.dx}",
                              decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none)),
                              onAction: (value) => onChangedVertex(Offset(double.parse(value), item.dy), index),
                            ),
                          ),
                          TableCell(
                            child: InputBox(
                              value: "${item.dy}",
                              decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none)),
                              onAction: (value) => onChangedVertex(Offset(item.dx, double.parse(value)), index),
                            ),
                          ),
                        ],
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
