import 'package:flayout/editors/editor.dart';
import 'package:flayout/layouts/cubits/cells_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditorConfig {
  final Cell cell;

  EditorConfig({required this.cell});
}

class EditorTab {
  EditorTab({required this.title, required this.editor});

  final String title;

  final Editor editor;

  EditorTab copyWith({required String title}) {
    return EditorTab(
      title: title,
      editor: editor,
    );
  }
}

class EditorManager {
  final ValueNotifier<List<EditorTab>> tabsNotifier = ValueNotifier<List<EditorTab>>([]);

  List<EditorTab> get tabs => tabsNotifier.value;

  final ValueNotifier<Editor?> currentEditorNotifier = ValueNotifier<Editor?>(null);

  Editor? get currentEditor => currentEditorNotifier.value;

  void createEditor(EditorConfig config) {
    final int index = tabs.indexWhere((tab) => tab.title == config.cell.name);
    if (index >= 0) {
      currentEditorNotifier.value = tabs[index].editor;
      return;
    }

    final EditorContext context = EditorContext()..graphic = config.cell.graphic;
    final EditorTab tab = EditorTab(
      title: config.cell.name,
      editor: Editor(key: ValueKey(config.cell.name), context: context),
    );
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

  void updateEditorTitle(String title, String newTitle) {
    final int index = tabs.indexWhere((item) => item.title == title);
    tabs[index] = tabs[index].copyWith(title: newTitle);
    tabsNotifier.value = [...tabs];
  }
}

final EditorManager editorManager = EditorManager();
