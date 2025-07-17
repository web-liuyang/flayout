import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:blueprint_master/layouts/menubar.dart';
import 'package:blueprint_master/layouts/resource_panel.dart';
import 'package:blueprint_master/layouts/toolbar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/editors.dart';
import 'cubits/cubits.dart';

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
          child: Row(
            children: [
              Container(width: 200, decoration: BoxDecoration(border: Border(right: BorderSide(width: 1))), child: ResourcePanel()),
              // Expanded(child: MultiBlocProvider(providers: [], child: Editor())),
              Expanded(child: DrawingArea()),
              Container(decoration: BoxDecoration(border: Border(left: BorderSide(width: 1))), child: PropertyPanel()),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1))),
          child: MultiBlocProvider(providers: [BlocProvider.value(value: mouseCubit), BlocProvider.value(value: zoomCubit)], child: StatusBar()),
        ),
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
          );
        },
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  List<T> intersected(T item) {
    if (length < 2) return toList();

    final List<T> newList = [];
    for (final T element in this) {
      newList.addAll([element, item]);
    }
    newList.removeLast();
    return newList;
  }
}

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Property Panel"));
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    final MouseCubit mouseCubit = context.watch<MouseCubit>();
    final ZoomCubit scaleCubit = context.watch<ZoomCubit>();

    // final Vector2 mousePosition = mouseCubit.state;
    final String zoomPercentage = scaleCubit.percentage();

    return Center(
      child: Row(
        children: [
          // Text("$mousePosition"),
          TextButton(
            onPressed: () {
              scaleCubit.reset();
            },
            child: Text(zoomPercentage),
          ),
        ],
      ),
    );
  }
}
