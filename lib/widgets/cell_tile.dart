import 'package:flutter/material.dart';

class CellTile extends StatelessWidget {
  const CellTile({super.key, required this.title, required this.trailing});

  final String title;

  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        SizedBox(width: 80, child: Text(title)),
        Expanded(child: trailing),
      ],
    );
  }
}
