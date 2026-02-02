import 'dart:io';

import 'package:iconvert/iconvert.dart';

/// Example 2: Conversion with custom options (resize, quality, background).
///
/// Usage: dart run example/example2_with_options.dart <input> <output> [width] [height] [quality]
Future<void> main(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: dart run example/example2_with_options.dart <input> <output> [width] [height] [quality]');
    print('Example: dart run example/example2_with_options.dart photo.png photo.jpg 800 600 85');
    exit(1);
  }

  final inputPath = arguments[0];
  final outputPath = arguments[1];
  final width = arguments.length > 2 ? int.tryParse(arguments[2]) : null;
  final height = arguments.length > 3 ? int.tryParse(arguments[3]) : null;
  final quality = arguments.length > 4 ? int.tryParse(arguments[4]) ?? 90 : 90;

  if (!File(inputPath).existsSync()) {
    print('Error: Input file does not exist: $inputPath');
    exit(1);
  }

  try {
    const converter = ImageConverter();

    final options = ConvertOptions(
      width: width,
      height: height,
      quality: quality,
      maintainAspectRatio: true,
      backgroundColor: RgbColor.white,
    );

    await converter.convertFile(
      inputPath: inputPath,
      outputPath: outputPath,
      options: options,
    );

    print('✅ Converted: $inputPath → $outputPath');
    if (width != null || height != null) {
      print('   Resized to: ${width ?? "auto"} x ${height ?? "auto"}');
    }
    print('   Quality: $quality');
  } on ImageConvertException catch (e) {
    print('❌ Conversion failed: $e');
    exit(1);
  }
}
