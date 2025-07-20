import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../editors/editors.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  CanvasAreaState createState() => CanvasAreaState();
}

class CanvasAreaState extends State<CanvasArea> {
  final FocusNode focusNode = FocusNode(debugLabel: "CanvasArea");

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        focusNode.requestFocus();
      },
      child: FocusableActionDetector(
        focusNode: focusNode,
        child: ListenableBuilder(
          listenable: Listenable.merge([editorManager.tabsNotifier, editorManager.currentEditorNotifier]),
          builder: (context, child) {
            final List<EditorTab> tabs = editorManager.tabs;
            final Editor? currentEditor = editorManager.currentEditor;

            return Column(
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
            );
          },
        ),
      ),
    );
  }
}
