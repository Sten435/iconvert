import 'dart:io';

import 'package:iconvert/iconvert.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

import 'helper/test_helpers.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = createTempTestDirectory();
  });

  tearDown(() {
    cleanupTempDirectory(tempDir);
  });

  group('Integration tests', () {
    test('full workflow: create, convert, verify', () async {
      // Create a test image
      final originalBytes = createTestImage(
        width: 200,
        height: 150,
        red: 100,
        green: 150,
        blue: 200,
      );

      final inputPath =
          writeTestImageToFile(tempDir, 'original.png', originalBytes);
      final outputPath = '${tempDir.path}/converted.jpg';

      // Convert
      const converter = ImageConverter();
      await converter.convertFile(
        inputPath: inputPath,
        outputPath: outputPath,
        options: const ConvertOptions(quality: 85),
      );

      // Verify
      final outputFile = File(outputPath);
      expect(outputFile.existsSync(), isTrue);

      final decoded = img.decodeImage(outputFile.readAsBytesSync());
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(200));
      expect(decoded.height, equals(150));
    });

    test('chain conversions: PNG → JPG → BMP → PNG', () {
      final originalBytes = createTestImage();
      const converter = ImageConverter();

      // PNG → JPG
      final jpgBytes = converter.convert(
        inputBytes: originalBytes,
        outputFormat: ImageFormat.jpg,
      );

      // JPG → BMP
      final bmpBytes = converter.convert(
        inputBytes: jpgBytes,
        outputFormat: ImageFormat.bmp,
      );

      // BMP → PNG
      final pngBytes = converter.convert(
        inputBytes: bmpBytes,
        outputFormat: ImageFormat.png,
      );

      final decoded = img.decodeImage(pngBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(100));
      expect(decoded.height, equals(100));
    });

    test('batch conversion with mixed formats', () async {
      // Create images in different formats
      final pngBytes = createTestImage(red: 255, green: 0, blue: 0);
      writeTestImageToFile(tempDir, 'red.png', pngBytes);

      final greenBytes = createTestImage(red: 0, green: 255, blue: 0);
      writeTestImageToFile(tempDir, 'green.png', greenBytes);

      final outputDir = Directory('${tempDir.path}/output');

      const converter = ImageConverter();
      final count = await converter.batchConvert(
        inputDirectory: tempDir.path,
        outputDirectory: outputDir.path,
        outputFormat: ImageFormat.jpg,
        options: const ConvertOptions(quality: 80),
      );

      expect(count, equals(2));

      // Verify both files exist
      expect(File('${outputDir.path}/red.jpg').existsSync(), isTrue);
      expect(File('${outputDir.path}/green.jpg').existsSync(), isTrue);
    });

    test('resize and convert in one operation', () async {
      final largeImage = createTestImage(width: 1000, height: 800);
      final inputPath = writeTestImageToFile(tempDir, 'large.png', largeImage);
      final outputPath = '${tempDir.path}/thumbnail.jpg';

      const converter = ImageConverter();
      await converter.convertFile(
        inputPath: inputPath,
        outputPath: outputPath,
        options: const ConvertOptions(
          width: 100,
          height: 80,
          quality: 75,
        ),
      );

      final decoded = img.decodeImage(File(outputPath).readAsBytesSync());
      expect(decoded!.width, equals(100));
      expect(decoded.height, equals(80));
    });

    test('converter reuse with different options', () {
      const converter = ImageConverter(
        defaultOptions: ConvertOptions(quality: 50),
      );

      final imageBytes = createTestImage();

      // Use default options
      final result1 = converter.convert(
        inputBytes: imageBytes,
        outputFormat: ImageFormat.jpg,
      );

      // Use custom options
      final result2 = converter.convert(
        inputBytes: imageBytes,
        outputFormat: ImageFormat.jpg,
        options: const ConvertOptions(quality: 100),
      );

      // Higher quality should produce larger file
      expect(result2.length, greaterThan(result1.length));
    });
  });
}
