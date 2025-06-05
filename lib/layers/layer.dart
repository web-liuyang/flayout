import 'base_layer.dart';

class Layer extends BaseLayer {
  const Layer({required super.number, required super.datatype});

  String identity() {
    return combineIdentity(number, datatype);
  }

  @override
  String toString() {
    return "Layer(number: $number, datatype: $datatype)";
  }
}

String combineIdentity(int number, int datatype) {
  return "$number/$datatype";
}
