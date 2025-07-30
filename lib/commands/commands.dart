import 'package:flayout/editors/editors.dart';
import 'package:flayout/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../editors/graphics/graphics.dart';
import '../editors/state_machines/state_machines.dart';

abstract class BaseIntent extends Intent {}

class AddGraphicIntent extends BaseIntent {
  AddGraphicIntent(this.context, this.graphics);

  final EditorContext context;

  final List<BaseGraphic> graphics;
}

class UndoIntent extends BaseIntent {
  UndoIntent();
}

class RedoIntent extends BaseIntent {
  RedoIntent();
}

class CopyIntent extends BaseIntent {
  CopyIntent();
}

class PasteIntent extends BaseIntent {
  PasteIntent();
}

class ZoomInIntent extends BaseIntent {
  ZoomInIntent();
}

class ZoomOutIntent extends BaseIntent {
  ZoomOutIntent();
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
    UndoIntent: CallbackAction<UndoIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        context?.commands.undo();
        return;
      },
    ),
    RedoIntent: CallbackAction<RedoIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        context?.commands.redo();
        return;
      },
    ),
    AddGraphicIntent: CallbackAction<AddGraphicIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        context?.commands.execute(AddGraphicCommand(intent));
        return;
      },
    ),
    CopyIntent: CallbackAction<CopyIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        if (context == null) return;
        _clipboardGraphics = context.selectedGraphics.toList();
        return;
      },
    ),
    PasteIntent: CallbackAction<PasteIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        if (context == null) return;
        if (_clipboardGraphics.isEmpty) return;
        context.stateMachineNotifier.value = PasteStateMachine(context: context, graphics: _clipboardGraphics);

        return;
      },
    ),
    ZoomInIntent: CallbackAction<ZoomInIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        if (context == null) return;
        context.viewport.zoomIn(context.viewport.visibleWorldRect.center);
        context.render();
        return;
      },
    ),
    ZoomOutIntent: CallbackAction<ZoomOutIntent>(
      onInvoke: (intent) {
        final EditorContext? context = editorManager.currentEditor?.context;
        if (context == null) return;
        context.viewport.zoomOut(context.viewport.visibleWorldRect.center);
        context.render();
        return;
      },
    ),
  };

  return actions;
}

Map<ShortcutActivator, Intent> createEditorShortcuts() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return _createEditorShortcuts();
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _createEditorShortcutsAppleOs();
  }
}

Map<ShortcutActivator, Intent> _createEditorShortcuts() {
  return {
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, control: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, control: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.equal, control: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.minus, control: true): ZoomOutIntent(),
  };
}

Map<ShortcutActivator, Intent> _createEditorShortcutsAppleOs() {
  return {
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.equal, meta: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.minus, meta: true): ZoomOutIntent(),
  };
}
