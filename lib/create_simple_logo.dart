import 'dart:convert';
import 'dart:io';

void main() async {
  // A simple 1x1 green pixel as a base64-encoded PNG
  const base64Logo = 
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z/C/noAEAAJ/Aj2Q8hYAAAAASUVORK5CYII=';
  
  // Decode the base64 string to bytes
  final bytes = base64Decode(base64Logo);
  
  // Ensure the images directory exists
  final imagesDir = Directory('assets/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  
  // Save the logo file
  final file = File('assets/images/logo.png');
  await file.writeAsBytes(bytes);
  
  print('Logo created at: ${file.path}');
  exit(0);
}
