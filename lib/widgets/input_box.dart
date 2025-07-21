import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  const InputBox({
    super.key,
    this.defaultValue,
    this.value,
    this.controller,
    this.decoration = const InputDecoration(),
    this.onSubmitted,
    this.onAction,
  });

  final String? defaultValue;

  final String? value;

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

    if (widget.value != null && widget.value != controller.text) {
      controller.text = widget.value!;
    } else if (widget.defaultValue != null && widget.defaultValue != controller.text) {
      controller.text = widget.defaultValue!;
    }
  }

  void onFocusChange(bool value) {
    if (!value) {
      widget.onAction?.call(controller.text);
    }
  }

  @override
  void didUpdateWidget(covariant InputBox oldWidget) {
    if (widget.value != null && widget.value != controller.text) {
      controller.text = widget.value!;
    }
    super.didUpdateWidget(oldWidget);
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
