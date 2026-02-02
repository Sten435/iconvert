/// Exception thrown when image conversion fails.
class ImageConvertException implements Exception {
  /// Creates an [ImageConvertException] with the given [message].
  const ImageConvertException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'ImageConvertException: $message';
}

/// Exception thrown when the input image cannot be decoded.
class ImageDecodeException extends ImageConvertException {
  /// Creates an [ImageDecodeException] for the given [path].
  const ImageDecodeException(String path)
      : super('Failed to decode image: $path');
}

/// Exception thrown when the output format is not supported.
class UnsupportedFormatException extends ImageConvertException {
  /// Creates an [UnsupportedFormatException] for the given [format].
  const UnsupportedFormatException(String format)
      : super('Unsupported output format: $format');
}
