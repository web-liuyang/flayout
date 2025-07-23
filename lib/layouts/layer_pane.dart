import 'package:blueprint_master/editors/editor_config.dart';
import 'package:blueprint_master/layouts/cubits/layers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/widgets.dart';

class EditableLayerPalette {
  const EditableLayerPalette({required this.outlineWidth, required this.outlineColor});

  final String outlineWidth;

  final Color outlineColor;

  EditableLayerPalette copyWith({String? outlineWidth, Color? outlineColor}) {
    return EditableLayerPalette(
      outlineWidth: outlineWidth ?? this.outlineWidth,
      outlineColor: outlineColor ?? this.outlineColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditableLayerPalette) return false;
    return outlineWidth == other.outlineWidth && outlineColor == other.outlineColor;
  }

  @override
  int get hashCode => outlineWidth.hashCode ^ outlineColor.hashCode;
}

class EditableLayer {
  EditableLayer({
    // required this.origin,
    required this.name,
    required this.layer,
    required this.datatype,
    required this.palette,
  });

  // final Layer origin;

  final String name;

  final String layer;

  final String datatype;

  final EditableLayerPalette palette;

  EditableLayer copyWith({String? name, String? layer, String? datatype, EditableLayerPalette? palette}) {
    return EditableLayer(
      // origin: origin,
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
    final List<Layer> filteredLayers = layersCubit.filteredLayers(searchValue);
    final Layer? current = layersCubit.current;

    return Column(
      children: [
        LayerPaneToolbar(current: current),
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
              final Layer item = filteredLayers[index];
              final String title = item.name;
              return ListTile(
                title: Text(title),
                selected: current == item,
                onTap: () => layersCubit.setCurrent(item),
              );
            },
            itemCount: filteredLayers.length,
          ),
        ),
      ],
    );
  }
}

class LayerPaneToolbar extends StatefulWidget {
  const LayerPaneToolbar({super.key, required this.current});

  final Layer? current;

  @override
  State<LayerPaneToolbar> createState() => _LayerPaneToolbarState();
}

class _LayerPaneToolbarState extends State<LayerPaneToolbar> {
  Future<void> showLayerSettings() async {
    // await LayerSettingsDialog.show(context);
  }

  Future<void> createLayer() async {
    final LayersCubit layersCubit = context.read<LayersCubit>();
    final Layer? newLayer = await CreateLayerDialog.show(context);
    if (newLayer == null) return;

    layersCubit.addLayer(newLayer);
    layersCubit.setCurrent(newLayer);
  }

  Future<void> deleteLayer(Layer layer) async {
    final LayersCubit layersCubit = context.read<LayersCubit>();
    layersCubit.removeLayer(layer);
  }

  Future<void> updateLayer(Layer layer) async {
    final LayersCubit layersCubit = context.read<LayersCubit>();
    final Layer? newLayer = await UpdateLayerDialog.show(context, layer);
    if (newLayer == null) return;
    layer
      ..name = newLayer.name
      ..layer = newLayer.layer
      ..datatype = newLayer.datatype
      ..palette = newLayer.palette;

    layersCubit.updateLayer(layer);

    // await LayerSettingsDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Layers Settings",
      child: Row(
        children: [
          Tooltip(
            message: "Create Layer",
            child: IconButton(icon: Icon(Icons.add_box_outlined), onPressed: createLayer),
          ),
          Tooltip(
            message: "Delete Layer",
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: widget.current != null ? () => deleteLayer(widget.current!) : null,
            ),
          ),
          Tooltip(
            message: "Update Layer",
            child: IconButton(
              icon: Icon(Icons.create),
              onPressed: widget.current != null ? () => updateLayer(widget.current!) : null,
            ),
          ),
          // IconButton(icon: Icon(Icons.settings), onPressed: showLayerSettings),
        ],
      ),
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
    required this.onDelete,
  });

  final List<EditableLayer> layers;

  final int currentIndex;

  final ValueSetter<int> onChangedCurrentIndex;

  final VoidCallback onAdd;

  final VoidCallback onDelete;

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
              IconButton(onPressed: widget.onDelete, icon: Icon(Icons.delete)),
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

class LayerEditor extends StatefulWidget {
  const LayerEditor({super.key, required this.value, required this.onChanged, required this.onError});

  final EditableLayer value;

