import 'dart:io';

import 'package:blueprint_master/gdsii/gdsii.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

// 使用示例
void main() async {
  final prefix = Platform.isWindows ? r"C:\Users\xiaoyao\Desktop\ansys" : "/Users/xiaoyao/Desktop/ansys";

  test("readGdsii: mmi.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('$prefix/mmi.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });

  test("readGdsii: MZI_SYSTEM_FOR_2X2.py.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('$prefix/MZI_SYSTEM_FOR_2X2.py.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });

  test("readGdsii: WBBC2017_top_180531.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('$prefix/WBBC2017_top_180531.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });

  test("1", () {
    final view = Rect.fromLTRB(-536.9, -304.2, 536.9, 304.2);
    final g1 = Rect.fromLTRB(1634.8, -2253.1, 1634.8, -2253.1);
    final g2 = Rect.fromLTRB(1684.8, -2303.1, 1684.8, -2303.1);
    final g3 = Rect.fromLTRB(1684.8, -2711.8, 1684.8, -2711.8);
    final g4 = Rect.fromLTRB(1634.8, -2761.8, 1634.8, -2761.8);
    final g5 = Rect.fromLTRB(1249.5, -2761.8, 1249.5, -2761.8);


    
    // print(view.intersect(g1));
    // print(view.intersect(g1).width);
    // print(view.intersect(g1).height);
    // print(view.contains(Offset(1200, dy)));
    print(view.overlaps(g1));
    // print(view.intersect(g2));
    // print(view.intersect(g3));
    // print(view.intersect(g4));
    // print(view.intersect(g5));

    // Rect.fromPoints(Offset(-356, -1000), Offset(720, -382));
  });
}
