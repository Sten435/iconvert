import 'dart:io';

import 'package:iconvert/iconvert.dart';

/// Example 4: Interactive CLI image converter.
///
/// Usage: dart run example/example4_interactive.dart
Future<void> main() async {
  print('╔══════════════════════════════════════╗');
  print('║      iConvert - Image Converter      ║');
  print('╚══════════════════════════════════════╝');
  print('');

  final inputPath = _prompt('Enter input file path: ');
  if (!File(inputPath).existsSync()) {
    print('❌ Error: File does not exist: $inputPath');
    exit(1);
  }

  print('');
  print('Supported output formats: ${ImageConverter.supportedOutputFormats.join(", ")}');
  final formatStr = _prompt('Enter output format: ');

  ImageFormat format;
  try {
    format = ImageFormat.fromExtension(formatStr);
  } on ArgumentError {
    print('❌ Error: Unsupported format: $formatStr');
    exit(1);
  }

  final defaultOutput = _changeExtension(inputPath, format.extension);
  final outputPath = _prompt('Enter output path [$defaultOutput]: ', defaultValue: defaultOutput);

  print('');
  final resizeChoice = _prompt('Resize image? (y/n) [n]: ', defaultValue: 'n');
  int? width;
  int? height;
  if (resizeChoice.toLowerCase() == 'y') {
    final widthStr = _prompt('Enter width (or leave empty for auto): ', defaultValue: '');
    final heightStr = _prompt('Enter height (or leave empty for auto): ', defaultValue: '');
    width = widthStr.isNotEmpty ? int.tryParse(widthStr) : null;
    height = heightStr.isNotEmpty ? int.tryParse(heightStr) : null;
  }

  var quality = 90;
  if (format == ImageFormat.jpg || format == ImageFormat.jpeg) {
    final qualityStr = _prompt('Enter quality (1-100) [90]: ', defaultValue: '90');
    quality = int.tryParse(qualityStr) ?? 90;
  }

  print('');
  print('Converting...');

  try {
    const converter = ImageConverter();

    final options = ConvertOptions(
      width: width,
      height: height,
      quality: quality,
    );

    await converter.convertFile(
      inputPath: inputPath,
      outputPath: outputPath,
      options: options,
    );

    print('');
    print('✅ Success! Converted: $inputPath → $outputPath');

    final outputFile = File(outputPath);
    final inputFile = File(inputPath);
    print('   Input size:  ${_formatBytes(inputFile.lengthSync())}');
    print('   Output size: ${_formatBytes(outputFile.lengthSync())}');
  } on ImageConvertException catch (e) {
    print('❌ Conversion failed: $e');
    exit(1);
  }
}

String _prompt(String message, {String? defaultValue}) {
  stdout.write(message);
  final input = stdin.readLineSync()?.trim() ?? '';
  return input.isEmpty && defaultValue != null ? defaultValue : input;
}

String _changeExtension(String path, String newExtension) {
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1) {
    return '$path.$newExtension';
  }
  return '${path.substring(0, lastDot)}.$newExtension';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
