/// Canonical Bible Book Identifiers & Cross-Translation Mapping
/// Maps between Ethiopian Orthodox 81 Canon, Traditional 1954 (66), and KJV (66).
class CanonicalBookMap {
  /// Standard 3-letter canonical codes for the 81 Books of the Ethiopian Orthodox Canon.
  /// (54 Old Testament books + 27 New Testament books)
  static const Map<int, String> eotc81ToCanonical = {
    // Old Testament (1-54)
    1: 'GEN',  // ኦሪት ዘፍጥረት (Genesis)
    2: 'EXO',  // ኦሪት ዘጸአት (Exodus)
    3: 'LEV',  // ኦሪት ዘሌዋውያን (Leviticus)
    4: 'NUM',  // ኦሪት ዘኍልቍ (Numbers)
    5: 'DEU',  // ኦሪት ዘዳግም (Deuteronomy)
    6: 'JOS',  // መጽሐፈ ኢያሱ (Joshua)
    7: 'JDG',  // መጽሐፈ መሳፍንት (Judges)
    8: 'RUT',  // መጽሐፈ ሩት (Ruth)
    9: '1SA',  // መጽሐፈ ሳሙኤል ቀዳማዊ (1 Samuel)
    10: '2SA', // መጽሐፈ ሳሙኤል ካልዕ (2 Samuel)
    11: '1KI', // መጽሐፈ ነገሥት ቀዳማዊ (1 Kings)
    12: '2KI', // መጽሐፈ ነገሥት ካልዕ (2 Kings)
    13: '1CH', // መጽሐፈ ዜና መዋዕል ቀዳማዊ (1 Chronicles)
    14: '2CH', // መጽሐፈ ዜና መዋዕል ካልዕ (2 Chronicles)
    15: 'JUB', // መጽሐፈ ኩፋሌ (Jubilees - 81 Only)
    16: 'ENO', // መጽሐፈ ሄኖክ (Enoch - 81 Only)
    17: 'EZR', // መጽሐፈ ዕዝራ (Ezra)
    18: 'NEH', // መጽሐፈ ነሐምያ (Nehemiah)
    19: 'EZ3', // መጽሐፈ ዕዝራ ሱቱኤል (3 Ezra - 81 Only)
    20: 'EZ4', // መጽሐፈ ዕዝራ ካልእ (4 Ezra - 81 Only)
    21: 'TOB', // መጽሐፈ ጦቢት (Tobit - 81 Only)
    22: 'JDT', // መጽሐፈ ዮዲት (Judith - 81 Only)
    23: 'EST', // መጽሐፈ አስቴር (Esther)
    24: 'MQ1', // መጽሐፈ መቃብያን ቀዳማዊ (1 Meqabyan - 81 Only)
    25: 'MQ2', // መጽሐፈ መቃብያን ካልእ (2 Meqabyan - 81 Only)
    26: 'MQ3', // መጽሐፈ መቃብያን ሳልስ (3 Meqabyan - 81 Only)
    27: 'JOB', // መጽሐፈ ኢዮብ (Job)
    28: 'PSA', // መዝሙረ ዳዊት (Psalms)
    29: 'PRO', // መጽሐፈ ምሳሌ (Proverbs)
    30: 'TEG', // መጽሐፈ ተግሣጽ (Book of Admonition - 81 Only)
    31: 'WIS', // መጽሐፈ ጥበብ (Wisdom of Solomon - 81 Only)
    32: 'ECC', // መጽሐፈ መክብብ (Ecclesiastes)
    33: 'SNG', // ማሕልየ መሓልይ ዘሰሎሞን (Song of Solomon)
    34: 'SIR', // መጽሐፈ ሲራክ (Sirach - 81 Only)
    35: 'ISA', // ትንቢተ ኢሳይያስ (Isaiah)
    36: 'JER', // ትንቢተ ኤርምያስ (Jeremiah)
    37: 'BAR', // መጽሐፈ ባሮክ (Baruch - 81 Only)
    38: 'LAM', // ሰቆቃወ ኤርምያስ (Lamentations)
    39: 'TER', // ተረፈ ኤርምያስ (Rest of Jeremiah - 81 Only)
    40: 'TBR', // ተረፈ ባሮክ (Rest of Baruch - 81 Only)
    41: 'EZK', // ትንቢተ ሕዝቅኤል (Ezekiel)
    42: 'DAN', // ትንቢተ ዳንኤል (Daniel)
    43: 'HOS', // ትንቢተ ሆሴዕ (Hosea)
    44: 'AMO', // ትንቢተ ዓሞጽ (Amos)
    45: 'MIC', // ትንቢተ ሚክያስ (Micah)
    46: 'JOL', // ትንቢተ ኢዮኤል (Joel)
    47: 'OBA', // ትንቢተ አብድዩ (Obadiah)
    48: 'JON', // ትንቢተ ዮናስ (Jonah)
    49: 'NAH', // ትንቢተ ናሆም (Nahum)
    50: 'HAB', // ትንቢተ ዕንባቆም (Habakkuk)
    51: 'ZEP', // ትንቢተ ሶፎንያስ (Zephaniah)
    52: 'HAG', // ትንቢተ ሐጌ (Haggai)
    53: 'ZEC', // ትንቢተ ዘካርያስ (Zechariah)
    54: 'MAL', // ትንቢተ ሚልክያስ (Malachi)

    // New Testament (55-81)
    55: 'MAT', // የማቴዎስ ወንጌል (Matthew)
    56: 'MRK', // የማርቆስ ወንጌል (Mark)
    57: 'LUK', // የሉቃስ ወንጌል (Luke)
    58: 'JHN', // የዮሐንስ ወንጌል (John)
    59: 'ACT', // የሐዋርያት ሥራ (Acts)
    60: 'ROM', // ወደ ሮሜ ሰዎች (Romans)
    61: '1CO', // 1ኛ ቆሮንቶስ (1 Corinthians)
    62: '2CO', // 2ኛ ቆሮንቶስ (2 Corinthians)
    63: 'GAL', // ወደ ገላትያ ሰዎች (Galatians)
    64: 'EPH', // ወደ ኤፌሶን ሰዎች (Ephesians)
    65: 'PHP', // ወደ ፊልጵስዩስ ሰዎች (Philippians)
    66: 'COL', // ወደ ቆላስይስ ሰዎች (Colossians)
    67: '1TH', // 1ኛ ወደ ተሰሎንቄ ሰዎች (1 Thessalonians)
    68: '2TH', // 2ኛ ወደ ተሰሎንቄ ሰዎች (2 Thessalonians)
    69: '1TI', // 1ኛ ወደ ጢሞቴዎስ (1 Timothy)
    70: '2TI', // 2ኛ ወደ ጢሞቴዎስ (2 Timothy)
    71: 'TIT', // ወደ ቲቶ (Titus)
    72: 'PHM', // ወደ ፊልሞና (Philemon)
    73: 'HEB', // ወደ ዕብራውያን (Hebrews)
    74: '1PE', // 1ኛ ጴጥሮስ (1 Peter)
    75: '2PE', // 2ኛ ጴጥሮስ (2 Peter)
    76: '1JN', // 1ኛ የዮሃንስ መልእክት (1 John)
    77: '2JN', // የዮሐንስ መልእክት 2 (2 John)
    78: '3JN', // 3ኛ የዮሐንስ መልእክት (3 John)
    79: 'JAS', // የያዕቆን መልእክት (James)
    80: 'JUD', // የይሁዳ መልእክት (Jude)
    81: 'REV', // የዮሐንስ ራዕይ (Revelation)
  };

