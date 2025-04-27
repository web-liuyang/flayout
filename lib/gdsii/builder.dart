import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'gdsii.dart';
import 'gdsii_read_utils.dart';

abstract class Struct {}

abstract class StructBuilder<T> {
  void handle(GdsRecordType type, ByteData data);

  T build();

  void handleElflags(ByteData data) {
    print("Elflags");
  }

  void handlePlex(ByteData data) {
    print("Plex");
  }

  int handleLayer(ByteData data) {
    // print("Layer");
    return data.getUint16(0);
  }

  int handleDatatype(ByteData data) {
    // print("Datatype");
    return data.getUint16(0);
  }

  int handleTexttype(ByteData data) {
    // print("Texttype");
    return data.getUint16(0);
  }

  String handleSname(ByteData data) {
    // print("Sname");
    return readString(data);
  }

  (int, Alignment) handlePresentation(ByteData data) {
    final flags = data.getUint8(1);

    final size = (flags & int.parse("00110000", radix: 2)) >>> 4;
    final vertical = (flags & int.parse("0001100", radix: 2)) >>> 2;
    final horizontal = (flags & int.parse("0000011", radix: 2));

    final alignment = Alignment(
      switch (horizontal) {
        0 => -1,
        1 => 0,
        2 => 1,
        (_) => throw UnimplementedError("horizontal: $horizontal"),
      },
      switch (vertical) {
        0 => -1,
        1 => 0,
        2 => 1,
        (_) => throw UnimplementedError("vertical: $vertical"),
      },
    );

    return (size, alignment);
  }

  void handlePathtype(ByteData data) {
    // print("Pathtype");
  }

  int handleWidth(ByteData data) {
    // print("Width");
    // print(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final width = data.getInt32(0);
    return width;
  }

  void handleBgnextn(ByteData data) {
    // print("bgnextn");
  }

  void handleEndextn(ByteData data) {
    // print("Endextn");
  }

  bool handleStrans(ByteData data) {
    assert(data.lengthInBytes == 2, "Strans length must be 2");
    // AREF 没有处理, 还没有遇到
    final vMirror = data.getUint8(0) == 1;
    return vMirror;
  }

  // bool handleSrefStrans(ByteData data) {
  //   final vMirror = data.getUint8(0) == 1;
  //   return vMirror;
  // }

  // void handleArefStrans(ByteData data) {
  //   print("aref Strans");
  // }

  num handleMag(ByteData data) {
    final magnification = readf64(data);
    return magnification;
  }

  num handleAngle(ByteData data) {
    final angle = readf64(data);
    return angle;
  }

  (int, int) handleColrow(ByteData data) {
    final int offset = (data.lengthInBytes / 2).round();
    final col = data.getInt16(0);
    final row = data.getInt16(offset);
    // 最大不超过 2 ** 15
    return (col, row);
  }

  List<Point> handleXY(ByteData data) {
    final points = readXY(data);
    return points;
  }

  String handleString(ByteData data) {
    final string = readString(data);
    return string;
  }
}

class BoundaryStruct extends Struct {
  BoundaryStruct({required this.layer, required this.datatype, required this.points});

  final int layer;

  final int datatype;

  final List<Point> points;
}

class BoundaryStructBuilder extends StructBuilder<BoundaryStruct> {
  BoundaryStructBuilder();

  late int layer = 0;

  late int datatype = 0;

  late List<Point> points;

  @override
  void handle(GdsRecordType type, ByteData data) {
    switch (type) {
      case GdsRecordType.elflags:
        {
          handleElflags(data);
          break;
        }

      case GdsRecordType.plex:
        {
          handlePlex(data);
          break;
        }

      case GdsRecordType.layer:
        {
          layer = handleLayer(data);
          break;
        }

      case GdsRecordType.datatype:
        {
          datatype = handleDatatype(data);
          break;
        }

      case GdsRecordType.xy:
        {
          points = handleXY(data);
          break;
        }

      default:
        throw UnimplementedError("$runtimeType: ${type.name}");
    }
  }

  @override
  BoundaryStruct build() {
    return BoundaryStruct(points: points, layer: layer, datatype: datatype);
  }
}

class TextStruct extends Struct {
  TextStruct({
    required this.layer,
    required this.texttype,
    required this.size,
    required this.alignment,
    required this.width,
    required this.vMirror,
    required this.string,
    required this.points,
  });

  final int layer;

  final int texttype;

  final int size;

  final Alignment alignment;

  final int width;

  final bool vMirror;

  final List<Point> points;

  final String string;
}

class TextStructBuilder extends StructBuilder<TextStruct> {
  TextStructBuilder();

  late int layer = 0;

  late int texttype = 0;

  late int size = 0;

  late Alignment alignment = Alignment.topLeft;

  late int width = 0;

  late bool vMirror = false;

  late List<Point> points;

  late String string;

