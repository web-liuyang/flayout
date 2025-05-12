import 'package:blueprint_master/editors/editors.dart';

import '../graphics/graphics.dart';

abstract class BaseBusinessGraphic {
  BaseBusinessGraphic();

  BaseGraphic? toGraphic(World world);
}
