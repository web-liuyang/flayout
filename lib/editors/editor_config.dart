import 'package:flutter/material.dart';

final double kMaxZoom = 100;
final double kMinZoom = 0.01;

final double kEditorDotGap = 50;
final double kEditorDotSize = 1;
final double kEditorAxisLength = 50;
final double kEditorAxisWidth = 1;
final Color kEditorBackgroundColor = Color(0xffffffff);
final Color kEditorAxisColor = Color(0xffff4500);

final List<Color> kEditorDrawingColors = [
  Colors.transparent,
  Colors.black,
  Colors.white,
  ...Colors.primaries,
];

// Temporary
final double kEditorUnits = 0.001;
final TextStyle kEditorTextStyle = TextStyle(fontSize: 20, color: Color(0xFF000000));
// Paint get kEditorPaint =>
//     Paint()
//       ..color = Color(0xFF000000)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
Paint kEditorPaint =
    Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

Paint kEditorHighlightPaint =
    Paint()
      ..color = Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
