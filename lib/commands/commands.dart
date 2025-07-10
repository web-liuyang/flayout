import 'package:flutter/widgets.dart';

abstract class Command extends Intent {
  void execute();
  void undo();
  void redo();
}
