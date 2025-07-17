extension IterableExtension<T> on Iterable<T> {
  int get lastIndex => length - 1;

  List<T> intersected(T item) {
    if (length < 2) return toList();

    final List<T> newList = [];
    for (final T element in this) {
      newList.addAll([element, item]);
    }
    newList.removeLast();

    return newList;
  }
}
