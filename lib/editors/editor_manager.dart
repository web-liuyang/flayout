import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../layouts/resource_panel.dart';

class EditorConfig {
  final String title;

  // final RootGraphic graphic;

  // EditorConfig({required this.title, required this.graphic});
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

  void createEditor(EditorConfig config) {
    final RootGraphicInfo root = infos.firstWhere((item) => item.title == config.title);
    final EditorContext context = EditorContext();

    final EditorTab tab = EditorTab(title: config.title, editor: Editor(context: context));
    tabsNotifier.value = [...tabsNotifier.value, tab];
  }
}

final EditorManager editorManager = EditorManager();
