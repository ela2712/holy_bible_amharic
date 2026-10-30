import '../models/reading_plan.dart';

class _BookDef {
  final int num;
  final String canonicalId;
  final String name;
  final String nameEn;
  final int chapters;
  const _BookDef(this.num, this.name, this.chapters, {this.canonicalId = '', this.nameEn = ''});
}

class ReadingPlansData {
  ReadingPlansData._();

  static const List<_BookDef> _otBooks = [
    _BookDef(1, 'ኦሪት ዘፍጥረት', 50, canonicalId: 'GEN', nameEn: 'Genesis'),
    _BookDef(2, 'ኦሪት ዘጸአት', 40, canonicalId: 'EXO', nameEn: 'Exodus'),
    _BookDef(3, 'ኦሪት ዘሌዋውያን', 27, canonicalId: 'LEV', nameEn: 'Leviticus'),
    _BookDef(4, 'ኦሪት ዘኍልቍ', 36, canonicalId: 'NUM', nameEn: 'Numbers'),
    _BookDef(5, 'ኦሪት ዘዳግም', 34, canonicalId: 'DEU', nameEn: 'Deuteronomy'),
    _BookDef(6, 'መጽሐፈ ኢያሱ ወልደ ነዌ', 24, canonicalId: 'JOS', nameEn: 'Joshua'),
    _BookDef(7, 'መጽሐፈ መሳፍንት', 21, canonicalId: 'JDG', nameEn: 'Judges'),
    _BookDef(8, 'መጽሐፈ ሩት', 4, canonicalId: 'RUT', nameEn: 'Ruth'),
    _BookDef(9, 'መጽሐፈ ሳሙኤል ቀዳማዊ', 31, canonicalId: '1SA', nameEn: '1 Samuel'),
    _BookDef(10, 'መጽሐፈ ሳሙኤል ካልዕ', 24, canonicalId: '2SA', nameEn: '2 Samuel'),
    _BookDef(11, 'መጽሐፈ ነገሥት ቀዳማዊ', 22, canonicalId: '1KI', nameEn: '1 Kings'),
    _BookDef(12, 'መጽሐፈ ነገሥት ካልዕ', 25, canonicalId: '2KI', nameEn: '2 Kings'),
    _BookDef(13, 'መጽሐፈ ዜና መዋዕል ቀዳማዊ', 29, canonicalId: '1CH', nameEn: '1 Chronicles'),
    _BookDef(14, 'መጽሐፈ ዜና መዋዕል ካልዕ', 36, canonicalId: '2CH', nameEn: '2 Chronicles'),
    _BookDef(15, 'መጽሐፈ ዕዝራ', 10, canonicalId: 'EZR', nameEn: 'Ezra'),
    _BookDef(16, 'መጽሐፈ ነህምያ', 13, canonicalId: 'NEH', nameEn: 'Nehemiah'),
    _BookDef(17, 'መጽሐፈ አስቴር', 10, canonicalId: 'EST', nameEn: 'Esther'),
    _BookDef(18, 'መጽሐፈ ኢዮብ', 42, canonicalId: 'JOB', nameEn: 'Job'),
    _BookDef(19, 'መዝሙረ ዳዊት', 150, canonicalId: 'PSA', nameEn: 'Psalms'),
    _BookDef(20, 'መጽሐፈ ምሳሌ', 31, canonicalId: 'PRO', nameEn: 'Proverbs'),
    _BookDef(21, 'መጽሐፈ መክብብ', 12, canonicalId: 'ECC', nameEn: 'Ecclesiastes'),
    _BookDef(22, 'መኃልየ መኃልይ ዘሰሎሞን', 8, canonicalId: 'SNG', nameEn: 'Song of Solomon'),
    _BookDef(23, 'ትንቢተ ኢሳይያስ', 66, canonicalId: 'ISA', nameEn: 'Isaiah'),
    _BookDef(24, 'ትንቢተ ኤርምያስ', 52, canonicalId: 'JER', nameEn: 'Jeremiah'),
    _BookDef(25, 'ሰቆቃወ ኤርምያስ', 5, canonicalId: 'LAM', nameEn: 'Lamentations'),
    _BookDef(26, 'ትንቢተ ሕዝቅኤል', 48, canonicalId: 'EZK', nameEn: 'Ezekiel'),
    _BookDef(27, 'ትንቢተ ዳንኤል', 12, canonicalId: 'DAN', nameEn: 'Daniel'),
    _BookDef(28, 'ትንቢተ ሆሴዕ', 14, canonicalId: 'HOS', nameEn: 'Hosea'),
    _BookDef(29, 'ትንቢተ ዮኤል', 3, canonicalId: 'JOL', nameEn: 'Joel'),
    _BookDef(30, 'ትንቢተ አሞጽ', 9, canonicalId: 'AMO', nameEn: 'Amos'),
    _BookDef(31, 'ትንቢተ አብድዩ', 1, canonicalId: 'OBA', nameEn: 'Obadiah'),
    _BookDef(32, 'ትንቢተ ዮናስ', 4, canonicalId: 'JON', nameEn: 'Jonah'),
    _BookDef(33, 'ትንቢተ ሚክያስ', 7, canonicalId: 'MIC', nameEn: 'Micah'),
    _BookDef(34, 'ትንቢተ ናሆም', 3, canonicalId: 'NAH', nameEn: 'Nahum'),
    _BookDef(35, 'ትንቢተ ዕንባቆም', 3, canonicalId: 'HAB', nameEn: 'Habakkuk'),
    _BookDef(36, 'ትንቢተ ሶፎንያስ', 3, canonicalId: 'ZEP', nameEn: 'Zephaniah'),
    _BookDef(37, 'ትንቢተ ሐጌ', 2, canonicalId: 'HAG', nameEn: 'Haggai'),
    _BookDef(38, 'ትንቢተ ዘካርያስ', 14, canonicalId: 'ZEC', nameEn: 'Zechariah'),
    _BookDef(39, 'ትንቢተ ሚልክያስ', 4, canonicalId: 'MAL', nameEn: 'Malachi'),
  ];

