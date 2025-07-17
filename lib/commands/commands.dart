import 'package:blueprint_master/editors/editors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../editors/graphics/graphics.dart';

abstract class BaseIntent extends Intent {}

class AddGraphicIntent extends BaseIntent {
  AddGraphicIntent(this.context, this.graphic);

  final EditorContext context;

  final BaseGraphic graphic;
}

class UndoIntent extends BaseIntent {
  UndoIntent(this.context);

  final EditorContext context;
}

class RedoIntent extends BaseIntent {
  RedoIntent(this.context);

  final EditorContext context;
}

class CopyIntent extends BaseIntent {}

class PasteIntent extends BaseIntent {}

class CustomDirectionalFocusAction extends DirectionalFocusAction {
  @override
  void invoke(DirectionalFocusIntent intent) {
    final a = switch (intent.direction) {
      TraversalDirection.left => 1,
      TraversalDirection.right => 2,
      TraversalDirection.up => 3,
      TraversalDirection.down => 4,
    };
    print(intent);
    // super.invoke(intent);
  }
}

abstract class BaseCommand<T extends BaseIntent> {
  void execute();
  void redo();
  void undo();
}

class AddGraphicCommand extends BaseCommand<AddGraphicIntent> {
  AddGraphicCommand(this.intent);

  final AddGraphicIntent intent;

  @override
  void execute() {
    intent.context.graphic.children.add(intent.graphic);
    intent.context.render();
  }

  @override
  void undo() {
    intent.context.graphic.children.remove(intent.graphic);
    intent.context.render();
  }

  @override
  void redo() {
    intent.context.graphic.children.add(intent.graphic);
    intent.context.render();
  }
}

class CommandManager extends ChangeNotifier {
  final List<BaseCommand> _undoStack = [];
  final List<BaseCommand> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void execute(BaseCommand command) {
    print(command);
    _undoStack.add(command); // Push to undo stack
    _redoStack.clear(); // Clear redo stack
    command.execute(); // Execute the command
    notifyListeners();
  }

  void undo() {
    print("undo");
    if (_undoStack.isNotEmpty) {
      final command = _undoStack.removeLast(); // Pop from undo stack
      _redoStack.add(command); // Push to redo stack
      command.undo(); // Undo the command
      notifyListeners();
    } else {
      print('No commands to undo.');
    }
  }

  void redo() {
    print("redo");
    if (_redoStack.isNotEmpty) {
      final command = _redoStack.removeLast(); // Pop from redo stack
      _undoStack.add(command); // Push to undo stack
      command.execute(); // Re-execute the command
      notifyListeners();
    } else {
      print('No commands to redo.');
    }
  }
}

Map<Type, Action<BaseIntent>> createEditorActions() {
  final Map<Type, Action<BaseIntent>> actions = {
    // DirectionalFocusIntent: CustomDirectionalFocusAction(),
    UndoIntent: CallbackAction<UndoIntent>(onInvoke: (intent) => intent.context.commands.undo()),
    RedoIntent: CallbackAction<RedoIntent>(onInvoke: (intent) => intent.context.commands.redo()),

    AddGraphicIntent: CallbackAction<AddGraphicIntent>(onInvoke: (intent) => intent.context.commands.execute(AddGraphicCommand(intent))),
    CopyIntent: CallbackAction<CopyIntent>(onInvoke: (intent) => {}),
    PasteIntent: CallbackAction<PasteIntent>(onInvoke: (intent) => {}),
  };

  return actions;
}

Map<ShortcutActivator, BaseIntent> createEditorShortcuts(EditorContext? context) {
  if (context == null) return {};

  final Map<ShortcutActivator, BaseIntent> shortcuts = {
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(context),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): RedoIntent(context),
    // SingleActivator(LogicalKeyboardKey.keyC, meta: true, control: true): CopyIntent(),
    // SingleActivator(LogicalKeyboardKey.keyV, meta: true, control: true): PasteIntent(),
  };

  return shortcuts;
}
