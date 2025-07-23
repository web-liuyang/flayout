import 'package:flutter/material.dart';

import '../layouts/cubits/cubits.dart';

class LayerSelector extends StatelessWidget {
  const LayerSelector({super.key, required this.value, required this.layers, required this.onChanged});

  final Layer value;

  final List<Layer> layers;

  final ValueSetter<Layer> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderSide? borderSide = theme.inputDecorationTheme.border?.borderSide;

    return Container(
      decoration: BoxDecoration(
        border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton(
        isExpanded: true,
        isDense: true,
        value: value,
        underline: Container(),
        selectedItemBuilder: (context) => layers.map((item) => Text(item.name)).toList(growable: false),
        items: layers
            .map(
              (item) =>
                  DropdownMenuItem(value: item, child: Container(margin: EdgeInsets.all(8), child: Text(item.name))),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}