  static const List<_BookDef> _ntBooks = [
    _BookDef(40, 'የማቴዎስ ወንጌል', 28, canonicalId: 'MAT', nameEn: 'Matthew'),
    _BookDef(41, 'የማርቆስ ወንጌል', 16, canonicalId: 'MRK', nameEn: 'Mark'),
    _BookDef(42, 'የሉቃስ ወንጌል', 24, canonicalId: 'LUK', nameEn: 'Luke'),
    _BookDef(43, 'የዮሐንስ ወንጌል', 21, canonicalId: 'JHN', nameEn: 'John'),
    _BookDef(44, 'የሐዋርያት ሥራ', 28, canonicalId: 'ACT', nameEn: 'Acts'),
    _BookDef(45, 'ወደ ሮሜ ሰዎች', 16, canonicalId: 'ROM', nameEn: 'Romans'),
    _BookDef(46, 'ወደ ቆሮንቶስ ሰዎች 1ኛ', 16, canonicalId: '1CO', nameEn: '1 Corinthians'),
    _BookDef(47, 'ወደ ቆሮንቶስ ሰዎች 2ኛ', 13, canonicalId: '2CO', nameEn: '2 Corinthians'),
    _BookDef(48, 'ወደ ገላትያ ሰዎች', 6, canonicalId: 'GAL', nameEn: 'Galatians'),
    _BookDef(49, 'ወደ ኤፌሶን ሰዎች', 6, canonicalId: 'EPH', nameEn: 'Ephesians'),
    _BookDef(50, 'ወደ ፊልጵስዩስ ሰዎች', 4, canonicalId: 'PHP', nameEn: 'Philippians'),
    _BookDef(51, 'ወደ ቆላስይስ ሰዎች', 4, canonicalId: 'COL', nameEn: 'Colossians'),
    _BookDef(52, 'ወደ ተሰሎንቄ ሰዎች 1ኛ', 5, canonicalId: '1TH', nameEn: '1 Thessalonians'),
    _BookDef(53, 'ወደ ተሰሎንቄ ሰዎች 2ኛ', 3, canonicalId: '2TH', nameEn: '2 Thessalonians'),
    _BookDef(54, 'ወደ ጢሞቴዎስ 1ኛ', 6, canonicalId: '1TI', nameEn: '1 Timothy'),
    _BookDef(55, 'ወደ ጢሞቴዎስ 2ኛ', 4, canonicalId: '2TI', nameEn: '2 Timothy'),
    _BookDef(56, 'ወደ ቲቶ', 3, canonicalId: 'TIT', nameEn: 'Titus'),
    _BookDef(57, 'ወደ ፊልሞና', 1, canonicalId: 'PHM', nameEn: 'Philemon'),
    _BookDef(58, 'ወደ ዕብራውያን', 13, canonicalId: 'HEB', nameEn: 'Hebrews'),
    _BookDef(59, 'የያዕቆብ መልእክት', 5, canonicalId: 'JAS', nameEn: 'James'),
    _BookDef(60, 'የጴጥሮስ መልእክት 1ኛ', 5, canonicalId: '1PE', nameEn: '1 Peter'),
    _BookDef(61, 'የጴጥሮስ መልእክት 2ኛ', 3, canonicalId: '2PE', nameEn: '2 Peter'),
    _BookDef(62, 'የዮሐንስ መልእክት 1ኛ', 5, canonicalId: '1JN', nameEn: '1 John'),
    _BookDef(63, 'የዮሐንስ መልእክት 2ኛ', 1, canonicalId: '2JN', nameEn: '2 John'),
    _BookDef(64, 'የዮሐንስ መልእክት 3ኛ', 1, canonicalId: '3JN', nameEn: '3 John'),
    _BookDef(65, 'የይሁዳ መልእክት', 1, canonicalId: 'JUD', nameEn: 'Jude'),
    _BookDef(66, 'የዮሐንስ ራእይ', 22, canonicalId: 'REV', nameEn: 'Revelation'),
  ];

