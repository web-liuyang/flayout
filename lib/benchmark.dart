import 'package:flutter/foundation.dart';

class Benchmark {
  static T run<T>(ValueGetter<T> cb, [String? title]) {
    final s = Stopwatch()..start();
    final result = cb();
    s.stop();

    title ??= "Benchmark";

    print("$title: ${s.elapsed.inMilliseconds}ms");

    return result;
  }
}
