import 'dart:ui' as ui;

import 'package:flutter/material.dart';

final double kMaxZoom = 100;
final double kMinZoom = 0.01;

final double kEditorDotGap = 50;
final double kEditorDotSize = 1;
final double kEditorAxisLength = 50;
final double kEditorAxisWidth = 1;
final Color kEditorBackgroundColor = Color(0xffffffff);
final Color kEditorAxisColor = Color(0xffff4500);
final Color kEditorSelectedColor = Color(0xFFFF0000);
final double kEditorSelectedStrokeWidth = 2;

final List<Color> kEditorDrawingColors = [
  Colors.transparent,
  Colors.black,
  Colors.white,
  ...Colors.primaries,
];

// Temporary
final double kEditorUnits = 0.001;
final ui.TextStyle kEditorTextStyle = ui.TextStyle(fontSize: 20, color: Color(0xFF000000));