  final ValueSetter<EditableLayer> onChanged;

  final ValueSetter<bool> onError;

  @override
  State<LayerEditor> createState() => _LayerEditorState();
}

class _LayerEditorState extends State<LayerEditor> {
  late final TextEditingController nameController = TextEditingController(text: widget.value.name);
  late final TextEditingController layerController = TextEditingController(text: widget.value.layer.toString());
  late final TextEditingController datatypeController = TextEditingController(text: widget.value.datatype.toString());
  late final TextEditingController outlineWidthController = TextEditingController(
    text: widget.value.palette.outlineWidth.toString(),
  );

  late Color outlineColor = widget.value.palette.outlineColor;

  String? nameErrorText;

  String? layerErrorText;

  String? datatypeErrorText;

  String? outlineWidthErrorText;

  bool get isError =>
      nameErrorText != null ||
      nameController.text.isEmpty ||
      layerErrorText != null ||
      layerController.text.isEmpty ||
      datatypeErrorText != null ||
      datatypeController.text.isEmpty ||
      outlineWidthErrorText != null ||
      outlineWidthController.text.isEmpty;

  @override
  void didUpdateWidget(covariant LayerEditor oldWidget) {
    if (nameController.text != widget.value.name) nameController.text = widget.value.name;
    if (layerController.text != widget.value.layer) layerController.text = widget.value.layer;
    if (datatypeController.text != widget.value.datatype) datatypeController.text = widget.value.datatype;
    if (outlineWidthController.text != widget.value.palette.outlineWidth.toString()) {
      outlineWidthController.text = widget.value.palette.outlineWidth.toString();
    }
    if (outlineColor != widget.value.palette.outlineColor) outlineColor = widget.value.palette.outlineColor;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    nameController.dispose();
    layerController.dispose();
    datatypeController.dispose();
    outlineWidthController.dispose();
    super.dispose();
  }

  String? validateName(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Layer name cannot be empty";

    final bool contains = layersCubit.contains(value);
    if (contains) return "Layer name already exists";

    return null;
  }

  String? validateLayer(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Layer number cannot be empty";

    final layer = int.tryParse(value);
    if (layer == null) return "Invalid layer number";

    final datatype = int.tryParse(datatypeController.text);
    if (datatype == null) return "Invalid datatype";

    final bool contains = layersCubit.layers.any((item) => layer == item.layer && datatype == item.datatype);
    if (contains) return "Layer number and datatype already exists";

    return null;
  }

  String? validateDatatype(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Layer datatype cannot be empty";

    final datatype = int.tryParse(value);
    if (datatype == null) return "Invalid datatype";

    final layer = int.tryParse(layerController.text);
    if (layer == null) return "Invalid layer number";

    final bool contains = layersCubit.layers.any((item) => layer == item.layer && datatype == item.datatype);
    if (contains) return "Layer number and datatype already exists";

    return null;
  }

  String? validateOutlineWidth(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Outline width cannot be empty";

    final width = double.tryParse(value);
    if (width == null || width <= 0) return "Invalid outline width";

    return null;
  }

