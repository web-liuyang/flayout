import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const double kMaxZoom = 100;
const double kMinZoom = 0.01;

const double kEditorDotGap = 50;
const double kEditorDotSize = 1;
const double kEditorAxisLength = 50;
const double kEditorAxisWidth = 1;
const Color kEditorBackgroundColor = Color(0xffffffff);
const Color kEditorAxisColor = Color(0xffff4500);
const Color kEditorSelectedColor = Color(0xFFFF0000);
const double kEditorSelectedStrokeWidth = 2;

const List<Color> kEditorDrawingColors = [
  Colors.transparent,
  Colors.black,
  Colors.white,
  ...Colors.primaries,
];

// Temporary
const double kEditorUnits = 0.001;
final ui.TextStyle kEditorTextStyle = ui.TextStyle(fontSize: 20, color: Color(0xFF000000));
