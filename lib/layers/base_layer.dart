abstract class BaseLayer {
  const BaseLayer({required this.number, required this.datatype});

  final int number;

  final int datatype;

  @override
  bool operator ==(Object other) {
    return other is BaseLayer && number == other.number && datatype == other.datatype;
  }

  @override
  int get hashCode => number.hashCode ^ datatype.hashCode;
}
