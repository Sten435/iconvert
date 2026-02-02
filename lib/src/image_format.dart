/// Supported image formats for conversion.
enum ImageFormat {
  png('png'),
  jpg('jpg'),
  jpeg('jpeg'),
  bmp('bmp'),
  gif('gif'),
  tiff('tiff'),
  tif('tif'),
  ico('ico');

  const ImageFormat(this.extension);

  /// The file extension for this format.
  final String extension;

  /// Parses an [ImageFormat] from a file extension string.
  ///
  /// Throws [ArgumentError] if the extension is not supported.
  static ImageFormat fromExtension(String extension) {
    final normalized = extension.replaceAll('.', '').trim().toLowerCase();
    return ImageFormat.values.firstWhere(
      (format) => format.extension == normalized,
      orElse: () => throw ArgumentError('Unsupported format: $extension'),
    );
  }

  /// Returns `true` if this format supports transparency (alpha channel).
  bool get supportsTransparency =>
      this == ImageFormat.png ||
      this == ImageFormat.ico ||
      this == ImageFormat.gif;
}
