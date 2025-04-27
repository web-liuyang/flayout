import 'package:blueprint_master/gdsii/gdsii.dart';
import 'package:flutter_test/flutter_test.dart';

// 使用示例
void main() async {
  try {} catch (e) {
    print('Error parsing GDSII: $e');
  }

  test("readGdsii: mmi.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('/Users/liuyang/Desktop/store/blueprint_master/test/mmi.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });

  test("readGdsii: MZI_SYSTEM_FOR_2X2.py.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/MZI_SYSTEM_FOR_2X2.py.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });

  test("readGdsii: WBBC2017_top_180531.gds", () {
    Stopwatch stopwatch = Stopwatch()..start();
    readGdsii('/Users/liuyang/Desktop/xiaoyao/ansys/WBBC2017_top_180531.gds');
    stopwatch.stop();
    print('speed: ${stopwatch.elapsedMilliseconds}ms');
  });
}
