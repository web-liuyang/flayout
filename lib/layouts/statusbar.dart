import 'package:flayout/layouts/cubits/canvas_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Statusbar extends StatefulWidget {
  const Statusbar({super.key});

  @override
  State<Statusbar> createState() => _StatusbarState();
}

class _StatusbarState extends State<Statusbar> {
  @override
  Widget build(BuildContext context) {
    final canvasCubit = context.watch<CanvasCubit>();
    final mousePosition = canvasCubit.state.position;
    final zoom = canvasCubit.state.zoom;
    final grid = canvasCubit.state.grid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 8,
        children: [
          Text("Position: ${mousePosition.dx.toStringAsFixed(2)}, ${mousePosition.dy.toStringAsFixed(2)}"),
          VerticalDivider(),
          Text("Zoom: ${zoom.toStringAsFixed(2)}x"),
          VerticalDivider(),
          Text("Grid: ${grid.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}
