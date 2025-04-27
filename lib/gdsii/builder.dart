import 'dart:math';
import 'dart:typed_data';

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

  void handlePresentation(ByteData data) {
    print("Presentation");
  }

  void handlePathtype(ByteData data) {
    print("Pathtype");
  }

  void handleWidth(ByteData data) {
    print("Width");
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
  TextStruct({required this.layer, required this.texttype, required this.vMirror, required this.string, required this.points});

  final int layer;

  final int texttype;

  final bool vMirror;

  final List<Point> points;

  final String string;
}

class TextStructBuilder extends StructBuilder<TextStruct> {
  TextStructBuilder();

  late int layer = 0;

  late int texttype = 0;

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
          handlePresentation(data);
          break;
        }
      case GdsRecordType.pathtype:
        {
          handlePathtype(data);
          break;
        }
      case GdsRecordType.width:
        {
          handleWidth(data);
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
    return TextStruct(layer: layer, texttype: texttype, vMirror: vMirror, string: string, points: points);
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
  ARefStruct({required this.name, required this.vMirror, required this.magnification, required this.angle, required this.points});

  final String name;

  final bool vMirror;

  final num magnification;

  final num angle;

  final List<Point> points;
}

class ARefStructBuilder extends StructBuilder<ARefStruct> {
  ARefStructBuilder();

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

      case GdsRecordType.colrow:
        {
          print("colrow");
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
  ARefStruct build() {
    return ARefStruct(name: name, vMirror: vMirror, magnification: magnification, angle: angle, points: points);
  }
}
