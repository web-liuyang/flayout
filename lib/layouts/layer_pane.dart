import 'package:blueprint_master/layouts/cubits/layers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../widgets/widgets.dart';
import 'cubits/cells_cubit.dart';

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
            // suffixIcon: IconButton(onPressed: () => setState(() => controller.text = ""), icon: Icon(Icons.clear)),
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
  const LayerSettingsDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => context.watch<LayersCubit>()),
          ],
          child: LayerSettingsDialog(),
        );
      },
    );
  }

  @override
  State<LayerSettingsDialog> createState() => _LayerSettingsDialogState();
}

class _LayerSettingsDialogState extends State<LayerSettingsDialog> {
  final TextEditingController controller = TextEditingController();

  String? cellNameErrorText;

  bool get isError => cellNameErrorText != null;

  late Layer? current = context.read<LayersCubit>().current;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void confirm() {
    final String cellName = controller.text;
    final bool contains = cellsCubit.contains(cellName);
    if (contains) return;
    Navigator.pop(context, cellName);
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
    final LayersCubit layersCubit = context.watch<LayersCubit>();
    final List<Layer> layers = layersCubit.layers;

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
                  layers: layers,
                  current: current,
                  onChangedCurrent: (value) {
                    setState(() => current = value);
                  },
                ),
              );
            },
          ),
          Area(
            flex: 2,
            builder: (context, area) {
              return Container(
                decoration: BoxDecoration(border: Border(left: Divider.createBorderSide(context))),
                child: LayerEditor(),
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
  const LayerListView({super.key, required this.layers, this.current, required this.onChangedCurrent});

  final List<Layer> layers;

  final Layer? current;

  final ValueSetter<Layer?> onChangedCurrent;

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
    return Column(
      children: [
        InputBox(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            // suffixIcon: IconButton(onPressed: () => setState(() => controller.text = ""), icon: Icon(Icons.clear)),
          ),
          controller: controller,
          onSubmitted: (value) => setState(() => controller.text = value),
        ),
        Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final Layer layer = widget.layers[index];
              final String title = layer.name;
              final bool isSelected = widget.current == layer;
              return ListTile(
                title: Text(title),
                selected: isSelected,
                onTap: () => widget.onChangedCurrent(layer),
              );
            },
            itemCount: widget.layers.length,
          ),
        ),
      ],
    );
  }
}

class LayerEditor extends StatelessWidget {
  const LayerEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
