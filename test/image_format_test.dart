import 'package:iconvert/iconvert.dart';
import 'package:test/test.dart';

void main() {
  group('ImageFormat', () {
    group('fromExtension', () {
      test('parses png extension', () {
        expect(ImageFormat.fromExtension('png'), equals(ImageFormat.png));
        expect(ImageFormat.fromExtension('PNG'), equals(ImageFormat.png));
        expect(ImageFormat.fromExtension('.png'), equals(ImageFormat.png));
      });

      test('parses jpg/jpeg extensions', () {
        expect(ImageFormat.fromExtension('jpg'), equals(ImageFormat.jpg));
        expect(ImageFormat.fromExtension('jpeg'), equals(ImageFormat.jpeg));
        expect(ImageFormat.fromExtension('JPG'), equals(ImageFormat.jpg));
      });

      test('parses bmp extension', () {
        expect(ImageFormat.fromExtension('bmp'), equals(ImageFormat.bmp));
        expect(ImageFormat.fromExtension('BmP'), equals(ImageFormat.bmp));
        expect(ImageFormat.fromExtension('.bmp'), equals(ImageFormat.bmp));
      });

      test('parses gif extension', () {
        expect(ImageFormat.fromExtension('gif'), equals(ImageFormat.gif));
        expect(ImageFormat.fromExtension('GiF'), equals(ImageFormat.gif));
        expect(ImageFormat.fromExtension('.gif'), equals(ImageFormat.gif));
      });

      test('parses tiff/tif extensions', () {
        expect(ImageFormat.fromExtension('tiff'), equals(ImageFormat.tiff));
        expect(ImageFormat.fromExtension('tif'), equals(ImageFormat.tif));
      });

      test('parses ico extension', () {
        expect(ImageFormat.fromExtension('ico'), equals(ImageFormat.ico));
        expect(ImageFormat.fromExtension(' ico '), equals(ImageFormat.ico));
        expect(ImageFormat.fromExtension('. Ico '), equals(ImageFormat.ico));
      });

      test('throws ArgumentError for unsupported format', () {
        expect(
          () => ImageFormat.fromExtension('xyz'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('supportsTransparency', () {
      test('png supports transparency', () {
        expect(ImageFormat.png.supportsTransparency, isTrue);
      });

      test('ico supports transparency', () {
        expect(ImageFormat.ico.supportsTransparency, isTrue);
      });

      test('gif supports transparency', () {
        expect(ImageFormat.gif.supportsTransparency, isTrue);
      });

      test('jpg does not support transparency', () {
        expect(ImageFormat.jpg.supportsTransparency, isFalse);
        expect(ImageFormat.jpeg.supportsTransparency, isFalse);
      });

      test('bmp does not support transparency', () {
        expect(ImageFormat.bmp.supportsTransparency, isFalse);
      });

      test('tiff does not support transparency', () {
        expect(ImageFormat.tiff.supportsTransparency, isFalse);
        expect(ImageFormat.tif.supportsTransparency, isFalse);
      });
    });

    test('extension property returns correct value', () {
      expect(ImageFormat.png.extension, equals('png'));
      expect(ImageFormat.jpg.extension, equals('jpg'));
      expect(ImageFormat.jpeg.extension, equals('jpeg'));
    });
  });
}
