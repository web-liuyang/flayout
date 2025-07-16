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

final List<BaseAction> actionHistories = [];

int actionIndex = -1;

abstract class BaseAction<T extends BaseIntent> extends Action<T> {
  void redo();

  void undo();
}

class AddGraphicAction extends BaseAction<AddGraphicIntent> {
  late AddGraphicIntent intent;

  // AddGraphicAction 有永远是单例
  // 所以回退的时候需要单独再来个 Index来控制加入的图形

  @override
  void invoke(AddGraphicIntent intent) {
    this.intent = intent;
    intent.context.graphic.children.add(intent.graphic);
    intent.context.render();
    actionHistories.add(this);
    actionIndex++;
  }

  @override
  void redo() {
    intent.context.graphic.children.add(intent.graphic);
    intent.context.render();
  }

  @override
  void undo() {
    intent.context.graphic.children.remove(intent.graphic);
    intent.context.render();
  }
}

class UndoAction extends BaseAction<UndoIntent> {
  @override
  void invoke(UndoIntent intent) {
    print("UndoAction $actionIndex");
    if (actionIndex == -1) return;
    actionHistories[actionIndex--].undo();
  }

  @override
  void redo() {}

  @override
  void undo() {}
}

class RedoAction extends BaseAction<RedoIntent> {
  @override
  void invoke(RedoIntent intent) {
    print("RedoAction $actionIndex");
    if (actionIndex == actionHistories.length - 1) return;
    actionHistories[++actionIndex].redo();
  }

  @override
  void redo() {}

  @override
  void undo() {}
}

class CopyAction extends BaseAction<CopyIntent> {
  @override
  void invoke(CopyIntent intent) {}

  @override
  void redo() {}

  @override
  void undo() {}
}

class PasteAction extends BaseAction<PasteIntent> {
  @override
  void invoke(PasteIntent intent) {}

  @override
  void redo() {}

  @override
  void undo() {}
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

final Map<Type, Action<Intent>> actions = {
  DirectionalFocusIntent: CustomDirectionalFocusAction(),

  AddGraphicIntent: AddGraphicAction(),
  UndoIntent: UndoAction(),
  RedoIntent: RedoAction(),
  CopyIntent: CopyAction(),
  PasteIntent: PasteAction(),
};

final Map<ShortcutActivator, Intent> shortcuts = {
  // SingleActivator(LogicalKeyboardKey.keyZ, meta: true, control: true): UndoIntent(),
  // SingleActivator(LogicalKeyboardKey.keyZ, meta: true, control: true, shift: true): RedoIntent(),
  SingleActivator(LogicalKeyboardKey.keyC, meta: true, control: true): CopyIntent(),
  SingleActivator(LogicalKeyboardKey.keyV, meta: true, control: true): PasteIntent(),
};