  /// Standard 3-letter canonical codes for the 66 Books of the 1954 Emperor Haile Selassie and KJV editions.
  static const Map<int, String> bible66ToCanonical = {
    // Old Testament (1-39)
    1: 'GEN', 2: 'EXO', 3: 'LEV', 4: 'NUM', 5: 'DEU',
    6: 'JOS', 7: 'JDG', 8: 'RUT', 9: '1SA', 10: '2SA',
    11: '1KI', 12: '2KI', 13: '1CH', 14: '2CH', 15: 'EZR',
    16: 'NEH', 17: 'EST', 18: 'JOB', 19: 'PSA', 20: 'PRO',
    21: 'ECC', 22: 'SNG', 23: 'ISA', 24: 'JER', 25: 'LAM',
    26: 'EZK', 27: 'DAN', 28: 'HOS', 29: 'JOL', 30: 'AMO',
    31: 'OBA', 32: 'JON', 33: 'MIC', 34: 'NAH', 35: 'HAB',
    36: 'ZEP', 37: 'HAG', 38: 'ZEC', 39: 'MAL',

    // New Testament (40-66)
    40: 'MAT', 41: 'MRK', 42: 'LUK', 43: 'JHN', 44: 'ACT',
    45: 'ROM', 46: '1CO', 47: '2CO', 48: 'GAL', 49: 'EPH',
    50: 'PHP', 51: 'COL', 52: '1TH', 53: '2TH', 54: '1TI',
    55: '2TI', 56: 'TIT', 57: 'PHM', 58: 'HEB', 59: 'JAS',
    60: '1PE', 61: '2PE', 62: '1JN', 63: '2JN', 64: '3JN',
    65: 'JUD', 66: 'REV',
  };

