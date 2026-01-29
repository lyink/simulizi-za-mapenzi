import 'dart:io';

void main() async {
  // Create a simple logo with a green background and white K
  final logoContent = '''
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#1B5E20"/>
  <text x="50%" y="50%" font-family="Arial" font-size="500" font-weight="bold" fill="white" text-anchor="middle" dominant-baseline="middle">K</text>
</svg>
''';
  
  // Ensure the images directory exists
  final imagesDir = Directory('assets/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  
  // Write the logo file
  final file = File('assets/images/logo.png');
  await file.writeAsString(logoContent);
  
  print('Logo created at: ${file.absolute.path}');
  exit(0);
}
