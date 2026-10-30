import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/core/utils/geez_normalizer.dart';

void main() {
  group('GeezNormalizer Homophone & Orthography Tests', () {
    test('ሀ, ሐ, ኀ series normalizes identically across all orders', () {
      // 1st order
      expect(GeezNormalizer.normalize('ሀገር'), GeezNormalizer.normalize('ሐገር'));
      expect(GeezNormalizer.normalize('ሀገር'), GeezNormalizer.normalize('ኀገር'));

      // 6th order
      expect(GeezNormalizer.normalize('ምህረት'), GeezNormalizer.normalize('ምሕረት'));
      expect(GeezNormalizer.normalize('ምህረት'), GeezNormalizer.normalize('ምኅረት'));

      // 4th order
      expect(GeezNormalizer.normalize('ሃይማኖት'), GeezNormalizer.normalize('ሓይማኖት'));
      expect(GeezNormalizer.normalize('ሃይማኖት'), GeezNormalizer.normalize('ኃይማኖት'));

      // 3rd & 5th order
      expect(GeezNormalizer.normalize('ህይወት'), GeezNormalizer.normalize('ሕይወት'));
      expect(GeezNormalizer.normalize('ብርሃን'), GeezNormalizer.normalize('ብርሓን'));
    });

    test('ሰ and ሠ series normalizes identically', () {
      expect(GeezNormalizer.normalize('ሰላም'), GeezNormalizer.normalize('ሠላም'));
      expect(GeezNormalizer.normalize('ስላሴ'), GeezNormalizer.normalize('ሥላሴ'));
      expect(GeezNormalizer.normalize('ሰው'), GeezNormalizer.normalize('ሠው'));
      expect(GeezNormalizer.normalize('ስጋ'), GeezNormalizer.normalize('ሥጋ'));
    });

    test('አ and ዐ series normalizes identically including everyday fourth orders', () {
      expect(GeezNormalizer.normalize('አለም'), GeezNormalizer.normalize('ዓለም'));
      expect(GeezNormalizer.normalize('አለም'), GeezNormalizer.normalize('ዐለም'));
      expect(GeezNormalizer.normalize('አመት'), GeezNormalizer.normalize('ዓመት'));
      expect(GeezNormalizer.normalize('እምነት'), GeezNormalizer.normalize('ዕምነት'));
      expect(GeezNormalizer.normalize('እግዚአብሔር'), GeezNormalizer.normalize('እግዚዐብሔር'));
    });

    test('ጸ and ፀ series normalizes identically', () {
      expect(GeezNormalizer.normalize('ጸሎት'), GeezNormalizer.normalize('ፀሎት'));
      expect(GeezNormalizer.normalize('ጸጋ'), GeezNormalizer.normalize('ፀጋ'));
      expect(GeezNormalizer.normalize('ጽድቅ'), GeezNormalizer.normalize('ፅድቅ'));
      expect(GeezNormalizer.normalize('ፀሐይ'), GeezNormalizer.normalize('ጸሐይ'));
    });

    test('Punctuation stripping cleans Ethiopic and Western marks', () {
      expect(GeezNormalizer.normalize('«ሰላም፥ ለእናንተ፡ ይሁን።»'), 'ሰላም ለእናንተ ይሁን');
    });
  });

  group('GeezNormalizer Typography & Formatting Tests', () {
    test('cleans newlines, indentation, and spaces before punctuation', () {
      const rawVerse =
          'ወምድርሰ ፡ ኢታስተርኢ ፡ ወኢኮነት ፡ ድሉተ ፡ ወጽልመት ፡ መልዕልተ ፡ ቀላይ ፡ ወመንፈሰ ፡ እግዚአብሔር ፡ ይጼልል ፡\n                  መልዕልተ ፡ ማይ ።';
      const expected =
          'ወምድርሰ፡ ኢታስተርኢ፡ ወኢኮነት፡ ድሉተ፡ ወጽልመት፡ መልዕልተ፡ ቀላይ፡ ወመንፈሰ፡ እግዚአብሔር፡ ይጼልል፡ መልዕልተ፡ ማይ።';
      expect(GeezNormalizer.cleanTypography(rawVerse), expected);
    });

    test('prevents isolated full stop and removes brackets', () {
      const rawVerse =
          'ወርእዮ ፡ እግዚአብሔር ፡ [ለብርሃን] ፡ ከመ ፡ ሠናይ ፡ ወፈለጠ ፡ እግዚአብሔር ፡ ማእከለ ፡ ብርሃን ፡ ወማእከለ ፡ ጽልመት\n                  ።';
      const expected =
          'ወርእዮ፡ እግዚአብሔር፡ ለብርሃን፡ ከመ፡ ሠናይ፡ ወፈለጠ፡ እግዚአብሔር፡ ማእከለ፡ ብርሃን፡ ወማእከለ፡ ጽልመት።';
      expect(GeezNormalizer.cleanTypography(rawVerse), expected);
    });
  });
}
