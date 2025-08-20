import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'gdsii.dart';

double readf64(ByteData data) {
  final int raw = data.getUint64(0);

  // 提取各部分
  final sign = (raw >>> (8 * 8 - 1) == 1) ? -1 : 1;
  final exponent = ((raw >> (8 * 7)) & 0x7F) - 64; // Excess-64
  final mantissa = (raw & 0x00FF_FFFF_FFFF_FFFF) / pow(2, 8 * 7);

  return sign * mantissa * pow(16, exponent);
}

List<Point> readXY(ByteData data) {
  final int length = data.lengthInBytes;
  final List<Point> point = [];
  for (int i = 0; i < length; i += 8) {
    final int x = data.getInt32(i);
    final int y = data.getInt32(i + 4);
    point.add(Point(x, y));
  }

  return point;
}

(DateTime, DateTime) readTime(ByteData data) {
  return (
    DateTime(
      //
      data.getUint16(0),
      data.getUint16(2),
      data.getUint16(4),
      data.getUint16(6),
      data.getUint16(8),
      data.getUint16(10),
    ),
    DateTime(
      //
      data.getUint16(12),
      data.getUint16(14),
      data.getUint16(16),
      data.getUint16(18),
      data.getUint16(20),
      data.getUint16(22),
    ),
  );
}

String readString(ByteData data) {
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return String.fromCharCodes(bytes).trim();
}

Iterable<(GDSIIRecordType, ByteData)> recordReader(File file) sync* {
  final Uint8List bytes = file.readAsBytesSync();
  final ByteData stream = ByteData.view(bytes.buffer);
  final int length = stream.lengthInBytes;
  final Set<GDSIIRecordType> records = {};

  for (int offset = 0; offset < length;) {
    final currentRecordSize = stream.getUint16(offset);
    if (currentRecordSize == 0) break;

    final type = stream.getUint16(offset + 2);
    final GDSIIRecordType? gdsRecordType = GDSIIRecordType.normalize(type);
    if (gdsRecordType == null) throw UnimplementedError("type: $type");

    records.add(gdsRecordType);

    final data = ByteData.sublistView(stream, offset + 4, offset + currentRecordSize);
    offset += currentRecordSize;
    yield (gdsRecordType, data);
  }
}
