import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Creates a simple test image with the specified dimensions and color.
Uint8List createTestImage({
  int width = 100,
  int height = 100,
  int red = 255,
  int green = 0,
  int blue = 0,
  int alpha = 255,
}) {
  final image = img.Image(width: width, height: height);
  final color = img.ColorRgba8(red, green, blue, alpha);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixel(x, y, color);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

/// Creates a test image with transparency (10x10 grid).
/// Left half (x < 5) is transparent, right half (x >= 5) is opaque red.
Uint8List createTransparentTestImage() {
  // Create a 10x10 image with transparency (numChannels: 4 for RGBA)
  final image = img.Image(width: 10, height: 10, numChannels: 4);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (x < 5) {
        // Left half: transparent red
        image.setPixelRgba(x, y, 255, 0, 0, 0);
      } else {
        // Right half: opaque blue
        image.setPixelRgba(x, y, 0, 0, 255, 255);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

/// Creates a temporary directory for tests.
Directory createTempTestDirectory() {
  return Directory.systemTemp.createTempSync('iconvert_test_');
}

/// Writes test image to a file and returns the path.
String writeTestImageToFile(Directory dir, String filename, Uint8List bytes) {
  final file = File('${dir.path}/$filename');
  file.writeAsBytesSync(bytes);
  return file.path;
}

/// Cleans up a temporary test directory.
void cleanupTempDirectory(Directory dir) {
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

/// Creates corrupted/invalid image bytes.
Uint8List createCorruptedImageBytes() {
  return Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x04]);
}
