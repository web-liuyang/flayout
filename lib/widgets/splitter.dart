import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplitterItem {
  SplitterItem({required this.child, this.size, required this.min});

  final Widget child;

  final double? size;

  final double min;
}

class Splitter extends StatefulWidget {
  const Splitter({super.key, required this.axis, required this.items});

  final Axis axis;

  final List<SplitterItem> items;

  @override
  State<Splitter> createState() => _SplitterState();
}

class _SplitterState extends State<Splitter> {
  final List<Widget> children = [];

  final Map<int, double> sizes = {};

  Offset _startGlobalPosition = Offset.zero;

  Map<int, double> _startSizes = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      if (item.size != null) {
        sizes[i * 2] = item.size!;
      }

      sizes[i * 2 + 1] = 1;

      children.add(item.child);

      // 在子组件之间添加分割器
      if (i < widget.items.length - 1) {
        children.add(
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              _startGlobalPosition = details.globalPosition;
              _startSizes = Map.from(sizes);
            },
            onPanUpdate: (details) => _handleDragUpdate(i, details),
            child: MouseRegion(cursor: SystemMouseCursors.resizeColumn, child: VerticalDivider(width: 1)),
          ),
        );
      }
    }
  }

  void _handleDragUpdate(int index, DragUpdateDetails details) {
    int actualIndex = index;
    Offset diff = details.globalPosition - _startGlobalPosition;
    if (widget.items[index].size == null) {
      actualIndex++;
      diff = -diff;
    }

    final double size = _startSizes[actualIndex * 2]! + diff.dx;
    final double min = widget.items[actualIndex].min;
    if (size > min) {
      setState(() {
        sizes[actualIndex * 2] = size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .mapIndexed((index, child) {
            final size = sizes[index];
            return size == null ? Expanded(child: child) : SizedBox(width: size, child: child);
          })
          .toList(growable: false),
    );
  }
}
