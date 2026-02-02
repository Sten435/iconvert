import 'package:iconvert/iconvert.dart';
import 'package:test/test.dart';

void main() {
  group('ImageConvertException', () {
    test('stores message', () {
      const exception = ImageConvertException('test error');
      expect(exception.message, equals('test error'));
    });

    test('toString includes class name and message', () {
      const exception = ImageConvertException('test error');
      expect(exception.toString(), equals('ImageConvertException: test error'));
    });
  });

  group('ImageDecodeException', () {
    test('creates message with path', () {
      const exception = ImageDecodeException('test.png');
      expect(exception.message, equals('Failed to decode image: test.png'));
    });

    test('is an ImageConvertException', () {
      const exception = ImageDecodeException('test.png');
      expect(exception, isA<ImageConvertException>());
    });
  });

  group('UnsupportedFormatException', () {
    test('creates message with format', () {
      const exception = UnsupportedFormatException('.xyz');
      expect(exception.message, equals('Unsupported output format: .xyz'));
    });

    test('is an ImageConvertException', () {
      const exception = UnsupportedFormatException('.xyz');
      expect(exception, isA<ImageConvertException>());
    });
  });
}
