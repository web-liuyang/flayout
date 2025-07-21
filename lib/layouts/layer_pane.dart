import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:blueprint_master/layouts/cubits/layers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../widgets/widgets.dart';
import 'cubits/cells_cubit.dart';

class EditableLayer extends Layer {
  EditableLayer({
    required this.origin,
    required super.name,
    required super.layer,
    required super.datatype,
    required super.palette,
  });

  final Layer origin;

  @override
  EditableLayer copyWith({String? name, int? layer, int? datatype, LayerPalette? palette}) {
    return EditableLayer(
      origin: origin,
      name: name ?? this.name,
      layer: layer ?? this.layer,
      datatype: datatype ?? this.datatype,
      palette: palette ?? this.palette,
    );
  }
}

class LayerPane extends StatefulWidget {
  const LayerPane({super.key});

  @override
  State<LayerPane> createState() => _LayerPaneState();
}

class _LayerPaneState extends State<LayerPane> {
  final TextEditingController controller = TextEditingController();
  String get searchValue => controller.text;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LayersCubit layersCubit = context.watch<LayersCubit>();
    final List<Layer> layers = layersCubit.layers;

    return Column(
      children: [
        LayerPaneToolbar(),
        Divider(height: 1),
        InputBox(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
          ),
          controller: controller,
          onSubmitted: (value) => setState(() => controller.text = value),
        ),
        Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final Layer layer = layers[index];
              final String title = layer.name;
              final bool isSelected = layersCubit.current == layer;
              return ListTile(
                title: Text(title),
                selected: isSelected,
                onTap: () {
                  layersCubit.setCurrent(layer);
                },
              );
            },
            itemCount: layers.length,
          ),
        ),
      ],
    );
  }
}

class LayerPaneToolbar extends StatefulWidget {
  const LayerPaneToolbar({super.key});

  @override
  State<LayerPaneToolbar> createState() => _LayerPaneToolbarState();
}

class _LayerPaneToolbarState extends State<LayerPaneToolbar> {
  Future<void> showLayerSettings() async {
    await LayerSettingsDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [IconButton(icon: Icon(Icons.settings), onPressed: showLayerSettings)]);
  }
}

class LayerSettingsDialog extends StatefulWidget {
  const LayerSettingsDialog({super.key, required this.layers});

  final List<EditableLayer> layers;

  static Future<void> show(BuildContext context) async {
    final layersCubit = context.read<LayersCubit>();
    final layers = layersCubit.layers;

    final editableLayers =
        layers
            .map(
              (layer) => EditableLayer(
                origin: layer,
                name: layer.name,
                layer: layer.layer,
                datatype: layer.datatype,
                palette: layer.palette.copyWith(),
              ),
            )
            .toList();

    final List<EditableLayer>? result = await showDialog<List<EditableLayer>>(
      context: context,
      builder: (_) => LayerSettingsDialog(layers: editableLayers),
    );

    if (result == null) return;

    layersCubit.setLayers(
      result.map((editableLayer) {
        return editableLayer.origin
          ..name = editableLayer.name
          ..layer = editableLayer.layer
          ..datatype = editableLayer.datatype
          ..palette = editableLayer.palette;
      }).toList(),
    );
  }

  @override
  State<LayerSettingsDialog> createState() => _LayerSettingsDialogState();
}

class _LayerSettingsDialogState extends State<LayerSettingsDialog> {
  final TextEditingController controller = TextEditingController();

  String? cellNameErrorText;

  bool get isError => cellNameErrorText != null;

  late List<EditableLayer> editableLayers =
      widget.layers
          .map(
            (layer) => EditableLayer(
              origin: layer,
              name: layer.name,
              layer: layer.layer,
              datatype: layer.datatype,
              palette: layer.palette.copyWith(),
            ),
          )
          .toList();

  late int currentIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void confirm() {
    Navigator.pop<List<EditableLayer>>(context, editableLayers);
  }

  String? validateCellName(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Cell name cannot be empty";

    final bool contains = cellsCubit.contains(value);
    if (contains) return "Cell name already exists";

    return null;
  }

