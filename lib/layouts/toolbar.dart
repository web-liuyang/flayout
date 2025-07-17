import 'package:blueprint_master/commands/commands.dart';
import 'package:blueprint_master/editors/editors.dart';
import 'package:flutter/material.dart';

import '../editors/state_machines/state_machines.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    // final DrawCubit drawCubit = context.watch<DrawCubit>();

    return Actions(
      actions: createEditorActions(),
      child: ListenableBuilder(
        listenable: editorManager.currentEditorNotifier,
        builder: (context, _) {
          final EditorContext? editorContext = editorManager.currentEditor?.context;
          final ValueNotifier<BaseStateMachine>? stateMachineNotifier = editorManager.currentEditor?.context.stateMachineNotifier;
          final CommandManager? commands = editorManager.currentEditor?.context.commands;

          return ListenableBuilder(
            listenable: Listenable.merge([stateMachineNotifier, commands]),
            builder: (context, _) {
              final bool canUndo = (commands?.canUndo ?? false);
              final bool canRedo = (commands?.canRedo ?? false);

              VoidCallback? invoke(ValueSetter<EditorContext> callback) {
                if (editorContext == null) return null;

                return () => callback(editorContext);
              }

              void onUndo(EditorContext editorContext) {
                Actions.invoke(context, UndoIntent(editorContext));
              }

              void onRedo(EditorContext editorContext) {
                Actions.invoke(context, RedoIntent(editorContext));
              }

              void onSelection(EditorContext editorContext) {
                editorContext.stateMachineNotifier.value = SelectionStateMachine(context: editorContext);
              }

              void onRectangle(EditorContext editorContext) {
                editorContext.stateMachineNotifier.value = RectangleStateMachine(context: editorContext);
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: canUndo ? invoke(onUndo) : null, icon: const Icon(Icons.undo), tooltip: "Undo"),
                  IconButton(onPressed: canRedo ? invoke(onRedo) : null, icon: const Icon(Icons.redo), tooltip: "Redo"),
                  IconButton(
                    onPressed: invoke(onSelection),
                    isSelected: editorContext?.stateMachine is SelectionStateMachine,
                    icon: const Icon(Icons.north_west),
                    tooltip: "Selection",
                  ),
                  IconButton(
                    onPressed: invoke(onRectangle),
                    isSelected: editorContext?.stateMachine is RectangleStateMachine,
                    icon: const Icon(Icons.rectangle_outlined),
                    tooltip: "Rectange",
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
