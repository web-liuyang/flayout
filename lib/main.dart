import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:blueprint_master/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Uint8List createBitmap(int width, int height) {
  return Uint8List(width * height * 4); // RGBA
}

void setPixel(Uint8List bitmap, int x, int y, int width, List<int> color) {
  final index = (y * width + x) * 4;
  bitmap[index] = color[0]; // R
  bitmap[index + 1] = color[1]; // G
  bitmap[index + 2] = color[2]; // B
  bitmap[index + 3] = color[3]; // A
}

void drawLine(Uint8List bitmap, int width, int height, int x1, int y1, int x2, int y2, List<int> color, [int lineWidth = 1]) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final steps = max(dx.abs(), dy.abs());

  for (int i = 0; i <= steps; i++) {
    final x = (x1 + (dx * i) / steps).round();
    final y = (y1 + (dy * i) / steps).round();

    final halfWidth = (lineWidth / 2).floor();

    for (int w = -halfWidth; w <= halfWidth; w++) {
      final xOffset = x + w;
      if (xOffset >= 0 && xOffset < width && y >= 0 && y < height) {
        setPixel(bitmap, xOffset, y, width, color);
      }
    }

    // if (x >= 0 && x < width && y >= 0 && y < height) {
    //   setPixel(bitmap, x, y, width, color);
    // }
  }
}

// void drawLine(bitmap: Uint8Array, width: number, height: number, x1: number, y1: number, x2: number, y2: number, color: [number, number, number, number], lineWidth: number) {
//     const dx = x2 - x1;
//     const dy = y2 - y1;
//     const steps = Math.max(Math.abs(dx), Math.abs(dy));

//     for (let i = 0; i <= steps; i++) {
//         const x = Math.round(x1 + (dx * i) / steps);
//         const y = Math.round(y1 + (dy * i) / steps);

//         // 绘制线条的宽度
//         for (let w = -Math.floor(lineWidth / 2); w <= Math.floor(lineWidth / 2); w++) {
//             const xOffset = x + w;
//             if (xOffset >= 0 && xOffset < width && y >= 0 && y < height) {
//                 setPixel(bitmap, xOffset, y, width, color);
//             }
//         }
//     }
// }

Future<ui.Image> createImageFromUint8List(Uint8List pixels, int width, int height) async {
  final descriptor = ui.ImageDescriptor.raw(await ui.ImmutableBuffer.fromUint8List(pixels), width: width, height: height, pixelFormat: ui.PixelFormat.rgba8888);

  // 生成图像编码器
  final codec = await descriptor.instantiateCodec(targetWidth: width, targetHeight: height);

  // 获取图像帧
  final frame = await codec.getNextFrame();

  return frame.image; // 返回生成的图像
}

Future<ui.Image> resizeImage(ui.Image image, int newWidth, int newHeight) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // 在 Canvas 上绘制原始图像，并缩放到新的宽高
  canvas.drawImage(image, Offset.zero, Paint());

  // 结束绘制并生成新图像
  final picture = recorder.endRecording();
  final resizedImage = await picture.toImage(newWidth, newHeight);
  return resizedImage;
}

Future<ui.Image> drawTest() async {
  const int dpi = 2;
  const int width = 50 * dpi;
  const int height = 50 * dpi;
  const int lineWidth = 1 * dpi;

  // 创建 ui.Image

  final Uint8List bitmap = createBitmap(width, height);
  bitmap.fillRange(0, bitmap.length, 255); // 填充为白色背景

  // 绘制光滑的斜线
  drawLine(bitmap, width, height, 0, 0, width, height, [0, 0, 255, 255], lineWidth); // 蓝色线条

  ui.Image image = await createImageFromUint8List(bitmap, width, height);
  // image = await resizeImage(image, (width / dpi).round(), (height / dpi).round());
  return image;
}

void main() async {
  // 创建一个示例的 Uint8List（这里填充为红色像素）

  const int width = 200;
  const int height = 200;

  // 创建 ui.Image

  final Uint8List bitmap = createBitmap(width, height);
  bitmap.fillRange(0, bitmap.length, 255); // 填充为白色背景

  // 绘制光滑的斜线
  drawLine(bitmap, width, height, 0, 0, width, height, [0, 0, 255, 255]); // 蓝色线条
  // 这里可以将bitmap用于其他目的，比如显示在Canvas上
  // final buffer = await ui.ImmutableBuffer.fromUint8List(bitmap);
  // final codec = await ui.instantiateImageCodecFromBuffer(buffer);
  ui.Image image = await createImageFromUint8List(bitmap, width, height);
  image = await resizeImage(image, (width / 2).round(), (height / 2).round());
  // final codec = await ui.instantiateImageCodec(bitmap, allowUpscaling: false);
  // final info = await codec.getNextFrame();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);

  // 保存为PNG文件
  await File('line2.png').writeAsBytes(data!.buffer.asUint8List());

  print('图片已保存为 line.png');

  runApp(const BlueprintMaster());
}

class BlueprintMaster extends StatelessWidget {
  const BlueprintMaster({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(brightness: Brightness.light, useMaterial3: true, colorScheme: ColorScheme.light());
    return MaterialApp(title: "Blueprint Master", themeMode: ThemeMode.system, theme: theme, home: Scaffold(body: const Layout()));
  }
}
