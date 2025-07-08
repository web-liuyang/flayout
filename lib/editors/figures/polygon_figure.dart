import 'package:flutter/material.dart';

class PolygonFigure extends LeafRenderObjectWidget {
  final List<Offset> vertices;

  final bool close;

  const PolygonFigure({super.key, required this.vertices, this.close = true});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PolygonFigureRenderObject(vertices: [...vertices, if (close) vertices.first]);
  }

  @override
  void updateRenderObject(BuildContext context, PolygonFigureRenderObject renderObject) {
    renderObject.update([...vertices, if (close) vertices.first]); // 传递回调
  }
}

class PolygonFigureRenderObject extends RenderBox {
  List<Offset> vertices;

  PolygonFigureRenderObject({required this.vertices});

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

    final paint = Paint()..color = Colors.blue;
    context.canvas.drawPath(_path, paint);

    context.canvas.restore();
  }
}
