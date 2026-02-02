import 'dart:io';

import 'package:iconvert/iconvert.dart';

/// Example 1: Simple single file conversion.
///
/// Usage: dart run example/example1_simple_convert.dart <input> <output>
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    print('Usage: dart run example/example1_simple_convert.dart <input> <output>');
    print('Example: dart run example/example1_simple_convert.dart photo.png photo.jpg');
    exit(1);
  }

  final inputPath = arguments[0];
  final outputPath = arguments[1];

  if (!File(inputPath).existsSync()) {
    print('Error: Input file does not exist: $inputPath');
    exit(1);
  }

  try {
    const converter = ImageConverter();
    await converter.convertFile(inputPath: inputPath, outputPath: outputPath);
    print('✅ Converted: $inputPath → $outputPath');
  } on ImageConvertException catch (e) {
    print('❌ Conversion failed: $e');
    exit(1);
  }
}
