import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/layouts/cubits/cells_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditorConfig {
  final String title;

  EditorConfig({required this.title});
}

class EditorTab {
  final String title;

  final Editor editor;

  EditorTab({required this.title, required this.editor});
}

class EditorManager {
  final ValueNotifier<List<EditorTab>> tabsNotifier = ValueNotifier<List<EditorTab>>([]);

  List<EditorTab> get tabs => tabsNotifier.value;

  final ValueNotifier<Editor?> currentEditorNotifier = ValueNotifier<Editor?>(null);

  Editor? get currentEditor => currentEditorNotifier.value;

  void createEditor(EditorConfig config) {
    final Cell? cell = cellsCubit.findCell(config.title);
    if (cell == null) return;

    final int index = tabs.indexWhere((tab) => tab.title == config.title);
    if (index >= 0) {
      currentEditorNotifier.value = tabs[index].editor;
      return;
    }

    final EditorContext context = EditorContext()..graphic = cell.graphic;
    final EditorTab tab = EditorTab(title: config.title, editor: Editor(key: ValueKey(config.title), context: context));
    tabsNotifier.value = [...tabsNotifier.value, tab];
    currentEditorNotifier.value = tab.editor;
  }

  void removeEditor(String title) {
    final int index = tabs.indexWhere((item) => item.title == title);
    if (currentEditor == tabs.elementAtOrNull(index)?.editor) {
      currentEditorNotifier.value = null;
    }
    tabs.removeAt(index);
    if (tabs.isNotEmpty) {
      currentEditorNotifier.value = (tabs.elementAtOrNull(index) ?? tabs.elementAtOrNull(index - 1))?.editor;
    }

    tabsNotifier.value = [...tabs];
  }
}

final EditorManager editorManager = EditorManager();
