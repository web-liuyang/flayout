import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  const InputBox({
    super.key,
    this.defaultValue,
    this.controller,
    this.decoration = const InputDecoration(),
    this.onSubmitted,
    this.onAction,
  });

  final String? defaultValue;

  final TextEditingController? controller;

  final InputDecoration decoration;

  final ValueSetter<String>? onSubmitted;

  final ValueSetter<String>? onAction;

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  TextEditingController? _controller;

  TextEditingController get controller => widget.controller ?? (_controller ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      controller.text = widget.defaultValue!;
    }
  }

  void onFocusChange(bool value) {
    if (!value) {
      widget.onAction?.call(controller.text);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextField(
        controller: controller,
        decoration: widget.decoration,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