  @override
  void handle(GdsRecordType type, ByteData data) {
    switch (type) {
      case GdsRecordType.elflags:
        {
          handleElflags(data);
          break;
        }

      case GdsRecordType.plex:
        {
          handlePlex(data);
          break;
        }

      case GdsRecordType.layer:
        {
          layer = handleLayer(data);
          break;
        }

      case GdsRecordType.texttype:
        {
          texttype = handleTexttype(data);
          break;
        }

      case GdsRecordType.presentation:
        {
          final result = handlePresentation(data);
          size = result.$1;
          alignment = result.$2;
          break;
        }
      case GdsRecordType.pathtype:
        {
          handlePathtype(data);
          break;
        }
      case GdsRecordType.width:
        {
          width = handleWidth(data);
          break;
        }
      case GdsRecordType.strans:
        {
          vMirror = handleStrans(data);
          break;
        }

      case GdsRecordType.mag:
        {
          handleMag(data);
          break;
        }

      case GdsRecordType.angle:
        {
          handleAngle(data);
          break;
        }

      case GdsRecordType.xy:
        {
          points = handleXY(data);
          break;
        }
      case GdsRecordType.string:
        {
          string = handleString(data);
          break;
        }

      default:
        throw UnimplementedError("$runtimeType: ${type.name}");
    }
  }

  @override
  TextStruct build() {
    return TextStruct(layer: layer, texttype: texttype, size: size, alignment: alignment, width: width, vMirror: vMirror, string: string, points: points);
  }
}

class PathStruct extends Struct {
  PathStruct({required this.layer, required this.datatype, required this.width, required this.points});

  final int layer;

  final int datatype;

  final int width;

  final List<Point> points;
}

class PathStructBuilder extends StructBuilder<PathStruct> {
  PathStructBuilder();

  late int layer = 0;

  late int datatype = 0;

  late int width = 0;

  late List<Point> points;

  @override
  void handle(GdsRecordType type, ByteData data) {
    switch (type) {
      case GdsRecordType.elflags:
        {
          handleElflags(data);
          break;
        }

      case GdsRecordType.plex:
        {
          handlePlex(data);
          break;
        }

      case GdsRecordType.layer:
        {
          layer = handleLayer(data);
          break;
        }

      case GdsRecordType.datatype:
        {
          datatype = handleDatatype(data);
          break;
        }

      case GdsRecordType.pathtype:
        {
          handlePathtype(data);
          break;
        }
      case GdsRecordType.width:
        {
          width = handleWidth(data);
          break;
        }

      case GdsRecordType.bgnextn:
        {
          handleBgnextn(data);
          break;
        }

      case GdsRecordType.endextn:
        {
          handleEndextn(data);
          break;
        }

      case GdsRecordType.xy:
        {
          points = handleXY(data);
          break;
        }

      default:
        throw UnimplementedError("$runtimeType: ${type.name}");
    }
  }

  @override
  PathStruct build() {
    return PathStruct(layer: layer, datatype: datatype, width: width, points: points);
  }
}

class SRefStruct extends Struct {
  SRefStruct({required this.name, required this.vMirror, required this.magnification, required this.angle, required this.points});

  final String name;

  final bool vMirror;

  final num magnification;

  final num angle;

  final List<Point> points;
}

class SRefStructBuilder extends StructBuilder<SRefStruct> {
  SRefStructBuilder();

  late String name;

  late bool vMirror = false;

  late num magnification = 1;

  late num angle = 0;

  late List<Point> points;

  @override
  void handle(GdsRecordType type, ByteData data) {
    switch (type) {
      case GdsRecordType.sname:
        {
          name = handleSname(data);
          break;
        }

      case GdsRecordType.strans:
        {
          vMirror = handleStrans(data);
          break;
        }

      case GdsRecordType.mag:
        {
          magnification = handleMag(data);
          break;
        }

      case GdsRecordType.angle:
        {
          angle = handleAngle(data);
          break;
        }

      case GdsRecordType.xy:
        {
          points = handleXY(data);
          break;
        }

      default:
        throw UnimplementedError("$runtimeType: ${type.name}");
    }
  }

  @override
  SRefStruct build() {
    return SRefStruct(name: name, vMirror: vMirror, magnification: magnification, angle: angle, points: points);
  }
}

class ARefStruct extends Struct {
  ARefStruct({
    required this.name,
    required this.vMirror,
    required this.magnification,
    required this.angle,
    required this.col,
    required this.row,
    required this.points,
  });

  final String name;

  final bool vMirror;

  final num magnification;

  final num angle;

  final int col;

  final int row;

  final List<Point> points;
}

class ARefStructBuilder extends StructBuilder<ARefStruct> {
  ARefStructBuilder();

  late String name;

  late bool vMirror = false;

  late num magnification = 1;

  late num angle = 0;

  late (int, int) colrow;

  late List<Point> points;

  @override
  void handle(GdsRecordType type, ByteData data) {
    switch (type) {
      case GdsRecordType.sname:
        {
          name = handleSname(data);
          break;
        }

      case GdsRecordType.strans:
        {
          vMirror = handleStrans(data);
          break;
        }

      case GdsRecordType.mag:
        {
          magnification = handleMag(data);
          break;
        }

      case GdsRecordType.angle:
        {
          angle = handleAngle(data);
          break;
        }

      case GdsRecordType.colrow:
        {
          colrow = handleColrow(data);
          break;
        }

      case GdsRecordType.xy:
        {
          points = handleXY(data);
          break;
        }

      default:
        throw UnimplementedError("$runtimeType: ${type.name}");
    }
  }

  @override
  ARefStruct build() {
    return ARefStruct(name: name, vMirror: vMirror, magnification: magnification, angle: angle, col: colrow.$1, row: colrow.$2, points: points);
  }
}
