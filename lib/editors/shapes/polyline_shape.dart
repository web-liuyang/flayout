import 'package:flame/components.dart';

class PolylineShape extends ShapeComponent {
  PolylineShape(this.vertices);

  final List<Vector2> vertices;
}
