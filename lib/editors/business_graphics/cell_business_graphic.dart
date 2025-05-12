import 'package:blueprint_master/editors/business_graphics/base_business_graphic.dart';
import 'package:blueprint_master/editors/editor.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';

class CellBusinessGraphic extends BaseBusinessGraphic {
  CellBusinessGraphic({required this.name, this.children = const []});

  final String name;

  final List<BaseBusinessGraphic> children;

  @override
  GroupGraphic toGraphic(World world) {
    return GroupGraphic(children: children.map((child) => child.toGraphic(world)).nonNulls.toList());
  }
}
