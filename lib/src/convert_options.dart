/// Simple RGB color representation
class RgbColor {
  /// Creates an RGB color.
  const RgbColor(this.red, this.green, this.blue);

  /// Creates white color.
  static const RgbColor white = RgbColor(255, 255, 255);

  /// Creates black color.
  static const RgbColor black = RgbColor(0, 0, 0);

  /// Red component (0-255).
  final int red;

  /// Green component (0-255).
  final int green;

  /// Blue component (0-255).
  final int blue;
}

/// Options for image conversion.
class ConvertOptions {
  /// Creates conversion options.
  const ConvertOptions({
    this.quality = 90,
    this.width,
    this.height,
    this.maintainAspectRatio = true,
    this.backgroundColor,
    this.icoSize = 256,
  });

  /// Quality for lossy formats (e.g., JPG). Range: 1-100.
  final int quality;

  /// Target width. If null, original width is preserved.
  final int? width;

  /// Target height. If null, original height is preserved.
  final int? height;

  /// Whether to maintain aspect ratio when resizing.
  final bool maintainAspectRatio;

  /// Background color for formats that don't support transparency.
  /// If null, defaults to white for JPG.
  final RgbColor? backgroundColor;

  /// Size for ICO output (default 256x256).
  final int icoSize;

  /// Creates a copy with the given fields replaced.
  ConvertOptions copyWith({
    int? quality,
    int? width,
    int? height,
    bool? maintainAspectRatio,
    RgbColor? backgroundColor,
    int? icoSize,
  }) {
    return ConvertOptions(
      quality: quality ?? this.quality,
      width: width ?? this.width,
      height: height ?? this.height,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icoSize: icoSize ?? this.icoSize,
    );
  }
}
