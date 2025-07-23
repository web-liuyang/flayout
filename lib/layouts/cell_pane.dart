import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart';
import '../editors/graphics/graphics.dart';
import '../widgets/widgets.dart';
import 'cubits/cells_cubit.dart';

class CellPane extends StatefulWidget {
  const CellPane({super.key});

  @override
  State<CellPane> createState() => _CellPaneState();
}

class _CellPaneState extends State<CellPane> {
  final TextEditingController controller = TextEditingController();

  String get searchValue => controller.text;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CellsCubit cellsCubit = context.watch<CellsCubit>();
    final List<Cell> filteredCells = cellsCubit.filteredCells(searchValue);
    final Cell? current = cellsCubit.current;

    return Column(
      children: [
        CellPaneToolbar(current: current),
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
              final Cell item = filteredCells[index];
              final String title = item.name;
              return ListTile(
                title: Text(title),
                selected: current == item,
                onTap: () {
                  cellsCubit.setCurrent(item);
                  editorManager.createEditor(EditorConfig(title: title));
                },
              );
            },
            itemCount: filteredCells.length,
          ),
        ),
      ],
    );
  }
}

class CellPaneToolbar extends StatefulWidget {
  const CellPaneToolbar({super.key, this.current});

  final Cell? current;

  @override
  State<CellPaneToolbar> createState() => _CellPaneToolbarState();
}

class _CellPaneToolbarState extends State<CellPaneToolbar> {
  Future<void> createCell() async {
    final String? cellName = await CreateCellDialog.show(context);
    if (cellName == null) return;
    final newCell = Cell(name: cellName, graphic: RootGraphic(children: []));
    cellsCubit.addCell(newCell);
    cellsCubit.setCurrent(newCell);
    editorManager.createEditor(EditorConfig(title: newCell.name));
  }

  void deleteCell() {
    cellsCubit.removeCell(widget.current!);
    editorManager.removeEditor(widget.current!.name);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: "Create Cell",
          child: IconButton(icon: Icon(Icons.add_box_outlined), onPressed: createCell),
        ),
        Tooltip(
          message: "Delete Cell",
          child: IconButton(icon: Icon(Icons.delete), onPressed: widget.current != null ? deleteCell : null),
        ),
      ],
    );
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
