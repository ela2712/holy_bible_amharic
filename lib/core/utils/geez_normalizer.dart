/// Ge'ez Homophone Normalizer (የሞክሼ ፊደላት አንድነት ማስተካከያ)
/// Provides phonetic normalization for Ethiopic script searches.
/// Ensures that homophonic characters (ሀ/ሐ/ኀ, ሰ/ሠ, አ/ዐ, ጸ/ፀ) and their labiovelar
/// variations match identically during search operations regardless of orthography.
class GeezNormalizer {
  GeezNormalizer._();

  static const List<String> _punctuations = [
    '፡', '።', '፣', '፤', '፥', '፦', '፠', '፨',
    '.', ',', ';', ':', '!', '?',
    '(', ')', '[', ']', '{', '}',
    '"', "'", '«', '»', '“', '”', '—', '-', '…'
  ];

  static String normalize(String text) {
    if (text.isEmpty) return '';

    String cleaned = text;
    for (final p in _punctuations) {
      cleaned = cleaned.replaceAll(p, ' ');
    }

    return cleaned
        // 1. ሀ series homophones: ሐ, ኀ -> ሀ
        .replaceAll(RegExp(r'[ሐኀ]'), 'ሀ')
        .replaceAll(RegExp(r'[ሑኁ]'), 'ሁ')
        .replaceAll(RegExp(r'[ሒኂ]'), 'ሂ')
        .replaceAll(RegExp(r'[ሓኃ]'), 'ሃ')
        .replaceAll(RegExp(r'[ሔኄ]'), 'ሄ')
        .replaceAll(RegExp(r'[ሕኅ]'), 'ህ')
        .replaceAll(RegExp(r'[ሖኆ]'), 'ሆ')
        .replaceAll('ሗ', 'ኋ')
        .replaceAll('ኈ', 'ሆ')
        .replaceAll('ኊ', 'ሂ')
        .replaceAll('ኌ', 'ሄ')
        .replaceAll('ኍ', 'ሁ')

        // 2. ሰ series homophones: ሠ -> ሰ
        .replaceAll('ሠ', 'ሰ')
        .replaceAll('ሡ', 'ሱ')
        .replaceAll('ሢ', 'ሲ')
        .replaceAll('ሣ', 'ሳ')
        .replaceAll('ሤ', 'ሴ')
        .replaceAll('ሥ', 'ስ')
        .replaceAll('ሦ', 'ሶ')
        .replaceAll('ሧ', 'ሷ')

        // 3. አ series homophones: ዐ, ዓ, ኣ -> አ
        // (In everyday Amharic speech & typing, ዐ/ዓ/ኣ/አ are phonetically equivalent)
        .replaceAll(RegExp(r'[ዐዓኣ]'), 'አ')
        .replaceAll('ዑ', 'ኡ')
        .replaceAll('ዒ', 'ኢ')
        .replaceAll('ዔ', 'ኤ')
        .replaceAll('ዕ', 'እ')
        .replaceAll('ዖ', 'ኦ')

        // 4. ጸ series homophones: ፀ -> ጸ
        .replaceAll('ፀ', 'ጸ')
        .replaceAll('ፁ', 'ጹ')
        .replaceAll('ፂ', 'ጺ')
        .replaceAll('ፃ', 'ጻ')
        .replaceAll('ፄ', 'ጼ')
        .replaceAll('ፅ', 'ጽ')
        .replaceAll('ፆ', 'ጾ')
        .replaceAll('ፇ', 'ጿ')

        // 5. Common labiovelar contractions
        .replaceAll('ኰ', 'ኮ')
        .replaceAll('ኲ', 'ኪ')
        .replaceAll('ኴ', 'ኬ')
        .replaceAll('ኵ', 'ኩ')
        .replaceAll('ጐ', 'ጎ')
        .replaceAll('ጒ', 'ጊ')
        .replaceAll('ጔ', 'ጌ')
        .replaceAll('ጕ', 'ጉ')
        .replaceAll('ቈ', 'ቆ')
        .replaceAll('ቊ', 'ቂ')
        .replaceAll('ቌ', 'ቄ')
        .replaceAll('ቍ', 'ቁ')

        // Lowercase for latin scripts (KJV English text)
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
