import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/widgets.dart';
import 'cubits/cubits.dart';

class ResourcePanel extends StatefulWidget {
  const ResourcePanel({super.key});

  @override
  State<ResourcePanel> createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  final TextEditingController controller = TextEditingController();
  String get searchValue => controller.text;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResourcePanelBlocProvider(
      builder: (context) {
        final filteredCells = context.watch<CellsCubit>().filtered(searchValue);
        return Column(
          children: [
            Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("Resources")])),
            Divider(height: 1),
            ResourceToolbar(),
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
                  final title = filteredCells[index].name;
                  return ListTile(
                    title: Text(title),
                    onTap: () {
                      editorManager.createEditor(EditorConfig(title: title));
                    },
                  );
                },
                itemCount: filteredCells.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ResourcePanelBlocProvider extends StatelessWidget {
  const ResourcePanelBlocProvider({super.key, required this.builder});

  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cellsCubit),
      ],
      child: Builder(builder: (context) => builder(context)),
    );
  }
}

class ResourceToolbar extends StatefulWidget {
  const ResourceToolbar({super.key});

  @override
  State<ResourceToolbar> createState() => _ResourceToolbarState();
}

class _ResourceToolbarState extends State<ResourceToolbar> {
  Future<void> createCell() async {
    final String? cellName = await CreateCellDialog.show(context);
    if (cellName == null) return;
    cellsCubit.add(Cell(name: cellName, graphic: RootGraphic(children: [])));
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [IconButton(icon: Icon(Icons.add_box_outlined), onPressed: createCell)]);
  }
}

class CreateCellDialog extends StatefulWidget {
  const CreateCellDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const CreateCellDialog(),
    );
  }

  @override
  State<CreateCellDialog> createState() => _CreateCellDialogState();
}

class _CreateCellDialogState extends State<CreateCellDialog> {
  final TextEditingController controller = TextEditingController();

  String? cellNameErrorText;

  bool get isError => cellNameErrorText != null;

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
    return LayoutDialog(
      title: "Create Cell",
      constraints: BoxConstraints.tightFor(width: 400),
      onConfirmed: isError ? null : confirm,
      child: Column(
        spacing: 8,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Text("Cell Name:"),
                Expanded(
                  child: InputBox(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Cell Name",
                      suffixIcon:
                          cellNameErrorText != null
                              ? Tooltip(
                                message: cellNameErrorText,
                                child: Icon(Icons.error),
                              )
                              : null,
                    ),
                    onAction: onActionCellName,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // onClosed: () => setState(() {}),
    );
  }
}