  static const List<_BookDef> _eotc81Books = [
    _BookDef(1, 'ኦሪት ዘፍጥረት', 50, canonicalId: 'GEN', nameEn: 'Genesis'),
    _BookDef(2, 'ኦሪት ዘጸአት', 40, canonicalId: 'EXO', nameEn: 'Exodus'),
    _BookDef(3, 'ኦሪት ዘሌዋውያን', 27, canonicalId: 'LEV', nameEn: 'Leviticus'),
    _BookDef(4, 'ኦሪት ዘኍልቍ', 36, canonicalId: 'NUM', nameEn: 'Numbers'),
    _BookDef(5, 'ኦሪት ዘዳግም', 34, canonicalId: 'DEU', nameEn: 'Deuteronomy'),
    _BookDef(6, 'መጽሐፈ ኢያሱ', 24, canonicalId: 'JOS', nameEn: 'Joshua'),
    _BookDef(7, 'መጽሐፈ መሳፍንት', 21, canonicalId: 'JDG', nameEn: 'Judges'),
    _BookDef(8, 'መጽሐፈ ሩት', 4, canonicalId: 'RUT', nameEn: 'Ruth'),
    _BookDef(9, 'መጽሐፈ ሳሙኤል ቀዳማዊ', 31, canonicalId: '1SA', nameEn: '1 Samuel'),
    _BookDef(10, 'መጽሐፈ ሳሙኤል ካልዕ', 24, canonicalId: '2SA', nameEn: '2 Samuel'),
    _BookDef(11, 'መጽሐፈ ነገሥት ቀዳማዊ', 22, canonicalId: '1KI', nameEn: '1 Kings'),
    _BookDef(12, 'መጽሐፈ ነገሥት ካልዕ', 25, canonicalId: '2KI', nameEn: '2 Kings'),
    _BookDef(13, 'መጽሐፈ ዜና መዋዕል ቀዳማዊ', 29, canonicalId: '1CH', nameEn: '1 Chronicles'),
    _BookDef(14, 'መጽሐፈ ዜና መዋዕል ካልዕ', 36, canonicalId: '2CH', nameEn: '2 Chronicles'),
    _BookDef(15, 'መጽሐፈ ኩፋሌ', 34, canonicalId: 'JUB', nameEn: 'Jubilees'),
    _BookDef(16, 'መጽሐፈ ሄኖክ', 42, canonicalId: 'ENO', nameEn: 'Enoch'),
    _BookDef(17, 'መጽሐፈ ዕዝራ', 10, canonicalId: 'EZR', nameEn: 'Ezra'),
    _BookDef(18, 'መጽሐፈ ነሐምያ', 13, canonicalId: 'NEH', nameEn: 'Nehemiah'),
    _BookDef(19, 'መጽሐፈ ዕዝራ ሱቱኤል', 13, canonicalId: 'EZ3', nameEn: '3 Ezra (Sutuel)'),
    _BookDef(20, 'መጽሐፈ ዕዝራ ካልእ', 9, canonicalId: 'EZ4', nameEn: '4 Ezra'),
    _BookDef(21, 'መጽሐፈ ጦቢት', 14, canonicalId: 'TOB', nameEn: 'Tobit'),
    _BookDef(22, 'መጽሐፈ ዮዲት', 16, canonicalId: 'JDT', nameEn: 'Judith'),
    _BookDef(23, 'መጽሐፈ አስቴር', 11, canonicalId: 'EST', nameEn: 'Esther'),
    _BookDef(24, 'መጽሐፈ መቃብያን ቀዳማዊ', 36, canonicalId: 'MQ1', nameEn: '1 Meqabyan'),
    _BookDef(25, 'መጽሐፈ መቃብያን ካልእ', 21, canonicalId: 'MQ2', nameEn: '2 Meqabyan'),
    _BookDef(26, 'መጽሐፈ መቃብያን ሳልስ', 10, canonicalId: 'MQ3', nameEn: '3 Meqabyan'),
    _BookDef(27, 'መጽሐፈ ኢዮብ', 42, canonicalId: 'JOB', nameEn: 'Job'),
    _BookDef(28, 'መዝሙረ ዳዊት', 151, canonicalId: 'PSA', nameEn: 'Psalms'),
    _BookDef(29, 'መጽሐፈ ምሳሌ', 24, canonicalId: 'PRO', nameEn: 'Proverbs'),
    _BookDef(30, 'መጽሐፈ ተግሣጽ', 6, canonicalId: 'TEG', nameEn: 'Book of Admonition'),
    _BookDef(31, 'መጽሐፈ ጥበብ', 19, canonicalId: 'WIS', nameEn: 'Wisdom of Solomon'),
    _BookDef(32, 'መጽሐፈ መክብብ', 12, canonicalId: 'ECC', nameEn: 'Ecclesiastes'),
    _BookDef(33, 'ማሕልየ መሓልይ ዘሰሎሞን', 8, canonicalId: 'SNG', nameEn: 'Song of Solomon'),
    _BookDef(34, 'መጽሐፈ ሲራክ', 51, canonicalId: 'SIR', nameEn: 'Sirach'),
    _BookDef(35, 'ትንቢተ ኢሳይያስ', 66, canonicalId: 'ISA', nameEn: 'Isaiah'),
    _BookDef(36, 'ትንቢተ ኤርምያስ', 52, canonicalId: 'JER', nameEn: 'Jeremiah'),
    _BookDef(37, 'መጽሐፈ ባሮክ', 5, canonicalId: 'BAR', nameEn: 'Baruch'),
    _BookDef(38, 'ሰቆቃወ ኤርምያስ', 5, canonicalId: 'LAM', nameEn: 'Lamentations'),
    _BookDef(39, 'ተረፈ ኤርምያስ', 1, canonicalId: 'TER', nameEn: 'Rest of Jeremiah'),
    _BookDef(40, 'ተረፈ ባሮክ', 5, canonicalId: 'TBR', nameEn: 'Rest of Baruch'),
    _BookDef(41, 'ትንቢተ ሕዝቅኤል', 48, canonicalId: 'EZK', nameEn: 'Ezekiel'),
    _BookDef(42, 'ትንቢተ ዳንኤል', 14, canonicalId: 'DAN', nameEn: 'Daniel'),
    _BookDef(43, 'ትንቢተ ሆሴዕ', 14, canonicalId: 'HOS', nameEn: 'Hosea'),
    _BookDef(44, 'ትንቢተ ዓሞጽ', 9, canonicalId: 'AMO', nameEn: 'Amos'),
    _BookDef(45, 'ትንቢተ ሚክያስ', 7, canonicalId: 'MIC', nameEn: 'Micah'),
    _BookDef(46, 'ትንቢተ ኢዮኤል', 3, canonicalId: 'JOL', nameEn: 'Joel'),
    _BookDef(47, 'ትንቢተ አብድዩ', 1, canonicalId: 'OBA', nameEn: 'Obadiah'),
    _BookDef(48, 'ትንቢተ ዮናስ', 4, canonicalId: 'JON', nameEn: 'Jonah'),
    _BookDef(49, 'ትንቢተ ናሆም', 3, canonicalId: 'NAH', nameEn: 'Nahum'),
    _BookDef(50, 'ትንቢተ ዕንባቆም', 3, canonicalId: 'HAB', nameEn: 'Habakkuk'),
    _BookDef(51, 'ትንቢተ ሶፎንያስ', 3, canonicalId: 'ZEP', nameEn: 'Zephaniah'),
    _BookDef(52, 'ትንቢተ ሐጌ', 2, canonicalId: 'HAG', nameEn: 'Haggai'),
    _BookDef(53, 'ትንቢተ ዘካርያስ', 14, canonicalId: 'ZEC', nameEn: 'Zechariah'),
    _BookDef(54, 'ትንቢተ ሚልክያስ', 4, canonicalId: 'MAL', nameEn: 'Malachi'),
    _BookDef(55, 'የማቴዎስ ወንጌል', 28, canonicalId: 'MAT', nameEn: 'Matthew'),
    _BookDef(56, 'የማርቆስ ወንጌል', 16, canonicalId: 'MRK', nameEn: 'Mark'),
    _BookDef(57, 'የሉቃስ ወንጌል', 24, canonicalId: 'LUK', nameEn: 'Luke'),
    _BookDef(58, 'የዮሐንስ ወንጌል', 21, canonicalId: 'JHN', nameEn: 'John'),
    _BookDef(59, 'የሐዋርያት ሥራ', 28, canonicalId: 'ACT', nameEn: 'Acts'),
    _BookDef(60, 'ወደ ሮሜ ሰዎች', 16, canonicalId: 'ROM', nameEn: 'Romans'),
    _BookDef(61, '1ኛ ቆሮንቶስ', 16, canonicalId: '1CO', nameEn: '1 Corinthians'),
    _BookDef(62, '2ኛ ቆሮንቶስ', 13, canonicalId: '2CO', nameEn: '2 Corinthians'),
    _BookDef(63, 'ወደ ገላትያ ሰዎች', 6, canonicalId: 'GAL', nameEn: 'Galatians'),
    _BookDef(64, 'ወደ ኤፌሶን ሰዎች', 6, canonicalId: 'EPH', nameEn: 'Ephesians'),
    _BookDef(65, 'ወደ ፊልጵስዩስ ሰዎች', 4, canonicalId: 'PHP', nameEn: 'Philippians'),
    _BookDef(66, 'ወደ ቆላስይስ ሰዎች', 4, canonicalId: 'COL', nameEn: 'Colossians'),
    _BookDef(67, '1ኛ ወደ ተሰሎንቄ ሰዎች', 5, canonicalId: '1TH', nameEn: '1 Thessalonians'),
    _BookDef(68, '2ኛ ወደ ተሰሎንቄ ሰዎች', 3, canonicalId: '2TH', nameEn: '2 Thessalonians'),
    _BookDef(69, '1ኛ ወደ ጢሞቴዎስ', 6, canonicalId: '1TI', nameEn: '1 Timothy'),
    _BookDef(70, '2ኛ ወደ ጢሞቴዎስ', 4, canonicalId: '2TI', nameEn: '2 Timothy'),
    _BookDef(71, 'ወደ ቲቶ', 3, canonicalId: 'TIT', nameEn: 'Titus'),
    _BookDef(72, 'ወደ ፊልሞና', 1, canonicalId: 'PHM', nameEn: 'Philemon'),
    _BookDef(73, 'ወደ ዕብራውያን', 13, canonicalId: 'HEB', nameEn: 'Hebrews'),
    _BookDef(74, '1ኛ ጴጥሮስ', 5, canonicalId: '1PE', nameEn: '1 Peter'),
    _BookDef(75, '2ኛ ጴጥሮስ', 3, canonicalId: '2PE', nameEn: '2 Peter'),
    _BookDef(76, '1ኛ የዮሃንስ መልእክት', 5, canonicalId: '1JN', nameEn: '1 John'),
    _BookDef(77, 'የዮሐንስ መልእክት 2', 1, canonicalId: '2JN', nameEn: '2 John'),
    _BookDef(78, '3ኛ የዮሐንስ መልእክት', 1, canonicalId: '3JN', nameEn: '3 John'),
    _BookDef(79, 'የያዕቆን መልእክት', 5, canonicalId: 'JAS', nameEn: 'James'),
    _BookDef(80, 'የይሁዳ መልእክት', 1, canonicalId: 'JUD', nameEn: 'Jude'),
    _BookDef(81, 'የዮሐንስ ራዕይ', 22, canonicalId: 'REV', nameEn: 'Revelation'),
  ];

  static final List<_BookDef> _eotcDeuterocanonicalBooks = _eotc81Books.where((b) => [
    15, 16, 19, 20, 21, 22, 24, 25, 26, 30, 31, 34, 37, 39, 40
  ].contains(b.num)).toList();

