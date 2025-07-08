import 'package:flutter/material.dart';

class PolylineFigure extends LeafRenderObjectWidget {
  final List<Offset> vertices;

  const PolylineFigure({super.key, required this.vertices});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PolylineFigureRenderObject(vertices: vertices);
  }

  @override
  void updateRenderObject(BuildContext context, PolylineFigureRenderObject renderObject) {
    renderObject.update(vertices);
  }
}

class PolylineFigureRenderObject extends RenderBox {
  List<Offset> vertices;

  PolylineFigureRenderObject({required this.vertices});

  Path _path = Path();

  void update(List<Offset> vertices) {
    this.vertices = vertices;
    markNeedsLayout();
    markNeedsPaint();
  }

  @override
  void performLayout() {
    _path = getPath();
    size = _path.getBounds().size;
  }

  Path getPath() {
    final path = Path();
    final [first, ...rest] = vertices;
    path.moveTo(first.dx, first.dy);
    for (final Offset vertex in rest) {
      path.lineTo(vertex.dx, vertex.dy);
    }

    return path;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    final paint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke;
    context.canvas.drawPath(_path, paint);

    context.canvas.restore();
  }
}
