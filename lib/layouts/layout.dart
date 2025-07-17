import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/extensions/list_extension.dart';
import 'package:blueprint_master/layouts/menubar.dart';
import 'package:blueprint_master/layouts/resource_panel.dart';
import 'package:blueprint_master/layouts/statusbar.dart';
import 'package:blueprint_master/layouts/toolbar.dart';
import 'package:blueprint_master/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart' hide Axis;
import 'cubits/cubits.dart';
import 'property_panel.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // //
        Container(child: Menubar(), alignment: Alignment.centerLeft),
        Divider(height: 1),
        Container(child: Toolbar()),
        Divider(height: 1),
        Expanded(
          child: Splitter(
            axis: Axis.horizontal,
            items: [
              SplitterItem(child: ResourcePanel(), min: 100, size: 300),
              SplitterItem(child: DrawingArea(), min: 100),
              SplitterItem(child: PropertyPanel(), min: 100, size: 300),
            ],
          ),
        ),

        Divider(height: 1),
        Container(child: Statusbar()),
      ],
    );
  }
}

class DrawingArea extends StatefulWidget {
  const DrawingArea({super.key});

  @override
  DrawingAreaState createState() => DrawingAreaState();
}

class DrawingAreaState extends State<DrawingArea> {
  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: createEditorActions(),
      child: ListenableBuilder(
        listenable: Listenable.merge([editorManager.tabsNotifier, editorManager.currentEditorNotifier]),
        builder: (context, child) {
          final List<EditorTab> tabs = editorManager.tabs;
          final Editor? currentEditor = editorManager.currentEditor;

          return Shortcuts(
            shortcuts: createEditorShortcuts(currentEditor?.context),
            child: Focus(
              // autofocus: true,
              // onKeyEvent: (node, event) {
              //   print(event);
              //   return KeyEventResult.ignored;
              // },
              child: Column(
                children: [
                  Row(
                    children: tabs
                        .mapIndexed<Widget>(
                          (index, tab) => Container(
                            decoration: BoxDecoration(border: Border(right: BorderSide(width: 1))),
                            child: IntrinsicWidth(
                              child: ListTile(
                                minTileHeight: 32,
                                contentPadding: EdgeInsets.only(left: 8),
                                selected: editorManager.currentEditor == tab.editor,
                                leading: Text(tab.title),
                                trailing: IconButton(iconSize: 12, onPressed: () => editorManager.removeEditor(tab.title), icon: Icon(Icons.close)),
                                onTap: () {
                                  editorManager.currentEditorNotifier.value = tab.editor;
                                },
                              ),
                            ),
                          ),
                        )
                        // .intersected(VerticalDivider(width: 20, thickness: 20, color: Colors.black))
                        .toList(growable: false),
                  ),
                  if (tabs.isNotEmpty) Divider(height: 1, thickness: 2),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        for (final tab in editorManager.tabs) {
                          tab.editor.context.viewport.setSize(c.biggest);
                        }
                        return Container(child: editorManager.currentEditor);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
