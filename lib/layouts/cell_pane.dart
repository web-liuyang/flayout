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
        InputBox(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
          ),
          controller: controller,
          onSubmitted: (value) => setState(() => controller.text = value),
        ),
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
                  editorManager.createEditor(EditorConfig(cell: item));
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
  const CellPaneToolbar({super.key, required this.current});

  final Cell? current;

  @override
  State<CellPaneToolbar> createState() => _CellPaneToolbarState();
}

class _CellPaneToolbarState extends State<CellPaneToolbar> {
  Future<void> createCell() async {
    final Cell? cell = await CreateCellDialog.show(context);
    if (cell == null) return;

    cellsCubit.addCell(cell);
    cellsCubit.setCurrent(cell);
    editorManager.createEditor(EditorConfig(cell: cell));
  }

  void deleteCell(Cell cell) {
    cellsCubit.removeCell(cell);
    editorManager.removeEditor(cell.name);
  }

  Future<void> updateCell(Cell cell) async {
    final Cell? newCell = await UpdateCellDialog.show(context, cell);
    if (newCell == null) return;
    final title = cell.name;
    final newTitle = newCell.name;
    cell.name = newCell.name;
    cell.graphic.name = newCell.name;
    cellsCubit.updateCell(cell);
    editorManager.updateEditorTitle(title, newTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text("Cells"))),
        Tooltip(
          message: "Create Cell",
          child: IconButton(icon: Icon(Icons.add_box_outlined), onPressed: createCell),
        ),
        Tooltip(
          message: "Update Cell",
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: widget.current != null ? () => updateCell(widget.current!) : null,
          ),
        ),
        Tooltip(
          message: "Delete Cell",
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: widget.current != null ? () => deleteCell(widget.current!) : null,
          ),
        ),
      ],
    );
  }
}

class EditableCell {
  EditableCell({
    required this.name,
  });

  final String name;

  EditableCell copyWith({String? name}) {
    return EditableCell(
      name: name ?? this.name,
    );
  }
}

class CellEditor extends StatefulWidget {
  const CellEditor({super.key, required this.value, required this.onChanged, required this.onError});

  final EditableCell value;

  final ValueSetter<EditableCell> onChanged;

  final ValueSetter<bool> onError;

  @override
  State<CellEditor> createState() => _CellEditorState();
}

class _CellEditorState extends State<CellEditor> {
  late final TextEditingController nameController = TextEditingController(text: widget.value.name);

  String? nameErrorText;

  bool get isError => nameErrorText != null && nameController.text.isEmpty;

  @override
  void didUpdateWidget(covariant CellEditor oldWidget) {
    if (nameController.text != widget.value.name) nameController.text = widget.value.name;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  String? validateName(String value) {
    final bool isEmpty = value.isEmpty;
    if (isEmpty) return "Cell name cannot be empty";

    final bool contains = cellsCubit.contains(value);
    if (contains) return "Cell name already exists";

    return null;
  }

  void onActionName(String value) {
    final String? errorText = validateName(value);
    setState(() => nameErrorText = errorText);
    widget.onError(isError);
    widget.onChanged(widget.value.copyWith(name: value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Cell Name",
                    suffixIcon:
                        nameErrorText != null ? Tooltip(message: nameErrorText, child: Icon(Icons.error)) : null,
                  ),
                  onAction: onActionName,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CreateCellDialog extends StatefulWidget {
  const CreateCellDialog({super.key});

  static Future<Cell?> show(BuildContext context) {
    return showDialog<Cell>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateCellDialog(),
    );
  }

  @override
  State<CreateCellDialog> createState() => _CreateCellDialogState();
}

class _CreateCellDialogState extends State<CreateCellDialog> {
  EditableCell cell = EditableCell(name: "");

  bool isError = true;

  void confirm() {
    final Cell newCell = Cell(name: cell.name, graphic: RootGraphic(name: cell.name, children: []));
    Navigator.pop(context, newCell);
  }

  void onError(bool value) => setState(() => isError = value);

  void onChanged(EditableCell value) => setState(() => cell = value);

  @override
  Widget build(BuildContext context) {
    return LayoutDialog(
      title: "Create Cell",
      constraints: BoxConstraints.tightFor(width: 400),
      onConfirmed: isError ? null : confirm,
      child: CellEditor(value: cell, onChanged: onChanged, onError: onError),
    );
  }
}

class UpdateCellDialog extends StatefulWidget {
  const UpdateCellDialog({super.key, required this.cell});

  final Cell cell;

  static Future<Cell?> show(BuildContext context, Cell cell) {
    return showDialog<Cell>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateCellDialog(cell: cell),
    );
  }

  @override
  State<UpdateCellDialog> createState() => _UpdateCellDialogState();
}

class _UpdateCellDialogState extends State<UpdateCellDialog> {
  late EditableCell cell = EditableCell(name: widget.cell.name);

  bool isError = false;

  void confirm() {
    final Cell newCell = Cell(name: cell.name, graphic: RootGraphic(name: cell.name, children: []));
    Navigator.pop(context, newCell);
  }

  void onError(bool value) => setState(() => isError = value);

  void onChanged(EditableCell value) => setState(() => cell = value);

  @override
  Widget build(BuildContext context) {
    return LayoutDialog(
      title: "Update Cell",
      constraints: BoxConstraints.tightFor(width: 400),
      onConfirmed: isError ? null : confirm,
      child: CellEditor(value: cell, onChanged: onChanged, onError: onError),
    );
  }
}
