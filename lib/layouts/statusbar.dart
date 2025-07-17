import 'package:flutter/material.dart';

class Statusbar extends StatefulWidget {
  const Statusbar({super.key});

  @override
  State<Statusbar> createState() => _StatusbarState();
}

class _StatusbarState extends State<Statusbar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          // Text("$mousePosition"),
          TextButton(onPressed: () {}, child: Text("A")),
        ],
      ),
    );
  }
}
