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

extension ListExtension<T> on List<T> {
  void removeAll(List<T> items) {
    for (final T item in items) {
      remove(item);
    }
  }

  List<T> replacedAt(int index, T item) => List.from(this)..[index] = item;

  void replaceAt(int index, T item) => this[index] = item;
}
