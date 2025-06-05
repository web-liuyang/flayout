import 'dart:ui';

import 'package:blueprint_master/editors/business_graphics/business_graphics.dart';

class CellBusinessGraphic extends BaseBusinessGraphic {
  CellBusinessGraphic({required this.name, this.children = const []});

  final String name;

  final List<BaseBusinessGraphic> children;

  // GroupGraphic? cache;

  // @override
  // GroupGraphic toGraphic() {
  //   cache ??= GroupGraphic(graphic: this, children: children.map((child) => child.toGraphic()).nonNulls.toList());
  //   return cache!;
  // }

  @override
  // Path collect(Map<Layer, Collection> layerToCollection, Map<String, Path> cellNameToPath) {
  Path collect(Collection collection) {
    if (collection.cellNameDependency.containsKey(name)) {
      return collection.cellNameDependency[name]!.path;
    }

    collection.cellNameDependency[name] = Dependency.empty();

    final Path cellPath = (collection.cellNameDependency[name]!.path);

    for (final child in children) {
      final childPath = child.collect(collection);
      cellPath.addPath(childPath, Offset.zero);
    }

    return cellPath;
  }
}
