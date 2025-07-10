import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/widgets.dart';

class EditorConfig {
  final String title;

  final RootGraphic graphic;

  EditorConfig({required this.title, required this.graphic});
}

class EditorTab {
  final String title;

  final Editor editor;

  EditorTab({required this.title, required this.editor});
}

class EditorManager {
  final ValueNotifier<List<EditorTab>> tabsNotifier = ValueNotifier<List<EditorTab>>([]);

  List<EditorTab> get tabs => tabsNotifier.value;

  void createEditor(EditorConfig config) {
    config;
    final tab = EditorTab(title: config.title, editor: Editor(graphic: config.graphic));
    tabsNotifier.value = [...tabsNotifier.value, tab];
  }
}

final EditorManager editorManager = EditorManager();
