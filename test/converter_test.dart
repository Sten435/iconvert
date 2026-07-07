import 'dart:io';
import 'dart:typed_data';

import 'package:iconvert/iconvert.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

import 'helper/test_helpers.dart';

void main() {
  late Directory tempDir;
  late Uint8List testImageBytes;

  setUp(() {
    tempDir = createTempTestDirectory();
    testImageBytes = createTestImage();
  });

  tearDown(() {
    cleanupTempDirectory(tempDir);
  });

  group('ImageConverter', () {
    group('constructor', () {
      test('creates with default options', () {
        const converter = ImageConverter();
        expect(converter.defaultOptions.quality, equals(90));
      });

      test('creates with custom default options', () {
        const options = ConvertOptions(quality: 75);
        const converter = ImageConverter(defaultOptions: options);
        expect(converter.defaultOptions.quality, equals(75));
      });
    });

    group('convert (bytes)', () {
      test('converts PNG to JPG', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.jpg,
        );

        expect(result, isNotEmpty);
        final decoded = img.decodeImage(result);
        expect(decoded, isNotNull);
      });

      test('converts PNG to BMP', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.bmp,
        );

        expect(result, isNotEmpty);
      });

      test('converts PNG to GIF', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.gif,
        );

        expect(result, isNotEmpty);
      });

      test('converts PNG to TIFF', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.tiff,
        );

        expect(result, isNotEmpty);
      });

      test('converts PNG to ICO', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.ico,
        );

        expect(result, isNotEmpty);
      });

      test('converts PNG to PNG (same format)', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.png,
        );

        expect(result, isNotEmpty);
      });

      test('throws ImageDecodeException for corrupted input', () {
        const converter = ImageConverter();
        final corrupted = createCorruptedImageBytes();

        expect(
          () => converter.convert(
            inputBytes: corrupted,
            outputFormat: ImageFormat.png,
          ),
          throwsA(isA<ImageDecodeException>()),
        );
      });

      test('applies custom quality option', () {
        const converter = ImageConverter();
        const lowQuality = ConvertOptions(quality: 10);
        const highQuality = ConvertOptions(quality: 100);

        final lowResult = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.jpg,
          options: lowQuality,
        );

        final highResult = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.jpg,
          options: highQuality,
        );

        // Lower quality should produce smaller file
        expect(lowResult.length, lessThan(highResult.length));
      });

      test('applies resize options', () {
        const converter = ImageConverter();
        const options = ConvertOptions(width: 50, height: 50);

        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: ImageFormat.png,
          options: options,
        );

        final decoded = img.decodeImage(result);
        expect(decoded, isNotNull);
        expect(decoded!.width, equals(50));
        expect(decoded.height, equals(50));
      });

      test('maintains aspect ratio when resizing', () {
        final wideImage = createTestImage(width: 200, height: 100);
        const converter = ImageConverter();
        const options = ConvertOptions(
          width: 100,
          height: 50,
          maintainAspectRatio: true,
        );

        final result = converter.convert(
          inputBytes: wideImage,
          outputFormat: ImageFormat.png,
          options: options,
        );

        final decoded = img.decodeImage(result);
        expect(decoded, isNotNull);
        expect(decoded!.width, equals(100));
        expect(decoded.height, equals(50));
      });
    });

    group('convertFile', () {
      test('converts file from PNG to JPG', () async {
        final inputPath = writeTestImageToFile(
          tempDir,
          'input.png',
          testImageBytes,
        );
        final outputPath = '${tempDir.path}/output.jpg';

        const converter = ImageConverter();
        await converter.convertFile(
            inputPath: inputPath, outputPath: outputPath);

        expect(File(outputPath).existsSync(), isTrue);
        expect(File(outputPath).lengthSync(), greaterThan(0));
      });

      test('converts file with custom options', () async {
        final inputPath = writeTestImageToFile(
          tempDir,
          'input.png',
          testImageBytes,
        );
        final outputPath = '${tempDir.path}/output.jpg';

        const converter = ImageConverter();
        const options = ConvertOptions(quality: 50, width: 50, height: 50);

        await converter.convertFile(
          inputPath: inputPath,
          outputPath: outputPath,
          options: options,
        );

        final outputFile = File(outputPath);
        expect(outputFile.existsSync(), isTrue);

        final decoded = img.decodeImage(outputFile.readAsBytesSync());
        expect(decoded!.width, equals(50));
      });

      test('throws FileSystemException for non-existent input', () async {
        const converter = ImageConverter();

        expect(
          () => converter.convertFile(
            inputPath: '${tempDir.path}/nonexistent.png',
            outputPath: '${tempDir.path}/output.jpg',
          ),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('batchConvert', () {
      test('converts all images in directory', () async {
        // Create multiple test images
        writeTestImageToFile(tempDir, 'image1.png', testImageBytes);
        writeTestImageToFile(tempDir, 'image2.png', testImageBytes);
        writeTestImageToFile(tempDir, 'image3.png', testImageBytes);

        final outputDir = Directory('${tempDir.path}/output');

        const converter = ImageConverter();
        final count = await converter.batchConvert(
          inputDirectory: tempDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.jpg,
        );

        expect(count, equals(3));
        expect(outputDir.existsSync(), isTrue);
        expect(File('${outputDir.path}/image1.jpg').existsSync(), isTrue);
        expect(File('${outputDir.path}/image2.jpg').existsSync(), isTrue);
        expect(File('${outputDir.path}/image3.jpg').existsSync(), isTrue);
      });

      test('creates output directory if it does not exist', () async {
        writeTestImageToFile(tempDir, 'image.png', testImageBytes);

        final outputDir = Directory('${tempDir.path}/new_output');
        expect(outputDir.existsSync(), isFalse);

        const converter = ImageConverter();
        await converter.batchConvert(
          inputDirectory: tempDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.png,
        );

        expect(outputDir.existsSync(), isTrue);
      });

      test('skips unsupported file types', () async {
        writeTestImageToFile(tempDir, 'image.png', testImageBytes);
        File('${tempDir.path}/document.txt').writeAsStringSync('not an image');

        final outputDir = Directory('${tempDir.path}/output');

        const converter = ImageConverter();
        final count = await converter.batchConvert(
          inputDirectory: tempDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.jpg,
        );

        expect(count, equals(1));
      });

      test('skips corrupted images', () async {
        writeTestImageToFile(tempDir, 'good.png', testImageBytes);
        writeTestImageToFile(
          tempDir,
          'bad.png',
          createCorruptedImageBytes(),
        );

        final outputDir = Directory('${tempDir.path}/output');

        const converter = ImageConverter();
        final count = await converter.batchConvert(
          inputDirectory: tempDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.jpg,
        );

        expect(count, equals(1));
      });

      test('returns 0 for empty directory', () async {
        final emptyDir = Directory('${tempDir.path}/empty')..createSync();
        final outputDir = Directory('${tempDir.path}/output');

        const converter = ImageConverter();
        final count = await converter.batchConvert(
          inputDirectory: emptyDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.png,
        );

        expect(count, equals(0));
      });

      test('throws for non-existent input directory', () async {
        const converter = ImageConverter();

        expect(
          () => converter.batchConvert(
            inputDirectory: '${tempDir.path}/nonexistent',
            outputDirectory: '${tempDir.path}/output',
            outputFormat: ImageFormat.png,
          ),
          throwsA(isA<ImageConvertException>()),
        );
      });

      test('applies options to all conversions', () async {
        writeTestImageToFile(tempDir, 'image1.png', testImageBytes);
        writeTestImageToFile(tempDir, 'image2.png', testImageBytes);

        final outputDir = Directory('${tempDir.path}/output');

        const converter = ImageConverter();
        const options = ConvertOptions(width: 25, height: 25);

        await converter.batchConvert(
          inputDirectory: tempDir.path,
          outputDirectory: outputDir.path,
          outputFormat: ImageFormat.png,
          options: options,
        );

        final output1 = img.decodeImage(
          File('${outputDir.path}/image1.png').readAsBytesSync(),
        );
        final output2 = img.decodeImage(
          File('${outputDir.path}/image2.png').readAsBytesSync(),
        );

        expect(output1!.width, equals(25));
        expect(output2!.width, equals(25));
      });
    });

    group('static properties', () {
      test('supportedInputFormats contains expected formats', () {
        final formats = ImageConverter.supportedInputFormats;

        expect(formats, contains('png'));
        expect(formats, contains('jpg'));
        expect(formats, contains('jpeg'));
        expect(formats, contains('bmp'));
        expect(formats, contains('gif'));
        expect(formats, contains('tiff'));
        expect(formats, contains('ico'));
      });

      test('supportedOutputFormats contains expected formats', () {
        final formats = ImageConverter.supportedOutputFormats;

        expect(formats, contains('png'));
        expect(formats, contains('jpg'));
        expect(formats, contains('jpeg'));
        expect(formats, contains('bmp'));
        expect(formats, contains('gif'));
        expect(formats, contains('tiff'));
        expect(formats, contains('ico'));
      });
    });
  });

  group('Format conversion matrix', () {
    const formats = [
      ImageFormat.png,
      ImageFormat.jpg,
      ImageFormat.bmp,
      ImageFormat.gif,
      ImageFormat.tiff,
      ImageFormat.ico,
    ];

    for (final outputFormat in formats) {
      test('PNG → ${outputFormat.extension.toUpperCase()}', () {
        const converter = ImageConverter();
        final result = converter.convert(
          inputBytes: testImageBytes,
          outputFormat: outputFormat,
        );

        expect(result, isNotEmpty);
      });
    }

    test('resizes large images before ICO export', () {
      final largeImage = createTestImage(width: 640, height: 480);
      const converter = ImageConverter();

      final result = converter.convert(
        inputBytes: largeImage,
        outputFormat: ImageFormat.ico,
      );

      expect(result, isNotEmpty);
    });
  });

  group('Transparency handling', () {
    test('preserves transparency for PNG output', () {
      final transparentImage = createTransparentTestImage();
      const converter = ImageConverter();

      final result = converter.convert(
        inputBytes: transparentImage,
        outputFormat: ImageFormat.png,
      );

      final decoded = img.decodeImage(result);
      expect(decoded, isNotNull);

      // Left half (x < 5) should be transparent
      // Right half (x >= 5) should be opaque
      final transparentPixel = decoded!.getPixel(2, 2);
      final opaquePixel = decoded.getPixel(7, 2);

      expect(transparentPixel.a.toInt(), equals(0));
      expect(opaquePixel.a.toInt(), equals(255));
    });

    test('fills background for JPG output', () {
      final transparentImage = createTransparentTestImage();
      const converter = ImageConverter();

      final result = converter.convert(
        inputBytes: transparentImage,
        outputFormat: ImageFormat.jpg,
      );

      final decoded = img.decodeImage(result);
      expect(decoded, isNotNull);

      // JPG doesn't support transparency
      // Previously transparent pixel should now have full alpha
      final pixel = decoded!.getPixel(2, 2);
      expect(pixel.a.toInt(), equals(255));
    });
  });
}