  static const List<_BookDef> _chronologicalOrder = [
    _BookDef(1, 'ኦሪት ዘፍጥረት', 50, canonicalId: 'GEN', nameEn: 'Genesis'),
    _BookDef(18, 'መጽሐፈ ኢዮብ', 42, canonicalId: 'JOB', nameEn: 'Job'),
    _BookDef(2, 'ኦሪት ዘጸአት', 40, canonicalId: 'EXO', nameEn: 'Exodus'),
    _BookDef(3, 'ኦሪት ዘሌዋውያን', 27, canonicalId: 'LEV', nameEn: 'Leviticus'),
    _BookDef(4, 'ኦሪት ዘኍልቍ', 36, canonicalId: 'NUM', nameEn: 'Numbers'),
    _BookDef(5, 'ኦሪት ዘዳግም', 34, canonicalId: 'DEU', nameEn: 'Deuteronomy'),
    _BookDef(6, 'መጽሐፈ ኢያሱ ወልደ ነዌ', 24, canonicalId: 'JOS', nameEn: 'Joshua'),
    _BookDef(7, 'መጽሐፈ መሳፍንት', 21, canonicalId: 'JDG', nameEn: 'Judges'),
    _BookDef(8, 'መጽሐፈ ሩት', 4, canonicalId: 'RUT', nameEn: 'Ruth'),
    _BookDef(9, 'መጽሐፈ ሳሙኤል ቀዳማዊ', 31, canonicalId: '1SA', nameEn: '1 Samuel'),
    _BookDef(10, 'መጽሐፈ ሳሙኤል ካልዕ', 24, canonicalId: '2SA', nameEn: '2 Samuel'),
    _BookDef(19, 'መዝሙረ ዳዊት', 150, canonicalId: 'PSA', nameEn: 'Psalms'),
    _BookDef(11, 'መጽሐፈ ነገሥት ቀዳማዊ', 22, canonicalId: '1KI', nameEn: '1 Kings'),
    _BookDef(20, 'መጽሐፈ ምሳሌ', 31, canonicalId: 'PRO', nameEn: 'Proverbs'),
    _BookDef(21, 'መጽሐፈ መክብብ', 12, canonicalId: 'ECC', nameEn: 'Ecclesiastes'),
    _BookDef(22, 'መኃልየ መኃልይ ዘሰሎሞን', 8, canonicalId: 'SNG', nameEn: 'Song of Solomon'),
    _BookDef(12, 'መጽሐፈ ነገሥት ካልዕ', 25, canonicalId: '2KI', nameEn: '2 Kings'),
    _BookDef(23, 'ትንቢተ ኢሳይያስ', 66, canonicalId: 'ISA', nameEn: 'Isaiah'),
    _BookDef(24, 'ትንቢተ ኤርምያስ', 52, canonicalId: 'JER', nameEn: 'Jeremiah'),
    _BookDef(26, 'ትንቢተ ሕዝቅኤል', 48, canonicalId: 'EZK', nameEn: 'Ezekiel'),
    _BookDef(27, 'ትንቢተ ዳንኤል', 12, canonicalId: 'DAN', nameEn: 'Daniel'),
    _BookDef(15, 'መጽሐፈ ዕዝራ', 10, canonicalId: 'EZR', nameEn: 'Ezra'),
    _BookDef(16, 'መጽሐፈ ነህምያ', 13, canonicalId: 'NEH', nameEn: 'Nehemiah'),
    _BookDef(17, 'መጽሐፈ አስቴር', 10, canonicalId: 'EST', nameEn: 'Esther'),
    _BookDef(41, 'የማርቆስ ወንጌል', 16, canonicalId: 'MRK', nameEn: 'Mark'),
    _BookDef(40, 'የማቴዎስ ወንጌል', 28, canonicalId: 'MAT', nameEn: 'Matthew'),
    _BookDef(42, 'የሉቃስ ወንጌል', 24, canonicalId: 'LUK', nameEn: 'Luke'),
    _BookDef(43, 'የዮሐንስ ወንጌል', 21, canonicalId: 'JHN', nameEn: 'John'),
    _BookDef(44, 'የሐዋርያት ሥራ', 28, canonicalId: 'ACT', nameEn: 'Acts'),
    _BookDef(45, 'ወደ ሮሜ ሰዎች', 16, canonicalId: 'ROM', nameEn: 'Romans'),
    _BookDef(46, 'ወደ ቆሮንቶስ ሰዎች 1ኛ', 16, canonicalId: '1CO', nameEn: '1 Corinthians'),
    _BookDef(58, 'ወደ ዕብራውያን', 13, canonicalId: 'HEB', nameEn: 'Hebrews'),
    _BookDef(66, 'የዮሐንስ ራእይ', 22, canonicalId: 'REV', nameEn: 'Revelation'),
  ];

  static List<DailyReadingPassage> _distributeBooksAcrossDays({
    required List<_BookDef> books,
    required int totalDays,
    required String titlePrefix,
    String titlePrefixEn = '',
    required String descPrefix,
    String descPrefixEn = '',
  }) {
    final flatChapters = <Map<String, dynamic>>[];
    for (final b in books) {
      for (int ch = 1; ch <= b.chapters; ch++) {
        flatChapters.add({
          'bookNum': b.num,
          'canonicalId': b.canonicalId,
          'bookName': b.name,
          'bookNameEn': b.nameEn,
          'chapter': ch,
        });
      }
    }

    if (flatChapters.isEmpty) return [];

    final passages = <DailyReadingPassage>[];
    final totalCh = flatChapters.length;

    for (int i = 0; i < totalDays; i++) {
      final day = i + 1;
      final startIdx = ((i * totalCh) ~/ totalDays).clamp(0, totalCh - 1);
      final endIdx = ((((i + 1) * totalCh) ~/ totalDays) - 1).clamp(startIdx, totalCh - 1);

      final first = flatChapters[startIdx];
      final bookNum = first['bookNum'] as int;
      final canonicalId = (first['canonicalId'] as String?) ?? '';
      final bookName = first['bookName'] as String;
      final bookNameEn = (first['bookNameEn'] as String?) ?? '';
      final startCh = first['chapter'] as int;

      int endCh = startCh;
      for (int k = startIdx; k <= endIdx; k++) {
        if (flatChapters[k]['bookNum'] == bookNum) {
          endCh = flatChapters[k]['chapter'] as int;
        }
      }

      final descAm = startCh == endCh
          ? '$descPrefix • $bookName ምዕራፍ $startCh'
          : '$descPrefix • $bookName ምዕራፍ $startCh እስከ $endCh';

      final descEn = descPrefixEn.isNotEmpty
          ? (startCh == endCh
              ? '$descPrefixEn • $bookNameEn Chapter $startCh'
              : '$descPrefixEn • $bookNameEn Chapters $startCh–$endCh')
          : '';

      passages.add(
        DailyReadingPassage(
          day: day,
          title: '$titlePrefix — ቀን $day',
          titleEn: titlePrefixEn.isNotEmpty ? '$titlePrefixEn — Day $day' : '',
          bookNumber: bookNum,
          canonicalId: canonicalId,
          bookName: bookName,
          bookNameEn: bookNameEn,
          startChapter: startCh,
          endChapter: endCh,
          description: descAm,
          descriptionEn: descEn,
        ),
      );
    }
    return passages;
  }

  /// Dynamically builds a custom reading plan for user-selected scope & duration
  static ReadingPlan buildCustomPlan({
    required String id,
    required String title,
    String? titleEn,
    required String scopeKey, // 'GOSPELS', 'NT', 'PSALMS_WISDOM', 'PENTATEUCH', 'OT', 'FULL'
    required int totalDays,
  }) {
    List<_BookDef> selectedBooks;
    String category;
    String categoryEn;
    String subtitle;
    String subtitleEn;

    switch (scopeKey) {
      case 'GOSPELS':
        selectedBooks = _ntBooks.sublist(0, 4);
        category = 'ሐዲስ ኪዳን';
        categoryEn = 'New Testament';
        subtitle = 'የአራቱ ወንጌላት የግል የንባብ ዕቅድ ($totalDays ቀናት)';
        subtitleEn = 'Personal reading plan for the Four Gospels ($totalDays days)';
        break;
      case 'NT':
        selectedBooks = _ntBooks;
        category = 'ሐዲስ ኪዳን';
        categoryEn = 'New Testament';
        subtitle = 'መላው ሐዲስ ኪዳን በ$totalDays ቀናት';
        subtitleEn = 'The entire New Testament in $totalDays days';
        break;
      case 'PSALMS_WISDOM':
        selectedBooks = _otBooks.where((b) => b.num >= 18 && b.num <= 22).toList();
        category = 'ጥበብና መዝሙር';
        categoryEn = 'Wisdom & Psalms';
        subtitle = 'መዝሙረ ዳዊትና የጥበብ መጻሕፍት በ$totalDays ቀናት';
        subtitleEn = 'Psalms of David and Wisdom literature in $totalDays days';
        break;
      case 'PENTATEUCH':
        selectedBooks = _otBooks.sublist(0, 5);
        category = 'ዓመታዊ';
        categoryEn = 'Annual';
        subtitle = 'አምስቱ የሙሴ የኦሪት መጻሕፍት በ$totalDays ቀናት';
        subtitleEn = 'The Five Books of Moses (Torah) in $totalDays days';
        break;
      case 'OT':
        selectedBooks = _otBooks;
        category = 'ዓመታዊ';
        categoryEn = 'Annual';
        subtitle = 'የብሉይ ኪዳን መጻሕፍት በ$totalDays ቀናት';
        subtitleEn = 'Old Testament books in $totalDays days';
        break;
      case 'FULL':
      default:
        selectedBooks = [..._otBooks, ..._ntBooks];
        category = 'ዓመታዊ';
        categoryEn = 'Annual';
        subtitle = 'ሙሉ መጽሐፍ ቅዱስ በ$totalDays ቀናት የግል ዕቅድ';
        subtitleEn = 'Full Bible custom reading plan in $totalDays days';
        break;
    }

    return ReadingPlan(
      id: id,
      title: title,
      titleEn: titleEn ?? title,
      subtitle: subtitle,
      subtitleEn: subtitleEn,
      category: category,
      categoryEn: categoryEn,
      totalDays: totalDays,
      coverIcon: 'auto_stories',
      badgeText: '$totalDays ቀናት • የግል ዕቅድ',
      badgeTextEn: '$totalDays Days • Custom Plan',
      passages: _distributeBooksAcrossDays(
        books: selectedBooks,
        totalDays: totalDays,
        titlePrefix: title,
        titlePrefixEn: titleEn ?? title,
        descPrefix: 'የግል ንባብ ዕቅድ',
        descPrefixEn: 'Custom Reading Plan',
      ),
    );
  }

