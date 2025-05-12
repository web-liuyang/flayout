import 'dart:ui';

import 'package:blueprint_master/editors/editor_config.dart';
import 'package:flutter/rendering.dart';

import 'base_graphic.dart';

class GroupGraphic extends BaseGraphic {
  GroupGraphic({super.position, this.children = const []});

  final List<BaseGraphic> children;

  void addChild(BaseGraphic child) {
    children.add(child);
  }

  void removeChild(BaseGraphic child) {
    children.remove(child);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print("GroupGraphic");
    // final pr = RendererBinding.instance.createPictureRecorder();
    // final innerCanvas = RendererBinding.instance.createCanvas(pr);
    final renderPosition = position * kEditorUnits;

    canvas.save();

    canvas.translate(renderPosition.dx, renderPosition.dy);
    for (final child in children) {
      child.paint(canvas, size);
      // child.paint(innerCanvas, size);
    }

    canvas.restore();

    // canvas.drawPicture(pr.endRecording());
  }
}
