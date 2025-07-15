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

    return ListenableBuilder(
      listenable: editorManager.currentEditorNotifier,
      builder: (context, _) {
        final ValueNotifier<BaseStateMachine>? stateMachineNotifier = editorManager.currentEditorNotifier.value?.context.stateMachineNotifier;

        return ListenableBuilder(
          listenable: Listenable.merge([stateMachineNotifier]),
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final context = editorManager.currentEditor?.context;
                    if (context == null) return;
                    context.stateMachineNotifier.value = SelectionStateMachine(context: context);
                  },
                  isSelected: editorManager.currentEditor?.context.stateMachine is SelectionStateMachine,
                  icon: const Icon(Icons.north_west),
                  tooltip: "Selection",
                ),
                IconButton(
                  onPressed: () {
                    final context = editorManager.currentEditor?.context;
                    if (context == null) return;
                    context.stateMachineNotifier.value = RectangleStateMachine(context: context);
                  },
                  isSelected: editorManager.currentEditor?.context.stateMachine is RectangleStateMachine,
                  icon: const Icon(Icons.rectangle_outlined),
                  tooltip: "Rectange",
                ),
              ],
            );
          },
        );
      },
    );
  }
}
