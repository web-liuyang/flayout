import 'package:flayout/commands/commands.dart';
import 'package:flayout/editors/editors.dart';
import 'package:flayout/layouts/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../editors/state_machines/state_machines.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: editorManager.currentEditorNotifier,
      builder: (context, _) {
        final EditorContext? editorContext = editorManager.currentEditor?.context;
        final ValueNotifier<BaseStateMachine>? stateMachineNotifier =
            editorManager.currentEditor?.context.stateMachineNotifier;
        final CommandManager? commands = editorManager.currentEditor?.context.commands;

        return ListenableBuilder(
          listenable: Listenable.merge([stateMachineNotifier, commands]),
          builder: (context, _) {
            final bool canUndo = (commands?.canUndo ?? false);
            final bool canRedo = (commands?.canRedo ?? false);
            final bool canDraw = context.watch<LayersCubit>().current != null;

            VoidCallback? invoke(ValueSetter<EditorContext> callback) {
              if (editorContext == null) return null;

              return () => callback(editorContext);
            }

            void onUndo(EditorContext editorContext) {
              Actions.invoke(context, UndoIntent());
            }

            void onRedo(EditorContext editorContext) {
              Actions.invoke(context, RedoIntent());
            }

            void onSelection(EditorContext editorContext) {
              editorContext.stateMachineNotifier.value = SelectionStateMachine(context: editorContext);
            }

            void onRectangle(EditorContext editorContext) {
              editorContext.stateMachineNotifier.value = RectangleStateMachine(context: editorContext);
            }

            void onPolygon(EditorContext editorContext) {
              editorContext.stateMachineNotifier.value = PolygonStateMachine(context: editorContext);
            }

            void onCircle(EditorContext editorContext) {
              editorContext.stateMachineNotifier.value = CircleStateMachine(context: editorContext);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: canUndo ? invoke(onUndo) : null, icon: const Icon(Icons.undo), tooltip: "Undo"),
                IconButton(onPressed: canRedo ? invoke(onRedo) : null, icon: const Icon(Icons.redo), tooltip: "Redo"),
                IconButton(
                  onPressed: canDraw ? invoke(onSelection) : null,
                  isSelected: editorContext?.stateMachine is SelectionStateMachine,
                  icon: const Icon(Icons.north_west),
                  tooltip: "Selection",
                ),
                IconButton(
                  onPressed: canDraw ? invoke(onRectangle) : null,
                  isSelected: editorContext?.stateMachine is RectangleStateMachine,
                  icon: const Icon(Icons.rectangle_outlined),
                  tooltip: "Rectange",
                ),
                IconButton(
                  onPressed: canDraw ? invoke(onPolygon) : null,
                  isSelected: editorContext?.stateMachine is PolygonStateMachine,
                  icon: const Icon(Icons.tab),
                  tooltip: "Polygon",
                ),
                IconButton(
                  onPressed: canDraw ? invoke(onCircle) : null,
                  isSelected: editorContext?.stateMachine is CircleStateMachine,
                  icon: const Icon(Icons.circle_outlined),
                  tooltip: "Circle",
                ),
              ],
            );
          },
        );
      },
    );
  }
}
