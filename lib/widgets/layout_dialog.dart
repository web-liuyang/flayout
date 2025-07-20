import 'package:flutter/material.dart';

class LayoutDialog extends StatefulWidget {
  const LayoutDialog({
    super.key,
    required this.title,
    this.constraints,
    required this.child,
    required this.onConfirmed,
    this.onClosed,
  });

  final String title;

  final BoxConstraints? constraints;

  final Widget child;

  final VoidCallback? onConfirmed;

  final VoidCallback? onClosed;

  @override
  State<LayoutDialog> createState() => _LayoutDialogState();
}

class _LayoutDialogState extends State<LayoutDialog> {
  void confirm() {
    Navigator.pop(context);
  }

  void cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: widget.constraints,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title),
                IconButton(icon: Icon(Icons.close), onPressed: widget.onClosed ?? cancel),
              ],
            ),
            Divider(height: 1),
            widget.child,
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: widget.onConfirmed, child: Text("OK")),
                  OutlinedButton(onPressed: widget.onClosed ?? cancel, child: Text("Cancel")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
