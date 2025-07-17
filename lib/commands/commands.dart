import 'dart:io';

import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../editors/graphics/graphics.dart';

abstract class BaseIntent extends Intent {}

class AddGraphicIntent extends BaseIntent {
  AddGraphicIntent(this.context, this.graphics);

  final EditorContext context;

  final List<BaseGraphic> graphics;
}

class UndoIntent extends BaseIntent {
  UndoIntent(this.context);

  final EditorContext context;
}

class RedoIntent extends BaseIntent {
  RedoIntent(this.context);

  final EditorContext context;
}

class CopyIntent extends BaseIntent {
  CopyIntent(this.context);

  final EditorContext context;
}

class PasteIntent extends BaseIntent {
  PasteIntent(this.context);

  final EditorContext context;
}

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

  void undo();
}

class AddGraphicCommand extends BaseCommand<AddGraphicIntent> {
  AddGraphicCommand(this.intent);

  final AddGraphicIntent intent;

  @override
  void execute() {
    intent.context.graphic.children.addAll(intent.graphics);
    intent.context.render();
  }

  @override
  void undo() {
    intent.context.graphic.children.removeAll(intent.graphics);
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

List<BaseGraphic> _clipboardGraphics = [];

Map<Type, Action<BaseIntent>> createEditorActions() {
  final Map<Type, Action<BaseIntent>> actions = {
    // DirectionalFocusIntent: CustomDirectionalFocusAction(),
    UndoIntent: CallbackAction<UndoIntent>(onInvoke: (intent) => intent.context.commands.undo()),
    RedoIntent: CallbackAction<RedoIntent>(onInvoke: (intent) => intent.context.commands.redo()),

    AddGraphicIntent: CallbackAction<AddGraphicIntent>(onInvoke: (intent) => intent.context.commands.execute(AddGraphicCommand(intent))),
    CopyIntent: CallbackAction<CopyIntent>(onInvoke: (intent) => _clipboardGraphics = intent.context.selectedGraphics),
    PasteIntent: CallbackAction<PasteIntent>(
      onInvoke: (intent) {
        if (_clipboardGraphics.isEmpty) return;
        intent.context.commands.execute(AddGraphicCommand(AddGraphicIntent(intent.context, _clipboardGraphics)));
      },
    ),
  };

  return actions;
}

Map<ShortcutActivator, BaseIntent> createEditorShortcuts(EditorContext? context) {
  if (context == null) return {};

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return _createEditorShortcuts(context);
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _createEditorShortcutsAppleOs(context);
  }
}

Map<ShortcutActivator, BaseIntent> _createEditorShortcuts(EditorContext context) {
  return {
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(context),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): RedoIntent(context),
    SingleActivator(LogicalKeyboardKey.keyC, control: true): CopyIntent(context),
    SingleActivator(LogicalKeyboardKey.keyV, control: true): PasteIntent(context),
  };
}

Map<ShortcutActivator, BaseIntent> _createEditorShortcutsAppleOs(EditorContext context) {
  print(2);
  return {
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(context),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): RedoIntent(context),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true): CopyIntent(context),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true): PasteIntent(context),
  };
}