  /// Resolves the canonical code for a given book number in a translation.
  static String getCanonicalId(int translationId, int bookNumber) {
    if (translationId == 2) {
      return eotc81ToCanonical[bookNumber] ?? '';
    } else {
      return bible66ToCanonical[bookNumber] ?? '';
    }
  }

  /// Finds the corresponding book number in the target translation.
  /// Returns `null` if the book only exists in the Orthodox 81 Canon (e.g. Enoch, Jubilees, Meqabyan).
  static int? getBookNumber(int translationId, String canonicalId) {
    if (canonicalId.isEmpty) return null;
    if (translationId == 2) {
      for (final entry in eotc81ToCanonical.entries) {
        if (entry.value == canonicalId) return entry.key;
      }
    } else {
      for (final entry in bible66ToCanonical.entries) {
        if (entry.value == canonicalId) return entry.key;
      }
    }
    return null;
  }

  /// Whether a book is exclusive to the Ethiopian Orthodox 81 Canon.
  static bool is81Exclusive(int bookNumber) {
    final canon = eotc81ToCanonical[bookNumber];
    if (canon == null) return false;
    return getBookNumber(1, canon) == null;
  }

  /// Standard English book names for KJV.
  static const Map<int, String> kjvEnglishNames = {
    1: 'Genesis', 2: 'Exodus', 3: 'Leviticus', 4: 'Numbers', 5: 'Deuteronomy',
    6: 'Joshua', 7: 'Judges', 8: 'Ruth', 9: '1 Samuel', 10: '2 Samuel',
    11: '1 Kings', 12: '2 Kings', 13: '1 Chronicles', 14: '2 Chronicles',
    15: 'Ezra', 16: 'Nehemiah', 17: 'Esther', 18: 'Job', 19: 'Psalms',
    20: 'Proverbs', 21: 'Ecclesiastes', 22: 'Song of Solomon', 23: 'Isaiah',
    24: 'Jeremiah', 25: 'Lamentations', 26: 'Ezekiel', 27: 'Daniel',
    28: 'Hosea', 29: 'Joel', 30: 'Amos', 31: 'Obadiah', 32: 'Jonah',
    33: 'Micah', 34: 'Nahum', 35: 'Habakkuk', 36: 'Zephaniah', 37: 'Haggai',
    38: 'Zechariah', 39: 'Malachi',
    40: 'Matthew', 41: 'Mark', 42: 'Luke', 43: 'John', 44: 'Acts',
    45: 'Romans', 46: '1 Corinthians', 47: '2 Corinthians', 48: 'Galatians',
    49: 'Ephesians', 50: 'Philippians', 51: 'Colossians', 52: '1 Thessalonians',
    53: '2 Thessalonians', 54: '1 Timothy', 55: '2 Timothy', 56: 'Titus',
    57: 'Philemon', 58: 'Hebrews', 59: 'James', 60: '1 Peter', 61: '2 Peter',
    62: '1 John', 63: '2 John', 64: '3 John', 65: 'Jude', 66: 'Revelation',
  };
}
