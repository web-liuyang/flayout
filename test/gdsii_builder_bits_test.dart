import 'dart:typed_data';

import 'package:flayout/gdsii/builder.dart';
import 'package:flutter_test/flutter_test.dart';

class _StructBuilderProbe extends StructBuilder<void> {
  @override
  void handle(type, ByteData data) {}

  @override
  void build() {}
}

void main() {
  test('handleStrans parses vMirror from highest bit', () {
    final probe = _StructBuilderProbe();

    final mirrored = ByteData(2)..setUint8(0, 0x80);
    final normal = ByteData(2)..setUint8(0, 0x00);

    expect(probe.handleStrans(mirrored), isTrue);
    expect(probe.handleStrans(normal), isFalse);
  });
}