  void onActionCellName(String value) {
    final String? errorText = validateCellName(value);
    setState(() => cellNameErrorText = errorText);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDialog(
      title: "Layer Settings",
      constraints: BoxConstraints.tightFor(width: 600),
      onConfirmed: isError ? null : confirm,
      child: MultiSplitView(
        initialAreas: [
          Area(
            flex: 1,
            builder: (context, area) {
              return Container(
                decoration: BoxDecoration(border: Border(right: Divider.createBorderSide(context))),
                child: LayerListView(
                  layers: editableLayers,
                  currentIndex: currentIndex,
                  onChangedCurrentIndex: (value) {
                    setState(() => currentIndex = value);
                  },
                  onAdd: () {
                    setState(() {
                      final Layer layer = Layer(name: "Layer ${editableLayers.length + 1}", layer: 1, datatype: 1);
                      editableLayers.add(
                        EditableLayer(
                          origin: layer,
                          name: layer.name,
                          layer: layer.layer,
                          datatype: layer.datatype,
                          palette: layer.palette.copyWith(),
                        ),
                      );
                    });
                  },
                ),
              );
            },
          ),
          Area(
            flex: 2,
            builder: (context, area) {
              final current = editableLayers.elementAtOrNull(currentIndex);
              if (current == null) {
                return Center(child: Text("No layer selected"));
              }

              return Container(
                decoration: BoxDecoration(border: Border(left: Divider.createBorderSide(context))),
                child: LayerEditor(
                  value: current,
                  onChanged: (value) {
                    setState(() {
                      editableLayers.replaceAt(currentIndex, value);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      // onClosed: () => setState(() {}),
    );
  }
}

class LayerListView extends StatefulWidget {
  const LayerListView({
    super.key,
    required this.layers,
    required this.currentIndex,
    required this.onChangedCurrentIndex,
    required this.onAdd,
  });

  final List<EditableLayer> layers;

  final int currentIndex;

  final ValueSetter<int> onChangedCurrentIndex;

  final VoidCallback onAdd;

  EditableLayer? get current => layers.elementAtOrNull(currentIndex);

  @override
  State<LayerListView> createState() => _LayerListViewState();
}

class _LayerListViewState extends State<LayerListView> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = widget.layers.where((layer) => layer.name.contains(controller.text)).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: widget.onAdd, icon: Icon(Icons.add_box_outlined)),
            ],
          ),

          InputBox(
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
            ),
            controller: controller,
            onSubmitted: (value) => setState(() => controller.text = value),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final EditableLayer layer = layers[index];
                final String title = layer.name;
                final bool isSelected = widget.current == layer;
                return ListTile(
                  title: Text(title),
                  selected: isSelected,
                  onTap: () => widget.onChangedCurrentIndex(widget.layers.indexOf(layer)),
                );
              },
              itemCount: layers.length,
            ),
          ),
        ],
      ),
    );
  }
}

class LayerEditor extends StatelessWidget {
  const LayerEditor({super.key, required this.value, required this.onChanged});

  final EditableLayer value;

  final ValueSetter<EditableLayer> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        children: [
          CellTile(
            title: "Name:",
            trailing: InputBox(
              value: value.name,
              onAction: (value) => onChanged(this.value.copyWith(name: value)),
            ),
          ),
          CellTile(
            title: "Layer:",
            trailing: InputBox(
              value: "${value.layer}",
              onAction: (value) => onChanged(this.value.copyWith(layer: int.parse(value))),
            ),
          ),
          CellTile(
            title: "Datatype:",
            trailing: InputBox(
              value: "${value.datatype}",
              onAction: (value) => onChanged(this.value.copyWith(datatype: int.parse(value))),
            ),
          ),
          CellTile(
            title: "Outline Width:",
            trailing: InputBox(
              value: "${value.palette.outlineWidth}",
              onAction: (value) {
                onChanged(
                  this.value.copyWith(palette: this.value.palette.copyWith(outlineWidth: double.parse(value))),
                );
              },
            ),
          ),
          CellTile(
            title: "Outline Color:",
            trailing: ColorSelector(
              value: value.palette.outlineColor,
              colors: kEditorDrawingColors,
              onChanged: (value) {
                onChanged(this.value.copyWith(palette: this.value.palette.copyWith(outlineColor: value)));
              },
            ),
          ),
          CellTile(
            title: "Fill Color:",
            trailing: ColorSelector(
              value: value.palette.fillColor,
              colors: kEditorDrawingColors,
              onChanged: (value) {
                onChanged(this.value.copyWith(palette: this.value.palette.copyWith(fillColor: value)));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key, required this.value, required this.colors, required this.onChanged});

  final Color value;

  final List<Color> colors;

  final ValueSetter<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderSide? borderSide = theme.inputDecorationTheme.border?.borderSide;

    return Container(
      decoration: BoxDecoration(
        border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton(
        isExpanded: true,
        isDense: true,
        value: value,
        underline: Container(),
        selectedItemBuilder: (context) => colors.map((color) => Container(color: color)).toList(growable: false),
        items: colors
            .map(
              (color) => DropdownMenuItem(value: color, child: Container(margin: EdgeInsets.all(8), color: color)),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}