  static final List<ReadingPlan> allPlans = [
    // 1. የ81 መጻሕፍት ዓመታዊ ንባብ (Orthodox 81 Canon 1-Year)
    ReadingPlan(
      id: 'canonical_365',
      title: 'የ81 መጻሕፍት ዓመታዊ ንባብ',
      titleEn: 'Complete 81 Books Orthodox Canon in 365 Days',
      subtitle: 'ከኦሪት ዘፍጥረት እስከ የዮሐንስ ራዕይ 81ዱንም የቀኖና መጻሕፍት በዓመት ይጨርሱ',
      subtitleEn: 'Read all 81 Books of the Ethiopian Orthodox Canon sequentially in one year',
      category: 'የኢ/ኦ/ተ/ቤ/ክ ቀኖና',
      categoryEn: 'EOTC Canon',
      totalDays: 365,
      coverIcon: 'auto_stories',
      badgeText: '365 ቀናት • 81 መጻሕፍት',
      badgeTextEn: '365 Days • 81 Books',
      passages: _distributeBooksAcrossDays(
        books: _eotc81Books,
        totalDays: 365,
        titlePrefix: 'የ81 መጻሕፍት ቀኖናዊ ንባብ',
        titlePrefixEn: '81 Books Canonical Reading',
        descPrefix: 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ መንፈሳዊ ጉዞ',
        descPrefixEn: 'EOTC Sacred Scripture Journey',
      ),
    ),

    // 2. የብሉያት ተጨማሪ መጻሕፍት (Deuterocanonical Books in 90 Days)
    ReadingPlan(
      id: 'deuterocanon_90',
      title: 'የብሉያት ተጨማሪ መጻሕፍት (አዋልድ)',
      titleEn: 'Deuterocanonical Books in 90 Days',
      subtitle: 'ኩፋሌ፣ ሄኖክ፣ መቃብያን፣ ዕዝራ፣ ሲራክ፣ ጥበብ፣ ጦቢትና ዮዲትን በ3 ወራት ያንብቡ',
      subtitleEn: 'Jubilees, Enoch, Meqabyan, Sirach, Wisdom, Tobit & Judith in 90 Days',
      category: 'የኢ/ኦ/ተ/ቤ/ክ ቀኖና',
      categoryEn: 'EOTC Canon',
      totalDays: 90,
      coverIcon: 'menu_book',
      badgeText: '90 ቀናት • 15ቱ መጻሕፍት',
      badgeTextEn: '90 Days • 15 Deuterocanonical',
      passages: _distributeBooksAcrossDays(
        books: _eotcDeuterocanonicalBooks,
        totalDays: 90,
        titlePrefix: 'የብሉያት ተጨማሪ መጻሕፍት',
        titlePrefixEn: 'Deuterocanonical Reading',
        descPrefix: 'የቀደሙት አባቶች ጥበብና ታሪክ',
        descPrefixEn: 'Wisdom & History of Ancient Fathers',
      ),
    ),

    // 2. የታሪክ ቅደም ተከተል ዕቅድ (Chronological Bible Plan - 365 Days)
    ReadingPlan(
      id: 'chronological_365',
      title: 'የታሪክ ቅደም ተከተል ዕቅድ',
      titleEn: 'Chronological Bible Plan',
      subtitle: 'መጽሐፍ ቅዱስን ታሪኮቹ በተፈጸሙበት የዘመን ቅደም ተከተል በዓመት ያንብቡ',
      subtitleEn: 'Read biblical history in the chronological order events occurred',
      category: 'ዓመታዊ',
      categoryEn: 'Annual',
      totalDays: 365,
      coverIcon: 'visibility',
      badgeText: '365 ቀናት • ታሪካዊ ቅደም ተከተል',
      badgeTextEn: '365 Days • Chronological',
      passages: _distributeBooksAcrossDays(
        books: _chronologicalOrder,
        totalDays: 365,
        titlePrefix: 'የታሪክ ቅደም ተከተል',
        titlePrefixEn: 'Chronological Reading',
        descPrefix: 'በዘመን ቅደም ተከተል የተዘጋጀ ንባብ',
        descPrefixEn: 'Chronological Scripture Reading',
      ),
    ),

    // 3. የብሉይና ሐዲስ ኪዳን ጥምር ዕቅድ (M'Cheyne Combined Plan)
    ReadingPlan(
      id: 'mcheyne_180',
      title: 'የብሉይና ሐዲስ ኪዳን ጥምር ዕቅድ',
      titleEn: 'OT & NT Combined Plan (M\'Cheyne)',
      subtitle: 'ከብሉይ ኪዳን፣ ከመዝሙራትና ከሐዲስ ኪዳን የተቀናጀ የጥናት ጉዞ',
      subtitleEn: 'Integrated daily readings from the Old Testament, Psalms, and New Testament',
      category: 'ዓመታዊ',
      categoryEn: 'Annual',
      totalDays: 180,
      coverIcon: 'auto_stories',
      badgeText: '180 ቀናት • ጥምር ጥናት',
      badgeTextEn: '180 Days • OT & NT Combined',
      passages: _distributeBooksAcrossDays(
        books: [..._ntBooks, ..._otBooks.sublist(0, 20)],
        totalDays: 180,
        titlePrefix: 'ጥምር መንፈሳዊ ንባብ',
        titlePrefixEn: 'Combined Spiritual Reading',
        descPrefix: 'የብሉይና ሐዲስ ኪዳን ስምምነት',
        descPrefixEn: 'Harmony of OT & NT',
      ),
    ),

    // 4. ሐዲስ ኪዳን በ90 ቀናት (New Testament in 90 Days)
    ReadingPlan(
      id: 'nt_90',
      title: 'ሐዲስ ኪዳን በ90 ቀናት',
      titleEn: 'New Testament in 90 Days',
      subtitle: '4ቱን ወንጌላት፣ የሐዋርያት ሥራ፣ መልእክታትና ራእይን በ3 ወራት ይጨርሱ',
      subtitleEn: 'Complete the 4 Gospels, Acts, Epistles, and Revelation in 3 months',
      category: 'ሐዲስ ኪዳን',
      categoryEn: 'New Testament',
      totalDays: 90,
      coverIcon: 'menu_book',
      badgeText: '90 ቀናት • 3 ምዕራፍ/ቀን',
      badgeTextEn: '90 Days • 3 ch/day',
      passages: _distributeBooksAcrossDays(
        books: _ntBooks,
        totalDays: 90,
        titlePrefix: 'የሐዲስ ኪዳን ጉዞ',
        titlePrefixEn: 'New Testament Journey',
        descPrefix: 'የወንጌልና የሐዋርያት ትምህርት',
        descPrefixEn: 'Teaching of Gospel & Apostles',
      ),
    ),

    // 5. አራቱ ወንጌላት በ30 ቀናት (The Four Gospels in 30 Days)
    ReadingPlan(
      id: 'gospels_30',
      title: 'አራቱ ወንጌላት በ30 ቀናት',
      titleEn: 'The Four Gospels in 30 Days',
      subtitle: 'የጌታችን የኢየሱስ ክርስቶስን ሕይወት፣ ትምህርት፣ መስቀልና ትንሣኤ በ1 ወር ያንብቡ',
      subtitleEn: 'Follow Christ\'s life, teachings, cross, and resurrection in one month',
      category: 'ሐዲስ ኪዳን',
      categoryEn: 'New Testament',
      totalDays: 30,
      coverIcon: 'menu_book',
      badgeText: '30 ቀናት • 4ቱ ወንጌላት',
      badgeTextEn: '30 Days • 4 Gospels',
      passages: _distributeBooksAcrossDays(
        books: _ntBooks.sublist(0, 4),
        totalDays: 30,
        titlePrefix: 'የወንጌል ብርሃን',
        titlePrefixEn: 'Light of the Gospel',
        descPrefix: 'የአራቱ ወንጌላት ንባብ',
        descPrefixEn: 'Four Gospels Reading',
      ),
    ),

    // 6. ሰሞነ ሕማማት (Holy Passion Week - 8 Days)
    ReadingPlan(
      id: 'passion_week',
      title: 'ሰሞነ ሕማማት',
      titleEn: 'Holy Passion Week',
      subtitle: 'ከሆሣዕና እስከ ትንሣኤ የክርስቶስን የመስቀል ጉዞና የግብረ ሕማማት ምንባባት ይከተሉ',
      subtitleEn: 'Follow Christ\'s journey from Hosanna to the Cross and glorious Resurrection',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: 8,
      coverIcon: 'church',
      badgeText: '8 ቀናት • ግብረ ሕማማት',
      badgeTextEn: '8 Days • Passion Week',
      passages: const [
        DailyReadingPassage(
          day: 1,
          title: 'ሆሣዕና — የክብር ግስጋሴ ወደ ኢየሩሳሌም',
          titleEn: 'Palm Sunday — Triumphal Entry into Jerusalem',
          bookNumber: 40,
          canonicalId: 'MAT',
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          startChapter: 21,
          endChapter: 21,
          description: 'ጌታችን በአህያ ውርንጭላ ላይ ተቀምጦ ወደ ኢየሩሳሌም በክብር መግባቱ።',
          descriptionEn: 'The Lord enters Jerusalem in glory on the colt of a donkey.',
        ),
        DailyReadingPassage(
          day: 2,
          title: 'ሰኞ — በለሲቱን መርገም እና ቤተ መቅደስን ማጽዳት',
          titleEn: 'Holy Monday — Fig Tree and Cleansing the Temple',
          bookNumber: 41,
          canonicalId: 'MRK',
          bookName: 'የማርቆስ ወንጌል',
          bookNameEn: 'Mark',
          startChapter: 11,
          endChapter: 11,
          description: 'ፍሬ የሌላትን በለስ ማድረቅና ቤተ መቅደስን ከነጋዴዎች ማጽዳት።',
          descriptionEn: 'Withering of the barren fig tree and cleansing of the temple.',
        ),
        DailyReadingPassage(
          day: 3,
          title: 'ማክሰኞ — የትምህርትና የጥያቄ ቀን (ደብረ ዘይት)',
          titleEn: 'Holy Tuesday — Teaching on the Mount of Olives',
          bookNumber: 40,
          canonicalId: 'MAT',
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          startChapter: 24,
          endChapter: 25,
          description: 'የዓለም ፍጻሜ ምልክቶችና የ10ሩ ቆነጃጅት ምሳሌ።',
          descriptionEn: 'Signs of the end times and parable of the ten virgins.',
        ),
        DailyReadingPassage(
          day: 4,
          title: 'ረቡዕ — የምክክርና የሽቶ ቀን',
          titleEn: 'Holy Wednesday — Anointing at Bethany & Betrayal',
          bookNumber: 40,
          canonicalId: 'MAT',
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          startChapter: 26,
          endChapter: 26,
          description: 'ማርያም የከበረ ሽቶ በጌታ ራስ ላይ ማፍሰሷና የአስቆሮቱ ይሁዳ ክህደት።',
          descriptionEn: 'Mary anoints Jesus with costly perfume; conspiracy to betray.',
        ),
        DailyReadingPassage(
          day: 5,
          title: 'ጸሎተ ሐሙስ — ሕጽበተ እግርና ምሥጢረ ቍርባን',
          titleEn: 'Maundy Thursday — Washing Feet & Mystical Supper',
          bookNumber: 43,
          canonicalId: 'JHN',
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          startChapter: 13,
          endChapter: 14,
          description: 'ጌታችን የደቀመዛሙርቱን እግር ማጠቡና ቅዱስ ሥጋውንና ደሙን መስጠቱ።',
          descriptionEn: 'Jesus washes disciples\' feet and institutes the Holy Eucharist.',
        ),
        DailyReadingPassage(
          day: 6,
          title: 'ስቅለተ ዓርብ — የድኅነት ቀን በመስቀል ላይ',
          titleEn: 'Good Friday — Salvation upon the Cross',
          bookNumber: 40,
          canonicalId: 'MAT',
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          startChapter: 27,
          endChapter: 27,
          description: 'ጌታችን መድኃኒታችን ኢየሱስ ክርስቶስ ስለ እኛ ኃጢአት በመስቀል ላይ መሞቱ።',
          descriptionEn: 'Our Lord Jesus Christ suffers and dies upon the cross for our sins.',
        ),
        DailyReadingPassage(
          day: 7,
          title: 'ቀዳም ስዑር — በመቃብር ያረፈበት ቀን',
          titleEn: 'Holy Saturday — Rest in the Tomb',
          bookNumber: 19,
          canonicalId: 'PSA',
          bookName: 'መዝሙረ ዳዊት',
          bookNameEn: 'Psalms',
          startChapter: 16,
          endChapter: 16,
          description: '«ነፍሴን በሲኦል አትተዋትምና፥ ቅዱስህንም መበስበስን ያይ ዘንድ አትተወውም።»',
          descriptionEn: '«For you will not leave my soul in Sheol, nor let your Holy One see decay.»',
        ),
        DailyReadingPassage(
          day: 8,
          title: 'ትንሣኤ — ሞትን ድል አድርጎ ተነሣ!',
          titleEn: 'Easter Sunday — Christ is Risen!',
          bookNumber: 43,
          canonicalId: 'JHN',
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          startChapter: 20,
          endChapter: 21,
          description: 'ክርስቶስ ተነሥቷል! በሞቱ ሞትን ሻረልን፤ ዘላለማዊ ሕይወትን ሰጠን።',
          descriptionEn: 'Christ is Risen! Trampling down death by death, bestowing eternal life.',
        ),
      ],
    ),

    // 7. የዐቢይ ጾም ጉዞ (Great Lent - 55 Days)
    ReadingPlan(
      id: 'great_lent_55',
      title: 'የዐቢይ ጾም ጉዞ',
      titleEn: 'Great Lent Journey (55 Days)',
      subtitle: 'ዘወረደ፣ ቅድስት፣ ምኩራብ፣ መጻጕዕ፣ ደብረ ዘይት፣ ገብር ኄር፣ ኒቆዲሞስና ሆሣዕና',
      subtitleEn: 'The 8 Sundays and weeks of Great Lent: Zewerede to Hosanna',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: 55,
      coverIcon: 'spa',
      badgeText: '55 ቀናት • ጾመ ሁዳዴ',
      badgeTextEn: '55 Days • Great Lent',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(40, 'የማቴዎስ ወንጌል', 28, canonicalId: 'MAT', nameEn: 'Matthew'),
          const _BookDef(43, 'የዮሐንስ ወንጌል', 21, canonicalId: 'JHN', nameEn: 'John'),
          const _BookDef(59, 'የያዕቆብ መልእክት', 5, canonicalId: 'JAS', nameEn: 'James'),
        ],
        totalDays: 55,
        titlePrefix: 'የዐቢይ ጾም ምንባብ',
        titlePrefixEn: 'Great Lent Reading',
        descPrefix: 'የንስሐ፣ የጸሎትና የምጽዋት ጉዞ',
        descPrefixEn: 'Repentance, Prayer and Almsgiving',
      ),
    ),

    // 8. ጾመ ነቢያት / የገና ጾም (Fast of the Prophets / Advent - 43 Days)
    ReadingPlan(
      id: 'advent_prophets_43',
      title: 'ጾመ ነቢያት',
      titleEn: 'Fast of the Prophets (Advent)',
      subtitle: 'ከኅዳር 15 እስከ ልደተ ክርስቶስ የነቢያት ትንቢትና የልደቱ ምሥጢር ምንባባት',
      subtitleEn: 'Prophecies and readings leading to the Nativity of Christ (43 Days)',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: 43,
      coverIcon: 'church',
      badgeText: '43 ቀናት • ጾመ ነቢያት',
      badgeTextEn: '43 Days • Advent Fast',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(23, 'ትንቢተ ኢሳይያስ', 66, canonicalId: 'ISA', nameEn: 'Isaiah'),
          const _BookDef(33, 'ትንቢተ ሚክያስ', 7, canonicalId: 'MIC', nameEn: 'Micah'),
          const _BookDef(42, 'የሉቃስ ወንጌል', 2, canonicalId: 'LUK', nameEn: 'Luke'),
        ],
        totalDays: 43,
        titlePrefix: 'ጾመ ነቢያት',
        titlePrefixEn: 'Prophets Fast',
        descPrefix: 'ስለ አማኑኤል ልደት የተነገረ ትንቢት',
        descPrefixEn: 'Prophecies of Emmanuel\'s Birth',
      ),
    ),

    // 9. ጾመ ፍልሰታ (Fast of Assumption - 16 Days)
    ReadingPlan(
      id: 'filseta_16',
      title: 'ጾመ ፍልሰታ',
      titleEn: 'Fast of the Assumption (Filseta)',
      subtitle: 'ከነሐሴ 1 እስከ 16 የእመቤታችንን ነገረ ማርያምና የወንጌል ምንባባት',
      subtitleEn: '16 days of Marian devotion, Gospel readings, and sacred hymns',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: 16,
      coverIcon: 'favorite',
      badgeText: '16 ቀናት • ነሐሴ 1-16',
      badgeTextEn: '16 Days • Nehase 1-16',
      passages: List.generate(16, (i) {
        final day = i + 1;
        const refs = [
          [42, 'የሉቃስ ወንጌል', 'Luke', 1, 'የመልአኩ ቅዱስ ገብርኤል ብሥራትና የእመቤታችን ትሕትና', 'Annunciation by Gabriel & humility of Mary', 'LUK'],
          [42, 'የሉቃስ ወንጌል', 'Luke', 2, 'የጌታችን ልደት በቤተልሔምና የእረኞች ምስጋና', 'Nativity in Bethlehem and shepherds\' praise', 'LUK'],
          [43, 'የዮሐንስ ወንጌል', 'John', 2, 'በቃና ዘገሊላ የተደረገው የመጀመሪያው ተአምር', 'First miracle at Cana in Galilee', 'JHN'],
          [43, 'የዮሐንስ ወንጌል', 'John', 19, 'በመስቀሉ ሥር ለዮሐንስ የተሰጠች የሁላችን እናት', 'At the foot of the Cross: Mother given to John', 'JHN'],
          [44, 'የሐዋርያት ሥራ', 'Acts', 1, 'ከሐዋርያት ጋር በአንድ ልብ በጸሎት መትጋቷ', 'Devoted together in prayer with the apostles', 'ACT'],
          [19, 'መዝሙረ ዳዊት', 'Psalms', 45, '«ንግሥቲቱ በቀኝህ ትቆማለች» — የዳዊት መዝሙር', '«At your right hand stands the queen»', 'PSA'],
          [19, 'መዝሙረ ዳዊት', 'Psalms', 87, '«መሠረቶቹ በተቀደሱ ተራሮች ናቸው»', '«Her foundation is in the holy mountains»', 'PSA'],
          [19, 'መዝሙረ ዳዊት', 'Psalms', 132, '«እግዚአብሔር ጽዮንን መርጦአታልና፥ ማደሪያውም ትሆን ዘንድ ወድዷታል»', '«For the Lord has chosen Zion as his dwelling»', 'PSA'],
          [23, 'ትንቢተ ኢሳይያስ', 'Isaiah', 7, '«እነሆ፥ ድንግል ትፀንሳለች ልጅም ትወልዳለች»', '«Behold, the virgin shall conceive and bear a Son»', 'ISA'],
          [26, 'ትንቢተ ሕዝቅኤል', 'Ezekiel', 44, 'የተዘጋችው የምሥራቅ ደጅ ምሳሌ', 'The closed East Gate of the sanctuary', 'EZK'],
          [22, 'መኃልየ መኃልይ ዘሰሎሞን', 'Song of Solomon', 4, '«ወዳጄ ሆይ፥ ሁለንተናሽ ውብ ነው፥ ነውርም የለብሽም»', '«You are altogether beautiful, my darling, there is no flaw in you»', 'SNG'],
          [20, 'መጽሐፈ ምሳሌ', 'Proverbs', 8, 'የሰማያዊት ጥበብ ምስጋና', 'The glory and praise of Heavenly Wisdom', 'PRO'],
          [20, 'መጽሐፈ ምሳሌ', 'Proverbs', 31, '«ልባም ሴትን ማን ሊያገኛት ይችላል?»', '«A wife of noble character who can find?»', 'PRO'],
          [48, 'ወደ ገላትያ ሰዎች', 'Galatians', 4, '«የዘመኑ ፍጻሜ በደረሰ ጊዜ እግዚአብሔር ከሴት የተወለደውን ልጁን ላከ»', '«God sent his Son, born of a woman»', 'GAL'],
          [66, 'የዮሐንስ ራእይ', 'Revelation', 12, 'ፀሐይን ተጎናጽፋ ጨረቃ ከእግሮቿ በታች ያላት ሴት', 'The woman clothed with the sun and moon under her feet', 'REV'],
          [19, 'መዝሙረ ዳዊት', 'Psalms', 150, 'የፍልሰታ ፍጻሜና የምስጋና መዝሙር', 'Conclusion of Filseta with psalms of praise', 'PSA'],
        ];
        final r = refs[i];
        return DailyReadingPassage(
          day: day,
          title: 'ጾመ ፍልሰታ — ቀን $day',
          titleEn: 'Fast of Assumption — Day $day',
          bookNumber: r[0] as int,
          canonicalId: r[6] as String,
          bookName: r[1] as String,
          bookNameEn: r[2] as String,
          startChapter: r[3] as int,
          endChapter: r[3] as int,
          description: r[4] as String,
          descriptionEn: r[5] as String,
        );
      }),
    ),

    // 10. መጽሐፈ ምሳሌ በ31 ቀናት (Proverbs Wisdom - 31 Days)
    ReadingPlan(
      id: 'proverbs_31',
      title: 'መጽሐፈ ምሳሌ በ31 ቀናት',
      titleEn: 'Proverbs in 31 Days',
      subtitle: 'በየቀኑ አንድ ምዕራፍ በማንበብ ሰማያዊ ጥበብንና ማስተዋልን ገንዘብ ያድርጉ',
      subtitleEn: 'Read one chapter daily to gain divine wisdom and discernment',
      category: 'ጥበብና መዝሙር',
      categoryEn: 'Wisdom & Psalms',
      totalDays: 31,
      coverIcon: 'lightbulb',
      badgeText: '31 ቀናት • 1 ምዕራፍ/ቀን',
      badgeTextEn: '31 Days • 1 ch/day',
      passages: List.generate(31, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'የጥበብ ቃል — ቀን $day',
          titleEn: 'Words of Wisdom — Day $day',
          bookNumber: 20,
          canonicalId: 'PRO',
          bookName: 'መጽሐፈ ምሳሌ',
          bookNameEn: 'Proverbs',
          startChapter: day,
          endChapter: day,
          description: 'መጽሐፈ ምሳሌ ምዕራፍ $day ንባብ',
          descriptionEn: 'Reading Proverbs Chapter $day',
        );
      }),
    ),

    // 11. መዝሙረ ዳዊት በ60 ቀናት (Psalms of David - 60 Days)
    ReadingPlan(
      id: 'psalms_60',
      title: 'መዝሙረ ዳዊት በ60 ቀናት',
      titleEn: 'Psalms of David in 60 Days',
      subtitle: 'የዳዊት 150 መዝሙራትን በጸሎትና በምስጋና መንፈስ ያንብቡ',
      subtitleEn: 'Pray and meditate through all 150 Psalms of David',
      category: 'ጥበብና መዝሙር',
      categoryEn: 'Wisdom & Psalms',
      totalDays: 60,
      coverIcon: 'music_note',
      badgeText: '60 ቀናት • 2-3 መዝሙር/ቀን',
      badgeTextEn: '60 Days • 2-3 psalms/day',
      passages: List.generate(60, (i) {
        final day = i + 1;
        final startCh = ((i * 150) ~/ 60) + 1;
        final endCh = (((i + 1) * 150) ~/ 60).clamp(startCh, 150);
        return DailyReadingPassage(
          day: day,
          title: 'የጸሎትና የምስጋና መዝሙር — ቀን $day',
          titleEn: 'Prayer & Praise Psalm — Day $day',
          bookNumber: 19,
          canonicalId: 'PSA',
          bookName: 'መዝሙረ ዳዊት',
          bookNameEn: 'Psalms',
          startChapter: startCh,
          endChapter: endCh,
          description: 'መዝሙረ ዳዊት ምዕራፍ $startCh እስከ $endCh',
          descriptionEn: 'Psalms of David Chapters $startCh–$endCh',
        );
      }),
    ),

    // 12. የክርስቶስ ተአምራትና ምሳሌዎች (Miracles & Parables - 21 Days)
    ReadingPlan(
      id: 'miracles_21',
      title: 'የክርስቶስ ተአምራትና ምሳሌዎች',
      titleEn: 'Miracles & Parables of Christ',
      subtitle: 'ዕውራንን ማብራት፣ አልዓዛርን ማስነሣትና የጠፋው ልጅ ምሳሌ',
      subtitleEn: 'Sign miracles and foundational parables from the Gospel of John',
      category: 'ሐዲስ ኪዳን',
      categoryEn: 'New Testament',
      totalDays: 21,
      coverIcon: 'stars',
      badgeText: '21 ቀናት • ተአምራት',
      badgeTextEn: '21 Days • Miracles',
      passages: List.generate(21, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'ተአምረ ኢየሱስ — ቀን $day',
          titleEn: 'Miracles of Jesus — Day $day',
          bookNumber: 43,
          canonicalId: 'JHN',
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          startChapter: day,
          endChapter: day,
          description: 'የዮሐንስ ወንጌል ምዕራፍ $day • የክርስቶስ የማዳን ሥራና ምሥጢራዊ ትምህርት',
          descriptionEn: 'Gospel of John Chapter $day • Christ\'s saving work and divine signs',
        );
      }),
    ),

    // 13. የእምነትና የጽናት ቃላት (Faith & Endurance - 30 Days)
    ReadingPlan(
      id: 'faith_30',
      title: 'የእምነትና የጽናት ቃላት',
      titleEn: 'Faith & Endurance',
      subtitle: 'በፈተና ጊዜ ብርታትና ሰላም የሚሰጡ የሐዋርያት መልእክታት',
      subtitleEn: 'Apostolic epistles of strength, peace, and persevering faith',
      category: 'ጥበብና መዝሙር',
      categoryEn: 'Wisdom & Psalms',
      totalDays: 30,
      coverIcon: 'shield',
      badgeText: '30 ቀናት • ጽናትና እምነት',
      badgeTextEn: '30 Days • Faith & Courage',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(45, 'ወደ ሮሜ ሰዎች', 16, canonicalId: 'ROM', nameEn: 'Romans'),
          const _BookDef(58, 'ወደ ዕብራውያን', 13, canonicalId: 'HEB', nameEn: 'Hebrews'),
          const _BookDef(59, 'የያዕቆብ መልእክት', 5, canonicalId: 'JAS', nameEn: 'James'),
        ],
        totalDays: 30,
        titlePrefix: 'የእምነትና የጽናት ቃል',
        titlePrefixEn: 'Words of Faith & Courage',
        descPrefix: 'በእምነት መጽናትና መንፈሳዊ ብርታት',
        descPrefixEn: 'Persevering in Faith & Spiritual Strength',
      ),
    ),

    // 14. የነቢያት ትንቢት ስለ ክርስቶስ (Messianic Prophecies - 40 Days)
    ReadingPlan(
      id: 'prophecies_40',
      title: 'የነቢያት ትንቢት ስለ ክርስቶስ',
      titleEn: 'Messianic Prophecies',
      subtitle: 'ኢሳይያስ፣ ዳንኤል፣ ሚክያስና ዘካርያስ ስለ መድኃኔዓለም የተናገሩት',
      subtitleEn: 'Prophecies of Isaiah, Daniel, and Zechariah concerning the Messiah',
      category: 'ዓመታዊ',
      categoryEn: 'Annual',
      totalDays: 40,
      coverIcon: 'visibility',
      badgeText: '40 ቀናት • ትንቢተ ነቢያት',
      badgeTextEn: '40 Days • Prophecies',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(23, 'ትንቢተ ኢሳይያስ', 66, canonicalId: 'ISA', nameEn: 'Isaiah'),
          const _BookDef(27, 'ትንቢተ ዳንኤል', 12, canonicalId: 'DAN', nameEn: 'Daniel'),
          const _BookDef(38, 'ትንቢተ ዘካርያስ', 14, canonicalId: 'ZEC', nameEn: 'Zechariah'),
        ],
        totalDays: 40,
        titlePrefix: 'የመሲሑ ትንቢት',
        titlePrefixEn: 'Messianic Prophecy',
        descPrefix: 'ስለ ክርስቶስ መወለድ፣ መከራና ክብር የተነገረ ትንቢት',
        descPrefixEn: 'Prophecy of Christ\'s Birth, Passion and Glory',
      ),
    ),
  ];

  static ReadingPlan? getPlanById(String id) {
    for (final p in allPlans) {
      if (p.id == id) return p;
    }
    return null;
  }
}
