import 'package:iconvert/iconvert.dart';
import 'package:test/test.dart';

void main() {
  group('ConvertOptions', () {
    test('has correct default values', () {
      const options = ConvertOptions();

      expect(options.quality, equals(90));
      expect(options.width, isNull);
      expect(options.height, isNull);
      expect(options.maintainAspectRatio, isTrue);
      expect(options.backgroundColor, isNull);
      expect(options.icoSize, equals(256));
    });

    test('accepts custom values', () {
      const options = ConvertOptions(
        quality: 75,
        width: 800,
        height: 600,
        maintainAspectRatio: false,
        backgroundColor: RgbColor.black,
        icoSize: 128,
      );

      expect(options.quality, equals(75));
      expect(options.width, equals(800));
      expect(options.height, equals(600));
      expect(options.maintainAspectRatio, isFalse);
      expect(options.backgroundColor, isNotNull);
      expect(options.backgroundColor!.red, equals(0));
      expect(options.icoSize, equals(128));
    });

    group('copyWith', () {
      test('creates copy with replaced quality', () {
        const original = ConvertOptions(quality: 90);
        final copy = original.copyWith(quality: 50);

        expect(copy.quality, equals(50));
        expect(original.quality, equals(90));
      });

      test('creates copy with replaced dimensions', () {
        const original = ConvertOptions();
        final copy = original.copyWith(width: 1024, height: 768);

        expect(copy.width, equals(1024));
        expect(copy.height, equals(768));
        expect(original.width, isNull);
        expect(original.height, isNull);
      });

      test('preserves unchanged values', () {
        const original = ConvertOptions(
          quality: 85,
          width: 500,
          maintainAspectRatio: false,
        );
        final copy = original.copyWith(height: 300);

        expect(copy.quality, equals(85));
        expect(copy.width, equals(500));
        expect(copy.height, equals(300));
        expect(copy.maintainAspectRatio, isFalse);
      });
    });
  });

  group('RgbColor', () {
    test('creates color with RGB values', () {
      const color = RgbColor(100, 150, 200);

      expect(color.red, equals(100));
      expect(color.green, equals(150));
      expect(color.blue, equals(200));
    });

    test('white constant is correct', () {
      expect(RgbColor.white.red, equals(255));
      expect(RgbColor.white.green, equals(255));
      expect(RgbColor.white.blue, equals(255));
    });

    test('black constant is correct', () {
      expect(RgbColor.black.red, equals(0));
      expect(RgbColor.black.green, equals(0));
      expect(RgbColor.black.blue, equals(0));
    });
  });
}
