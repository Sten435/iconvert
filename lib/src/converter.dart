import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'convert_options.dart';
import 'exceptions.dart';
import 'image_format.dart';

/// A pure Dart image converter supporting multiple formats.
class ImageConverter {
  /// Creates an [ImageConverter] with optional default [options].
  const ImageConverter({this.defaultOptions = const ConvertOptions()});

  /// Default options used when not specified in conversion methods.
  final ConvertOptions defaultOptions;

  /// Converts an image file from [inputPath] to [outputPath] asynchronously.
  ///
  /// The output format is determined by the file extension of [outputPath].
  /// Optionally provide [options] to customize the conversion.
  Future<void> convertFile({
    required String inputPath,
    required String outputPath,
    ConvertOptions? options,
  }) async {
    final inputBytes = await File(inputPath).readAsBytes();
    final outputFormat = _getFormatFromPath(outputPath);
    final opts = options ?? defaultOptions;

    final outputBytes = convert(
      inputBytes: inputBytes,
      outputFormat: outputFormat,
      options: opts,
    );

    await File(outputPath).writeAsBytes(outputBytes);
  }

  /// Converts an image file synchronously.
  ///
  /// Prefer [convertFile] for better performance in most cases.
  void convertFileSync({
    required String inputPath,
    required String outputPath,
    ConvertOptions? options,
  }) {
    final inputBytes = File(inputPath).readAsBytesSync();
    final outputFormat = _getFormatFromPath(outputPath);
    final opts = options ?? defaultOptions;

    final outputBytes = convert(
      inputBytes: Uint8List.fromList(inputBytes),
      outputFormat: outputFormat,
      options: opts,
    );

    File(outputPath).writeAsBytesSync(outputBytes);
  }

  /// Converts image bytes to the specified [outputFormat].
  ///
  /// Returns the encoded image bytes.
  Uint8List convert({
    required Uint8List inputBytes,
    required ImageFormat outputFormat,
    ConvertOptions? options,
  }) {
    final opts = options ?? defaultOptions;

    img.Image? image;
    try {
      image = img.decodeImage(inputBytes);
    } catch (error) {
      print('Error decoding image data: ${error.toString()}');
    } finally {
      if (image == null) {
        throw const ImageDecodeException('Unsupported or corrupted image data.');
      }
    }

    image = _applyResize(image, opts);
    image = _applyBackgroundIfNeeded(image, outputFormat, opts);

    return Uint8List.fromList(_encode(image, outputFormat, opts));
  }

  /// Batch converts all images in [inputDirectory] to [outputDirectory].
  ///
  /// Converts to [outputFormat] and optionally applies [options].
  /// Returns the number of successfully converted files.
  Future<int> batchConvert({
    required String inputDirectory,
    required String outputDirectory,
    required ImageFormat outputFormat,
    ConvertOptions? options,
  }) async {
    final inputDir = Directory(inputDirectory);
    final outputDir = Directory(outputDirectory);

    if (!await inputDir.exists()) {
      throw ImageConvertException(
        'Input directory does not exist: $inputDirectory',
      );
    }

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    var count = 0;
    final entities = await inputDir.list().toList();

    for (final entity in entities) {
      if (entity is! File) continue;

      final inputPath = entity.path;
      if (!_isSupportedInput(inputPath)) continue;

      final fileName = _getFileNameWithoutExtension(inputPath);
      final outputPath = '${outputDir.path}${Platform.pathSeparator}$fileName.${outputFormat.extension}';

      try {
        await convertFile(
          inputPath: inputPath,
          outputPath: outputPath,
          options: options,
        );
        count++;
      } on ImageConvertException {
        // Skip files that fail to convert
        continue;
      }
    }

    return count;
  }

  /// Batch converts all images synchronously.
  ///
  /// Prefer [batchConvert] for better performance in most cases.
  int batchConvertSync({
    required String inputDirectory,
    required String outputDirectory,
    required ImageFormat outputFormat,
    ConvertOptions? options,
  }) {
    final inputDir = Directory(inputDirectory);
    final outputDir = Directory(outputDirectory);

    if (!inputDir.existsSync()) {
      throw ImageConvertException(
        'Input directory does not exist: $inputDirectory',
      );
    }

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    var count = 0;
    final entities = inputDir.listSync();

    for (final entity in entities) {
      if (entity is! File) continue;

      final inputPath = entity.path;
      if (!_isSupportedInput(inputPath)) continue;

      final fileName = _getFileNameWithoutExtension(inputPath);
      final outputPath = '${outputDir.path}${Platform.pathSeparator}$fileName.${outputFormat.extension}';

      try {
        convertFileSync(
          inputPath: inputPath,
          outputPath: outputPath,
          options: options,
        );
        count++;
      } on ImageConvertException {
        // Skip files that fail to convert
        continue;
      }
    }

    return count;
  }

  /// Returns a list of supported input format extensions.
  static List<String> get supportedInputFormats => ['png', 'jpg', 'jpeg', 'bmp', 'gif', 'tiff', 'tif', 'webp', 'ico'];

  /// Returns a list of supported output format extensions.
  static List<String> get supportedOutputFormats => ['png', 'jpg', 'jpeg', 'bmp', 'gif', 'tiff', 'tif', 'webp', 'ico'];

  ImageFormat _getFormatFromPath(String path) {
    final extension = path.split('.').last;
    return ImageFormat.fromExtension(extension);
  }

  bool _isSupportedInput(String path) {
    final extension = path.split('.').last.toLowerCase();
    return supportedInputFormats.contains(extension);
  }

  String _getFileNameWithoutExtension(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  img.Image _applyResize(img.Image image, ConvertOptions options) {
    if (options.width == null && options.height == null) {
      return image;
    }

    return img.copyResize(
      image,
      width: options.width ?? -1,
      height: options.height ?? -1,
      maintainAspect: options.maintainAspectRatio,
    );
  }

  img.Image _applyBackgroundIfNeeded(
    img.Image image,
    ImageFormat format,
    ConvertOptions options,
  ) {
    if (format.supportsTransparency) {
      return image;
    }

    // For formats without transparency, fill transparent pixels
    final bgColor = options.backgroundColor;
    final background = bgColor != null ? img.ColorRgba8(bgColor.red, bgColor.green, bgColor.blue, 255) : img.ColorRgba8(255, 255, 255, 255); // Default to white

    final result = img.Image(width: image.width, height: image.height, backgroundColor: background);
    return img.compositeImage(result, image);
  }

  List<int> _encode(
    img.Image image,
    ImageFormat format,
    ConvertOptions options,
  ) {
    return switch (format) {
      ImageFormat.png => img.encodePng(image),
      ImageFormat.jpg || ImageFormat.jpeg => img.encodeJpg(
          image,
          quality: options.quality,
        ),
      ImageFormat.bmp => img.encodeBmp(image),
      ImageFormat.gif => img.encodeGif(image),
      ImageFormat.tiff || ImageFormat.tif => img.encodeTiff(image),
      ImageFormat.ico => img.encodeIco(image),
    };
  }
}
