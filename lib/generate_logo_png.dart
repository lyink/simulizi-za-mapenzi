import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> main() async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const size = Size(1024, 1024);
  
  // Draw background
  final paint = Paint()..color = const Color(0xFF1B5E20);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  
  // Draw K letter
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'K',
      style: TextStyle(
        color: Colors.white,
        fontSize: 500,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ),
  );
  
  // Convert to image
  final img = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Ensure the images directory exists
  final imagesDir = Directory('assets/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  
  // Save to file
  final file = File('assets/images/logo.png');
  await file.writeAsBytes(buffer);
  
  print('Logo created at: ${file.path}');
  exit(0);
}
