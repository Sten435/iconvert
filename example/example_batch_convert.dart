import 'dart:io';

import 'package:iconvert/iconvert.dart';

/// Example 3: Batch convert all images in a directory.
///
/// Usage: dart run example/example3_batch_convert.dart <input_dir> <output_dir> <format>
Future<void> main(List<String> arguments) async {
  if (arguments.length != 3) {
    print('Usage: dart run example/example3_batch_convert.dart <input_dir> <output_dir> <format>');
    print('Example: dart run example/example3_batch_convert.dart ./images ./output png');
    print('');
    print('Supported formats: ${ImageConverter.supportedOutputFormats.join(", ")}');
    exit(1);
  }

  final inputDir = arguments[0];
  final outputDir = arguments[1];
  final formatStr = arguments[2];

  if (!Directory(inputDir).existsSync()) {
    print('Error: Input directory does not exist: $inputDir');
    exit(1);
  }

  ImageFormat format;
  try {
    format = ImageFormat.fromExtension(formatStr);
  } on ArgumentError {
    print('Error: Unsupported format: $formatStr');
    print('Supported formats: ${ImageConverter.supportedOutputFormats.join(", ")}');
    exit(1);
  }

  try {
    const converter = ImageConverter();

    print('Converting images in $inputDir to $format format...');

    final count = await converter.batchConvert(
      inputDirectory: inputDir,
      outputDirectory: outputDir,
      outputFormat: format,
    );

    print('✅ Successfully converted $count images to $outputDir');
  } on ImageConvertException catch (e) {
    print('❌ Batch conversion failed: $e');
    exit(1);
  }
}