  void onActionName(String value) {
    final String? errorText = validateName(value);
    setState(() => nameErrorText = errorText);
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(name: value));
  }

  void onActionLayer(String value) {
    setState(() {
      layerErrorText = validateLayer(value);
      datatypeErrorText = validateDatatype(datatypeController.text);
    });
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(layer: value));
  }

  void onActionDatatype(String value) {
    setState(() {
      layerErrorText = validateLayer(layerController.text);
      datatypeErrorText = validateDatatype(value);
    });
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(datatype: value));
  }

  void onActionOutlineWidth(String value) {
    final String? errorText = validateOutlineWidth(value);
    setState(() => outlineWidthErrorText = errorText);
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(palette: widget.value.palette.copyWith(outlineWidth: value)));
  }

  void onActionOutlineColor(Color value) {
    setState(() => outlineColor = value);
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(palette: widget.value.palette.copyWith(outlineColor: value)));
  }

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
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Layer Name",
                suffixIcon: nameErrorText != null ? Tooltip(message: nameErrorText, child: Icon(Icons.error)) : null,
              ),
              onAction: onActionName,
            ),
          ),
          CellTile(
            title: "Layer:",
            trailing: InputBox(
              controller: layerController,
              decoration: InputDecoration(
                hintText: "Layer Number",
                suffixIcon: layerErrorText != null ? Tooltip(message: layerErrorText, child: Icon(Icons.error)) : null,
              ),
              onAction: onActionLayer,
            ),
          ),
          CellTile(
            title: "Datatype:",
            trailing: InputBox(
              controller: datatypeController,
              decoration: InputDecoration(
                hintText: "Layer Datatype",
                suffixIcon:
                    datatypeErrorText != null ? Tooltip(message: datatypeErrorText, child: Icon(Icons.error)) : null,
              ),
              onAction: onActionDatatype,
            ),
          ),
          CellTile(
            title: "Outline Width:",
            trailing: InputBox(
              controller: outlineWidthController,
              decoration: InputDecoration(
                hintText: "Outline Width",
                suffixIcon:
                    outlineWidthErrorText != null
                        ? Tooltip(message: outlineWidthErrorText, child: Icon(Icons.error))
                        : null,
              ),
              onAction: onActionOutlineWidth,
            ),
          ),
          CellTile(
            title: "Outline Color:",
            trailing: ColorSelector(
              value: outlineColor,
              colors: kEditorDrawingColors,
              onChanged: onActionOutlineColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateLayerDialog extends StatefulWidget {
  const CreateLayerDialog({super.key});

  static Future<Layer?> show(BuildContext context) {
    return showDialog<Layer>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateLayerDialog(),
    );
  }

  @override
  State<CreateLayerDialog> createState() => _CreateLayerDialogState();
}

class _CreateLayerDialogState extends State<CreateLayerDialog> {
  EditableLayer layer = EditableLayer(
    name: "",
    layer: "",
    datatype: "",
    palette: EditableLayerPalette(outlineWidth: "1", outlineColor: Colors.black),
  );

  bool isError = true;

  void confirm() {
    final Layer newLayer = Layer(
      name: layer.name,
      layer: int.parse(layer.layer),
      datatype: int.parse(layer.datatype),
      palette: LayerPalette(
        outlineWidth: double.parse(layer.palette.outlineWidth),
        outlineColor: layer.palette.outlineColor,
      ),
    );

    Navigator.pop(context, newLayer);
  }

  void onError(bool value) => setState(() => isError = value);

  void onChanged(EditableLayer value) => setState(() => layer = value);

  @override
  Widget build(BuildContext context) {
    return LayoutDialog(
      title: "Create Cell",
      constraints: BoxConstraints.tightFor(width: 400),
      onConfirmed: isError ? null : confirm,
      child: LayerEditor(value: layer, onChanged: onChanged, onError: onError),
    );
  }
}

class UpdateLayerDialog extends StatefulWidget {
  const UpdateLayerDialog({super.key, required this.layer});

  final Layer layer;

  static Future<Layer?> show(BuildContext context, Layer layer) {
    return showDialog<Layer>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateLayerDialog(layer: layer),
    );
  }

  @override
  State<UpdateLayerDialog> createState() => _UpdateLayerDialogState();
}

class _UpdateLayerDialogState extends State<UpdateLayerDialog> {
  late EditableLayer layer = EditableLayer(
    name: widget.layer.name,
    layer: widget.layer.layer.toString(),
    datatype: widget.layer.datatype.toString(),
    palette: EditableLayerPalette(
      outlineWidth: widget.layer.palette.outlineWidth.toString(),
      outlineColor: widget.layer.palette.outlineColor,
    ),
  );

  bool isError = false;

  void confirm() {
    final Layer newLayer = Layer(
      name: layer.name,
      layer: int.parse(layer.layer),
      datatype: int.parse(layer.datatype),
      palette: LayerPalette(
        outlineWidth: double.parse(layer.palette.outlineWidth),
        outlineColor: layer.palette.outlineColor,
      ),
    );

    Navigator.pop(context, newLayer);
  }

  void onError(bool value) => setState(() => isError = value);

  void onChanged(EditableLayer value) => setState(() => layer = value);

  @override
  Widget build(BuildContext context) {
    return LayoutDialog(
      title: "Create Cell",
      constraints: BoxConstraints.tightFor(width: 400),
      onConfirmed: isError ? null : confirm,
      child: LayerEditor(value: layer, onChanged: onChanged, onError: onError),
    );
  }
}
