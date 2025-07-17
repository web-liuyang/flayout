import 'dart:ui';

final double kMaxZoom = 100;
final double kMinZoom = 0.01;

final double kEditorDotGap = 40;
final double kEditorDotSize = 1;
final double kEditorAxisLength = 40;
final double kEditorAxisWidth = 1;
final Color kEditorBackgroundColor = Color(0xffffffff);
final Color kEditorAxisColor = Color(0xffff4500);

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
