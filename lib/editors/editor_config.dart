import 'package:flutter/material.dart';

const double kMaxZoom = 1000;
const double kMinZoom = 0.001;

const double kEditorDotGap = 50;
const double kEditorDotSize = 1;
const double kEditorAxisLength = 50;
const double kEditorAxisWidth = 1;
const Color kEditorBackgroundColor = Color(0xffffffff);
const Color kEditorAxisColor = Color(0xffff4500);
const Color kEditorSelectedColor = Color(0xFFFF0000);
const double kEditorSelectedStrokeWidth = 2;

const List<Color> kMonochrome = [Colors.transparent, Colors.white, Colors.black];

const List<Color> kEditorDrawingColors = [
  ...kMonochrome,
  ...Colors.primaries,
];

// Temporary
const double kEditorUnits = 0.001;

const double kEditorTextSize = 20;
const Color kEditorTextColor = Color(0xFF000000);
