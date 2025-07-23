import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key, required this.value, required this.colors, required this.onChanged});

  final Color value;

  final List<Color> colors;

  final ValueSetter<Color> onChanged;

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
        selectedItemBuilder: (context) => colors.map((color) => Container(color: color)).toList(growable: false),
        items: colors
            .map(
              (color) => DropdownMenuItem(value: color, child: Container(margin: EdgeInsets.all(8), color: color)),
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
