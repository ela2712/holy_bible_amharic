/// Ge'ez Homophone Normalizer
/// Provides phonetic normalization for Ethiopic script searches.
/// Ensures that homophonic characters (e.g. ሀ/ሐ/ኀ, ሰ/ሠ, አ/ዐ, ጸ/ፀ) match identically
/// during search operations regardless of historical orthography.
class GeezNormalizer {
  GeezNormalizer._();

  static const List<String> _punctuations = [
    '፡', '።', '፣', '፤', '፥', '፦',
    '.', ',', ';', ':', '!', '?',
    '(', ')', '[', ']', '"', "'",
    '«', '»', '“', '”', '—', '-'
  ];

  static String normalize(String text) {
    if (text.isEmpty) return '';

    String cleaned = text;
    for (final p in _punctuations) {
      cleaned = cleaned.replaceAll(p, ' ');
    }

    return cleaned
        // ሀ series homophones: ሐ, ኀ -> ሀ
        .replaceAll(RegExp(r'[ሐኀ]'), 'ሀ')
        .replaceAll(RegExp(r'[ሑኁ]'), 'ሁ')
        .replaceAll(RegExp(r'[ሒኂ]'), 'ሂ')
        .replaceAll(RegExp(r'[ሓኃ]'), 'ሃ')
        .replaceAll(RegExp(r'[ሔኄ]'), 'ሄ')
        .replaceAll(RegExp(r'[ሕኅ]'), 'ህ')
        .replaceAll(RegExp(r'[ሖኆ]'), 'ሆ')
        // ሠ series homophones: ሠ -> ሰ
        .replaceAll('ሠ', 'ሰ')
        .replaceAll('ሡ', 'ሱ')
        .replaceAll('ሢ', 'ሲ')
        .replaceAll('ሣ', 'ሳ')
        .replaceAll('ሤ', 'ሴ')
        .replaceAll('ሥ', 'ስ')
        .replaceAll('ሦ', 'ሶ')
        // ዐ series homophones: ዐ -> አ
        .replaceAll('ዐ', 'አ')
        .replaceAll('ዑ', 'ኡ')
        .replaceAll('ዒ', 'ኢ')
        .replaceAll('ዓ', 'ኣ')
        .replaceAll('ዔ', 'ኤ')
        .replaceAll('ዕ', 'እ')
        .replaceAll('ዖ', 'ኦ')
        // ፀ series homophones: ፀ -> ጸ
        .replaceAll('ፀ', 'ጸ')
        .replaceAll('ፁ', 'ጹ')
        .replaceAll('ፂ', 'ጺ')
        .replaceAll('ፃ', 'ጻ')
        .replaceAll('ፄ', 'ጼ')
        .replaceAll('ፅ', 'ጽ')
        .replaceAll('ፆ', 'ጾ')
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
