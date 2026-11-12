import '../models/reading_plan.dart';
import '../services/bahire_hasab_service.dart';

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

  static _BookDef _findBookByCanon(String canonicalId) {
    for (final b in _otBooks) {
      if (b.canonicalId == canonicalId) return b;
    }
    for (final b in _ntBooks) {
      if (b.canonicalId == canonicalId) return b;
    }
    throw ArgumentError('Unknown canonicalId: $canonicalId');
  }

  /// Builds curated seasonal daily passages from compact tuples:
  /// `[canonicalId, startCh, endCh, titleAm, titleEn, descAm, descEn]`
  static List<DailyReadingPassage> _buildCuratedPassages(List<List<dynamic>> entries) {
    return List<DailyReadingPassage>.generate(entries.length, (i) {
      final row = entries[i];
      final book = _findBookByCanon(row[0] as String);
      final startCh = row[1] as int;
      final endCh = row[2] as int;
      if (startCh < 1 || endCh > book.chapters || startCh > endCh) {
        throw ArgumentError('Invalid chapter range $startCh-$endCh for ${book.canonicalId} (max ${book.chapters})');
      }
      return DailyReadingPassage(
        day: i + 1,
        title: row[3] as String,
        titleEn: row[4] as String,
        bookNumber: book.num,
        canonicalId: book.canonicalId,
        bookName: book.name,
        bookNameEn: book.nameEn,
        startChapter: startCh,
        endChapter: endCh,
        description: row[5] as String,
        descriptionEn: row[6] as String,
      );
    });
  }

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

  static const List<String> _apostolicEpistleOrder = [
    '1PE',
    '2PE',
    '1JN',
    '2JN',
    '3JN',
    'JAS',
    'JUD',
  ];

  static int? _cachedApostlesSeasonYear;
  static ReadingPlan? _cachedApostlesPlan;

  /// Dynamically constructs the Fast of the Apostles (`apostles_fast`) reading plan
  /// whose duration shifts each Ethiopian year (14–49 days) from Monday after Pentecost to Hamle 4.
  /// - When duration <= 28 days: fits all 28 chapters of Acts cleanly (1–2 ch/day).
  /// - When duration > 28 days: Days 1–28 cover Acts 1–28 (1 ch/day), and remaining days (up to 21 max)
  ///   continue in EOTC General Epistles order (1–2 Peter, 1–3 John, James, Jude).
  static ReadingPlan buildApostlesFastPlan({EthiopianDate? targetDate}) {
    final today = targetDate ?? BahireHasabService.fromGregorian(DateTime.now());
    final seasonInfo = BahireHasabService.getFastSeasonInfo('apostles_fast', today);
    final start = seasonInfo.startDate!;
    final end = seasonInfo.endDate!;
    final targetYear = start.year;

    if (_cachedApostlesSeasonYear == targetYear && _cachedApostlesPlan != null) {
      return _cachedApostlesPlan!;
    }

    final totalDays = BahireHasabService.daysBetween(start, end) + 1;
    final acts = _findBookByCanon('ACT');
    final passages = <DailyReadingPassage>[];

    if (totalDays <= acts.chapters) {
      for (int i = 0; i < totalDays; i++) {
        final day = i + 1;
        final startCh = ((i * acts.chapters) ~/ totalDays) + 1;
        final endCh = (((i + 1) * acts.chapters) ~/ totalDays).clamp(startCh, acts.chapters);
        final chTextAm = startCh == endCh ? 'ምዕራፍ $startCh' : 'ምዕራፍ $startCh–$endCh';
        final chTextEn = startCh == endCh ? 'Chapter $startCh' : 'Chapters $startCh–$endCh';
        passages.add(
          DailyReadingPassage(
            day: day,
            title: 'ጾመ ሐዋርያት ቀን $day — የሐዋርያት ሥራ $chTextAm',
            titleEn: 'Apostles Fast Day $day — Acts $chTextEn',
            bookNumber: acts.num,
            canonicalId: acts.canonicalId,
            bookName: acts.name,
            bookNameEn: acts.nameEn,
            startChapter: startCh,
            endChapter: endCh,
            description: 'የመንፈስ ቅዱስ መውረድና የቅዱሳን ሐዋርያት የወንጌል አገልግሎት ($chTextAm)',
            descriptionEn: 'Apostolic mission and witness of the early Church ($chTextEn)',
          ),
        );
      }
    } else {
      // Days 1..28: Book of Acts (1 chapter per day)
      for (int ch = 1; ch <= acts.chapters; ch++) {
        passages.add(
          DailyReadingPassage(
            day: ch,
            title: 'ጾመ ሐዋርያት ቀን $ch — የሐዋርያት ሥራ ምዕራፍ $ch',
            titleEn: 'Apostles Fast Day $ch — Acts Chapter $ch',
            bookNumber: acts.num,
            canonicalId: acts.canonicalId,
            bookName: acts.name,
            bookNameEn: acts.nameEn,
            startChapter: ch,
            endChapter: ch,
            description: 'የመንፈስ ቅዱስ መውረድና የቅዱሳን ሐዋርያት የወንጌል አገልግሎት (ምዕራፍ $ch)',
            descriptionEn: 'Apostolic mission and witness of the early Church (Chapter $ch)',
          ),
        );
      }

      // Remaining days (> 28, up to 21 max): General Epistles in EOTC canonical sequence
      final extraDays = totalDays - acts.chapters;
      final epistleChapters = <Map<String, dynamic>>[];
      for (final canon in _apostolicEpistleOrder) {
        final book = _findBookByCanon(canon);
        for (int ch = 1; ch <= book.chapters; ch++) {
          epistleChapters.add({'book': book, 'chapter': ch});
        }
      }

      final count = extraDays.clamp(0, epistleChapters.length);
      for (int j = 0; j < count; j++) {
        final day = acts.chapters + j + 1;
        final item = epistleChapters[j];
        final book = item['book'] as _BookDef;
        final ch = item['chapter'] as int;
        passages.add(
          DailyReadingPassage(
            day: day,
            title: 'ጾመ ሐዋርያት ቀን $day — ${book.name} ምዕራፍ $ch',
            titleEn: 'Apostles Fast Day $day — ${book.nameEn} Chapter $ch',
            bookNumber: book.num,
            canonicalId: book.canonicalId,
            bookName: book.name,
            bookNameEn: book.nameEn,
            startChapter: ch,
            endChapter: ch,
            description: 'የሐዋርያት መልእክታት ትምህርትና በእምነት መጽናት (ምዕራፍ $ch)',
            descriptionEn: 'General Epistles of the Holy Apostles (Chapter $ch)',
          ),
        );
      }
    }

    final hasEpistles = totalDays > acts.chapters;
    final rangeAm = seasonInfo.getSeasonRangeText(isEnglish: false);
    final rangeEn = seasonInfo.getSeasonRangeText(isEnglish: true);

    final plan = ReadingPlan(
      id: 'apostles_fast',
      title: 'ጾመ ሐዋርያት',
      titleEn: 'Fast of the Apostles',
      subtitle: hasEpistles
          ? 'ከበዓለ ጰራቅሊጦስ ማግሥት እስከ ሐምሌ 4 የሐዋርያት ሥራና የሐዋርያት መልእክታት ($totalDays ቀናት)'
          : 'ከበዓለ ጰራቅሊጦስ ማግሥት እስከ ሐምሌ 4 የሐዋርያት ሥራ ምንባባት ($totalDays ቀናት)',
      subtitleEn: hasEpistles
          ? 'Acts & General Epistles of the Apostles from Pentecost to Hamle 4 ($totalDays days in $targetYear E.C.)'
          : 'Book of Acts from the Monday after Pentecost to Hamle 4 ($totalDays days in $targetYear E.C.)',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: totalDays,
      coverIcon: 'menu_book',
      badgeText: '$totalDays ቀናት • $rangeAm',
      badgeTextEn: '$totalDays Days • $rangeEn',
      passages: passages,
    );

    _cachedApostlesSeasonYear = targetYear;
    _cachedApostlesPlan = plan;
    return plan;
  }

  /// Returns all reading plans dynamically calibrated to [targetDate] (defaults to today).
  static List<ReadingPlan> getPlansForDate([EthiopianDate? targetDate]) {
    final apostlesPlan = buildApostlesFastPlan(targetDate: targetDate);
    final result = <ReadingPlan>[];
    for (final p in _staticPlans) {
      if (p.id == 'filseta_16') {
        // Insert Fast of the Apostles chronologically right before Filseta
        result.add(apostlesPlan);
      }
      result.add(p);
    }
    return result;
  }

  static List<ReadingPlan> get allPlans => getPlansForDate();

  static final List<ReadingPlan> _staticPlans = [
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

    // 6. ጾመ ነቢያት / የገና ጾም (Fast of the Prophets / Advent - Hidar 15 - Tahsas 28)
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
      passages: _buildCuratedPassages(const [
        ['GEN', 3, 3, 'ቀን 1 — የሴቲቱ ዘር ተስፋ', 'Day 1 — Seed of the Woman Promised', 'በኤደን የተሰጠው የመጀመሪያው የድኅነት ተስፋ', 'The first promise of the Savior given in Eden'],
        ['GEN', 12, 12, 'ቀን 2 — ለአብርሃም የተሰጠው ቃል ኪዳን', 'Day 2 — The Covenant with Abraham', '«የምድር ነገዶች ሁሉ በአንተ ይባረካሉ»', 'In your seed all nations of the earth shall be blessed'],
        ['GEN', 49, 49, 'ቀን 3 — የይሁዳ በትረ መንግሥት (ሴሎም)', 'Day 3 — The Scepter of Judah (Shiloh)', 'የያዕቆብ ትንቢት ስለ ንጉሡ መምጣት', 'Jacob\'s prophecy of the coming Ruler'],
        ['NUM', 24, 24, 'ቀን 4 — ከያዕቆብ የሚወጣው ኮከብ', 'Day 4 — A Star Out of Jacob', '«ከያዕቆብ ኮከብ ይወጣል፥ ከእስራኤልም በትር ይነሣል»', 'A Star shall come out of Jacob and a Scepter from Israel'],
        ['DEU', 18, 18, 'ቀን 5 — እንደ ሙሴ ያለ ነቢይ', 'Day 5 — A Prophet Like Moses', 'እግዚአብሔር ስለሚያስነሣው ታላቅ ነቢይ የተነገረ ትንቢት', 'God promises to raise up the Prophet to whom all must listen'],
        ['2SA', 7, 7, 'ቀን 6 — ለዳዊት የተገባ ዘላለማዊ ኪዳን', 'Day 6 — Eternal Covenant with David', '«ዙፋንህም ለዘላለም ይጸናል»', 'Your house and kingdom shall endure forever'],
        ['1CH', 17, 17, 'ቀን 7 — የዳዊት ዘር የእግዚአብሔር ልጅ', 'Day 7 — Son of David, Eternal King', 'እግዚአብሔር ለዳዊት ቤት የሚሠራለት ዘላለማዊ መንግሥት', 'God establishes the eternal throne of David\'s offspring'],
        ['PSA', 2, 2, 'ቀን 8 — «አንተ ልጄ ነህ እኔ ዛሬ ወለድሁህ»', 'Day 8 — You Are My Son, Today I Have Begotten You', 'ስለ ተቀባው ንጉሥ ስለ ክርስቶስ የተነገረ መዝሙር', 'Royal psalm proclaiming the Lord\'s Anointed'],
        ['PSA', 45, 45, 'ቀን 9 — የንጉሡ ክብርና ዘላለማዊ መንግሥት', 'Day 9 — The Glorious Bridegroom King', '«አምላክ ሆይ፥ ዙፋንህ ለዘላለም ነው»', 'Your throne, O God, is forever and ever'],
        ['PSA', 72, 72, 'ቀን 10 — የጻድቁ ንጉሥ የሰላም መንግሥት', 'Day 10 — Reign of the Righteous King', '«የሳባና የዓረብ ነገሥታት እጅ መንሻ ያመጣሉ»', 'Kings of Tarshish, Sheba, and Seba shall bring gifts'],
        ['PSA', 89, 89, 'ቀን 11 — የዳዊት የኪዳን ምሕረትና እውነት', 'Day 11 — Covenant Steadfastness to David', '«እኔ ከመረጥሁት ጋር ቃል ኪዳን አደረግሁ»', 'I have made a covenant with My chosen David'],
        ['PSA', 110, 110, 'ቀን 12 — በቀኝ የተቀመጠው ንጉሥና ካህን', 'Day 12 — King & Priest Like Melchizedek', '«እግዚአብሔር ጌታዬን፦ በቀኜ ተቀመጥ አለው»', 'The Lord said to my Lord: Sit at My right hand'],
        ['PSA', 132, 132, 'ቀን 13 — በኤፍራታ የተገኘው ማደሪያ', 'Day 13 — Resting Place Found in Ephrathah', '«እነሆ በኤፍራታ ሰማነው፥ በዱርም ሜዳ አገኘነው»', 'We heard of it in Ephrathah; the Lord chose Zion'],
        ['ISA', 2, 2, 'ቀን 14 — የእግዚአብሔር ቤት ተራራ', 'Day 14 — Mountain of the Lord\'s House', 'ከጽዮን የሚወጣው ሕግና ለአሕዛብ ሁሉ የሚመጣ ሰላም', 'All nations shall flow to the mountain of the Lord'],
        ['ISA', 7, 7, 'ቀን 15 — የድንግል መፀነስና አማኑኤል', 'Day 15 — Virgin Birth & Emmanuel', '«እነሆ፥ ድንግል ትፀንሳለች ልጅም ትወልዳለች፥ ስሙንም አማኑኤል ብላ ትጠራዋለች»', 'Behold, the virgin shall conceive and bear Emmanuel'],
        ['ISA', 9, 9, 'ቀን 16 — ሕፃን ተወልዶልናል፥ ወንድ ልጅም ተሰጥቶናል', 'Day 16 — Unto Us a Child Is Born', '«ስሙም ድንቅ መካር፥ ኃያል አምላክ፥ የዘላለም አባት፥ የሰላም አለቃ ይባላል»', 'Wonderful Counselor, Mighty God, Everlasting Father, Prince of Peace'],
        ['ISA', 11, 11, 'ቀን 17 — ከእሴይ ግንድ የሚወጣ በትር', 'Day 17 — Shoot from the Stump of Jesse', 'በእርሱ ላይ የጥበብና የማስተዋል መንፈስ ያድራል', 'The Spirit of the Lord shall rest upon the Branch of Jesse'],
        ['ISA', 25, 25, 'ቀን 18 — ሞትን ለዘላለም የሚውጠው ጌታ', 'Day 18 — Death Swallowed Up Forever', '«እነሆ፥ በእርሱ የታመንን አምላካችን ይህ ነው፤ ያድነንማል»', 'Behold, this is our God; we have waited for Him to save us'],
        ['ISA', 35, 35, 'ቀን 19 — አምላክ ራሱ መጥቶ ያድናችኋል', 'Day 19 — God Himself Will Come to Save', 'የዕውራን ዓይን ይገለጣል፥ የደንቆሮዎችም ጆሮ ይከፈታል', 'The eyes of the blind shall be opened and the desert shall rejoice'],
        ['ISA', 40, 40, 'ቀን 20 — «የእግዚአብሔርን መንገድ አዘጋጁ»', 'Day 20 — Prepare the Way of the Lord', 'ለሕዝቡ መጽናናትና የመጥምቁ ዮሐንስ መልእክት', 'Comfort My people; a voice cries in the wilderness'],
        ['ISA', 42, 42, 'ቀን 21 — ለአሕዛብ ብርሃን የሆነው የእግዚአብሔር ባሪያ', 'Day 21 — A Light to the Gentiles', '«የተቀጠቀጠውን ሸምበቆ አይሰብርም፥ የሚጤሰውንም ክር አያጠፋም»', 'Behold My Servant, upholding justice with gentleness'],
        ['ISA', 49, 49, 'ቀን 22 — እስከ ምድር ዳርቻ የሚደርስ ማዳን', 'Day 22 — Salvation to the Ends of the Earth', '«እስከ ምድር ዳርቻ ድረስ መድኃኒቴ ትሆን ዘንድ ለአሕዛብ ብርሃን አድርጌ ሰጥቼሃለሁ»', 'I will make You a light for the nations'],
        ['ISA', 52, 52, 'ቀን 23 — የምሥራች የሚያወሩ እግሮች ውበት', 'Day 23 — Glad Tidings of Peace & Salvation', '«የምሥራች የሚያወራ፥ ሰላምንም የሚያሰማ እግር በተራሮች ላይ እጅግ ያምራል»', 'How beautiful upon the mountains are the feet bringing good news'],
        ['ISA', 55, 55, 'ቀን 24 — ወደ ሕይወት ውኃ የተጠራንበት ኪዳን', 'Day 24 — Everlasting Covenant of Mercy', '«የተጠማችሁ ሁሉ ወደ ውኃ ኑ... የታመነውን የዳዊትን ምሕረት እሰጣችኋለሁ»', 'Come everyone who thirsts; I will make an everlasting covenant'],
        ['ISA', 60, 60, 'ቀን 25 — «ብርሃንሽ መጥቶአልና ተነሺ፥ አብሪ»', 'Day 25 — Arise, Shine, For Your Light Has Come', 'አሕዛብ ወደ ብርሃንሽ ነገሥታትም ወደ መውጫሽ ፀዳል ይመጣሉ', 'Nations shall come to your light, and kings to your brightness'],
        ['ISA', 61, 61, 'ቀን 26 — የጸጋውን ዓመት የሚያውጅ መሲሕ', 'Day 26 — Anointed to Proclaim Liberty', '«ለድሆች የምሥራችን እሰብክ ዘንድ እግዚአብሔር ቀብቶኛል»', 'The Spirit of the Lord God is upon Me to bring good news'],
        ['ISA', 62, 62, 'ቀን 27 — «እነሆ መድኃኒትሽ ይመጣል»', 'Day 27 — Behold, Your Salvation Comes', 'ለጽዮን የተሰጠ አዲስ ስምና የክብር አክሊል', 'Say to the daughter of Zion: Behold, your Salvation comes!'],
        ['JER', 23, 23, 'ቀን 28 — «እግዚአብሔር ጽድቃችን» የተባለ ጻድቅ ቍጥቋጥ', 'Day 28 — The Righteous Branch of David', '«ለዳዊት ጻድቅ ቍጥቋጥ አስነሣለሁ፥ እርሱም ንጉሥ ሆኖ ይነግሣል»', 'I will raise up for David a righteous Branch; He is our Righteousness'],
        ['JER', 31, 31, 'ቀን 29 — በልብ የሚጻፍ አዲስ ኪዳን', 'Day 29 — The New Covenant Promised', '«ከእስራኤል ቤት ጋር አዲስ ቃል ኪዳን የምገባበት ወራት ይመጣል»', 'I will write My law upon their hearts and forgive their iniquity'],
        ['JER', 33, 33, 'ቀን 30 — የጽድቅ ኪዳን መፈጸም', 'Day 30 — Fulfillment of the Covenant of Peace', '«ለእስራኤልና ለይሁዳ ቤት የተናገርሁትን መልካም ቃል እፈጽማለሁ»', 'God fulfills His sure covenant promise with David\'s house'],
        ['EZK', 34, 34, 'ቀን 31 — በጎቹን የሚጠብቅ አንዱ እረኛ', 'Day 31 — One Shepherd Over the Flock', '«እኔ ራሴ በጎቼን እጠብቃለሁ... አንዱንም እረኛ ዳዊትን አቆምላቸዋለሁ»', 'I Myself will be the shepherd of My sheep'],
        ['DAN', 2, 2, 'ቀን 32 — ያለ እጅ ከተራራው የተፈነቀለው ድንጋይ', 'Day 32 — Stone Cut Without Hands', 'ለዘላለም የማይፈርስ የእግዚአብሔር መንግሥት', 'The stone cut without human hands fills the whole earth'],
        ['DAN', 7, 7, 'ቀን 33 — በሰማይ ደመና የመጣው የሰው ልጅ', 'Day 33 — Son of Man on Clouds of Heaven', 'መንግሥቱ የማያልፍ የዘላለም ግዛት ተሰጠው', 'His dominion is an everlasting dominion that shall not pass away'],
        ['DAN', 9, 9, 'ቀን 34 — የሰባው ሱባኤ መሲሕ ትንቢት', 'Day 34 — The Seventy Weeks & Anointed Prince', 'ስለ መሲሑ መገለጥና ስለ ዘላለማዊ ጽድቅ መምጣት', 'Prophecy of the time appointed for the Anointed One'],
        ['HOS', 11, 11, 'ቀን 35 — «ልጄን ከግብፅ ጠራሁት»', 'Day 35 — Out of Egypt I Called My Son', 'የእግዚአብሔር የአባትነት ፍቅርና የሆሴዕ ትንቢት', 'God\'s tender love and prophetic calling from Egypt'],
        ['MIC', 4, 4, 'ቀን 36 — የእግዚአብሔር ሰላምና የጽዮን ክብር', 'Day 36 — Peace Among the Nations from Zion', 'ሰይፋቸውንም ማረሻ ጦራቸውንም ማጭድ ያደርጋሉ', 'Swords beaten into plowshares under the Messiah\'s reign'],
        ['MIC', 5, 5, 'ቀን 37 — «አንቺም ቤተ ልሔም ኤፍራታ ሆይ»', 'Day 37 — Out of Bethlehem Ephrathah', '«አወጣጡ ከቀድሞ ጀምሮ ከዘላለም የሆነ፥ በእስራኤል ላይ ገዥ የሚሆን ከአንቺ ይወጣልኛል»', 'From Bethlehem shall come forth the Ruler whose origins are from eternity'],
        ['HAG', 2, 2, 'ቀን 38 — «የአሕዛብ ሁሉ ምኞት ይመጣል»', 'Day 38 — Desire of All Nations Shall Come', 'ሁለተኛውን ቤተ መቅደስ በክብር የሚሞላው ጌታ', 'The glory of the latter temple shall be greater than the former'],
        ['ZEC', 2, 2, 'ቀን 39 — «በመካከልሽ እኖራለሁና ደስ ይበልሽ»', 'Day 39 — I Will Dwell in Your Midst', 'አሕዛብ ከእግዚአብሔር ጋር የሚተባበሩበት ቀን', 'Sing and rejoice, O daughter of Zion, for the Lord dwells with you'],
        ['ZEC', 9, 9, 'ቀን 40 — «ንጉሥሽ ጻድቅና አዳኝ ነው»', 'Day 40 — Your King Comes Righteous & Saving', 'ትሑት ሆኖ የሚመጣው ንጉሥ በምድር ሁሉ ሰላምን ያውጃል', 'Behold, your King comes humbly, speaking peace to the nations'],
        ['MAL', 3, 4, 'ቀን 41 — በድንገት ወደ መቅደሱ የሚመጣው ጌታ (ምዕራፍ 3-4)', 'Day 41 — Messenger of the Covenant & Sun of Righteousness', '«ለስሜ ለምትፈሩ የጽድቅ ፀሐይ ትወጣላችኋለች» (ምዕራፍ 3 እስከ 4)', 'The Lord shall suddenly come; the Sun of Righteousness rises (Ch. 3–4)'],
        ['LUK', 1, 1, 'ቀን 42 — የመልአኩ ቅዱስ ገብርኤል ብሥራት', 'Day 42 — Annunciation to Zechariah & St. Mary', 'የመጥምቁ ዮሐንስ መፀነስና ለድንግል ማርያም የተነገረ የምሥራች', 'Angel Gabriel announces the birth of the Savior to St. Mary'],
        ['LUK', 2, 2, 'ቀን 43 — የጌታችን ልደት በቤተ ልሔም (ልደተ ክርስቶስ)', 'Day 43 — Nativity of Christ in Bethlehem', '«ዛሬ በዳዊት ከተማ መድኃኒት እርሱም ክርስቶስ ጌታ የሆነ ተወልዶላችኋልና»', 'Today in the city of David a Savior is born to you, who is Christ the Lord'],
      ]),
    ),

    // 7. ጾመ ነነዌ (Fast of Nineveh - 3 Days, Book of Jonah)
    ReadingPlan(
      id: 'nineveh_3',
      title: 'ጾመ ነነዌ',
      titleEn: 'Fast of Nineveh',
      subtitle: 'የነነዌ ሰዎችን ንስሐና የእግዚአብሔርን ምሕረት የሚያሳየው የትንቢተ ዮናስ 3 ቀናት ንባብ',
      subtitleEn: 'Three-day reading through the Book of Jonah: repentance and God\'s mercy',
      category: 'ጾምና በዓላት',
      categoryEn: 'Fasts & Feasts',
      totalDays: 3,
      coverIcon: 'spa',
      badgeText: '3 ቀናት • ትንቢተ ዮናስ',
      badgeTextEn: '3 Days • Book of Jonah',
      passages: const [
        DailyReadingPassage(
          day: 1,
          title: 'ሰኞ — የዮናስ መሸሽና በዓሣ ሆድ ውስጥ የጸለየው ጸሎት',
          titleEn: 'Monday — Jonah\'s Flight & Prayer from the Deep',
          bookNumber: 32,
          canonicalId: 'JON',
          bookName: 'ትንቢተ ዮናስ',
          bookNameEn: 'Jonah',
          startChapter: 1,
          endChapter: 2,
          description: 'ዮናስ ወደ ተርሴስ መሸሹ፣ የባሕሩ ማዕበልና ከዓሣው ሆድ የጸለየው የንስሐ ጸሎት።',
          descriptionEn: 'Jonah flees to Tarshish, the storm at sea, and his prayer from inside the great fish.',
        ),
        DailyReadingPassage(
          day: 2,
          title: 'ማክሰኞ — የነነዌ ሰዎች ጾምና እውነተኛ ንስሐ',
          titleEn: 'Tuesday — Preaching in Nineveh & the Three-Day Fast',
          bookNumber: 32,
          canonicalId: 'JON',
          bookName: 'ትንቢተ ዮናስ',
          bookNameEn: 'Jonah',
          startChapter: 3,
          endChapter: 3,
          description: 'የነነዌ ንጉሥና ሕዝቡ ከታላቁ እስከ ታናሹ ማቅ ለብሰው በአመድ ላይ ተቀምጠው ሦስት ቀን መጾማቸው።',
          descriptionEn: 'Nineveh believes God, proclaims a fast in sackcloth and ashes, and turns from evil.',
        ),
        DailyReadingPassage(
          day: 3,
          title: 'ረቡዕ — ወሰን የሌለው የእግዚአብሔር ምሕረት',
          titleEn: 'Wednesday — God\'s Boundless Mercy Over Nineveh',
          bookNumber: 32,
          canonicalId: 'JON',
          bookName: 'ትንቢተ ዮናስ',
          bookNameEn: 'Jonah',
          startChapter: 4,
          endChapter: 4,
          description: 'እግዚአብሔር ቅልን በምሳሌ በማድረግ ንስሐ ለገባችው ለታላቂቱ ከተማ ለነነዌ ያለውን ርኅራኄ ማስተማሩ።',
          descriptionEn: 'The sign of the gourd: God teaches Jonah His compassion for the repentant city of Nineveh.',
        ),
      ],
    ),

    // 8. የዐቢይ ጾም ጉዞ (Great Lent - Yekatit/Megabit - Miyazya, 55 Days)
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
      passages: _buildCuratedPassages(const [
        // Week 1: ዘወረደ (Days 1-7)
        ['JOL', 2, 2, 'ዘወረደ ቀን 1 — «በጾምና በልቅሶ በፍጹም ልባችሁ ወደ እኔ ተመለሱ»', 'Zewerede Day 1 — Return to Me With Fasting and Weeping', 'የዐቢይ ጾም መጀመሪያ የንስሐ ጥሪ', 'Opening call to sincere repentance and fasting'],
        ['ISA', 58, 58, 'ዘወረደ ቀን 2 — እግዚአብሔር የመረጠው እውነተኛ ጾም', 'Zewerede Day 2 — The True Fast Chosen by God', 'የግፍን ሰንሰለት መፍታትና ለተራበው እንጀራን መቁረስ', 'Loosing the bonds of wickedness and sharing bread with the hungry'],
        ['PSA', 51, 51, 'ዘወረደ ቀን 3 — «አቤቱ ንጹሕ ልብን ፍጠርልኝ»', 'Zewerede Day 3 — Create in Me a Clean Heart', 'የዳዊት የንስሐ መዝሙር (መዝሙር 51)', 'David\'s great psalm of contrition and renewal'],
        ['MAT', 4, 4, 'ዘወረደ ቀን 4 — የጌታችን የ40 ቀን ጾምና የፈተና ድል', 'Zewerede Day 4 — 40-Day Fast & Victory Over Temptation', 'ጌታችን በገዳመ ቆሮንቶስ አርባ ቀንና አርባ ሌሊት ጾሞ ዲያብሎስን ድል መንሣቱ', 'Christ fasts forty days and overcomes the tempter'],
        ['MAT', 5, 5, 'ዘወረደ ቀን 5 — አንቀጸ ብፁዓንና የተራራው ስብከት', 'Zewerede Day 5 — Beatitudes & the Sermon on the Mount', 'የመንግሥተ ሰማያት ዜጎች ምግባርና ትሕትና', 'Blessed are the poor in spirit and the pure in heart'],
        ['MAT', 6, 6, 'ዘወረደ ቀን 6 — የጾም፣ የጸሎትና የምጽዋት ሥርዓት', 'Zewerede Day 6 — Fasting, Prayer, and Almsgiving in Secret', '«በምትጾሙበት ጊዜ እንደ ግብዞች አትጠውልጉ»', 'Alms, prayer, and fasting offered to the Father in secret'],
        ['JHN', 3, 3, 'ዘወረደ (እሑድ 1) — ከሰማይ የወረደው የሰው ልጅ', 'Zewerede (Sunday 1) — He Who Descended from Heaven', '«ከሰማይ ከወረደው በቀር ወደ ሰማይ የወጣ ማንም የለም» (ዘወረደ)', 'No one has ascended to heaven except He who descended from heaven'],
        // Week 2: ቅድስት (Days 8-14)
        ['LEV', 19, 19, 'ቅድስት ቀን 8 — «እኔ እግዚአብሔር ቅዱስ ነኝና እናንተም ቅዱሳን ሁኑ»', 'Kidist Day 8 — Be Holy, For I the Lord Am Holy', 'በቃልና በሥራ ቅድስናንና ፍቅረ ቢጽን መጠበቅ', 'Called to holiness and love of neighbor'],
        ['PSA', 15, 15, 'ቅድስት ቀን 9 — በተቀደሰው ተራራ የሚኖር ማን ነው?', 'Kidist Day 9 — Who Shall Dwell on Your Holy Hill?', 'ያለ ነውር የሚሄድና እውነትን በልቡ የሚናገር', 'He who walks blamelessly and speaks truth from his heart'],
        ['PSA', 24, 24, 'ቅድስት ቀን 10 — ንጹሕ እጅና የቀና ልብ', 'Kidist Day 10 — Clean Hands and a Pure Heart', 'ወደ እግዚአብሔር ተራራ ለመውጣት የሚገባ ንጽሕና', 'Who shall ascend the hill of the Lord?'],
        ['MAT', 7, 7, 'ቅድስት ቀን 11 — «ለምኑ ይሰጣችኋል፥ ፈልጉ ታገኛላችሁ»', 'Kidist Day 11 — Ask, Seek, Knock & Narrow Gate', 'በዐለት ላይ የተመሠረተች ቤትና ቀጥተኛው በር', 'Enter by the narrow gate; build your house upon the Rock'],
        ['1PE', 1, 1, 'ቅድስት ቀን 12 — በአካሄዳችሁ ሁሉ ቅዱሳን ሁኑ', 'Kidist Day 12 — Be Holy in All Your Conduct', 'በክቡር የክርስቶስ ደም መዋጀታችንና በፍቅር መኖር', 'Redeemed by the precious blood of Christ to live in holiness'],
        ['1JN', 1, 2, 'ቅድስት ቀን 13 — በብርሃን መመላለስና ንስሐ (ምዕራፍ 1-2)', 'Kidist Day 13 — Walking in the Light (Ch. 1–2)', '«ኃጢአታችንን ብንናዘዝ ይቅር ይለናል» (1ኛ ዮሐ 1-2)', 'If we confess our sins, He is faithful and just to forgive us'],
        ['JAS', 1, 1, 'ቅድስት (እሑድ 2) — ቃሉን የምታደርጉ ሁኑ እንጂ ሰሚዎች ብቻ አትሁኑ', 'Kidist (Sunday 2) — Doers of the Word & True Devotion', 'ንጹሕና ነውር የሌለበት አምልኮ በእግዚአብሔር ፊት', 'Pure and undefiled religion before God the Father'],
        // Week 3: ምኩራብ (Days 15-21)
        ['PSA', 69, 69, 'ምኩራብ ቀን 15 — «የቤትህ ቅናት በልታኛለችና»', 'Mikurab Day 15 — Zeal for Your House Has Consumed Me', 'ስለ ቤተ መቅደስ ክብር የተነገረ የዳዊት መዝሙር', 'Zeal for God\'s house and the prayer of the humble'],
        ['PSA', 84, 84, 'ምኩራብ ቀን 16 — «አቤቱ ማደሪያዎችህ እንዴት የተወደዱ ናቸው!»', 'Mikurab Day 16 — How Lovely Is Your Dwelling Place!', 'በእግዚአብሔር ቤት መኖርና አንድ ቀን ከሺህ ይበልጣል', 'A single day in Your courts is better than a thousand elsewhere'],
        ['ISA', 56, 56, 'ምኩራብ ቀን 17 — «ቤቴ ለአሕዛብ ሁሉ የጸሎት ቤት ይባላል»', 'Mikurab Day 17 — My House Shall Be Called a House of Prayer', 'የሰንበት አከባበርና የመቅደሱ ቅድስና', 'The Lord gathers outcasts into His house of prayer'],
        ['MAT', 12, 12, 'ምኩራብ ቀን 18 — «ምሕረትን እወዳለሁ መሥዋዕትንም አይደለም»', 'Mikurab Day 18 — Lord of the Sabbath & Mercy', 'ጌታችን የሰንበት ጌታ መሆኑና ከመቅደስ መብለጡ', 'I desire mercy, not sacrifice; One greater than the temple is here'],
        ['LUK', 4, 4, 'ምኩራብ ቀን 19 — በናዝሬት ምኩራብ የተነበበው የድኅነት ቃል', 'Mikurab Day 19 — Reading Isaiah in the Synagogue', 'ጌታችን በምኩራብ የጸጋውን ዓመት ማወጁ', 'Jesus proclaims freedom and the acceptable year of the Lord'],
        ['1CO', 3, 3, 'ምኩራብ ቀን 20 — «እናንተ የእግዚአብሔር ቤተ መቅደስ ናችሁ»', 'Mikurab Day 20 — You Are God\'s Temple', 'የእግዚአብሔር መንፈስ የሚኖርበት የልብ መቅደስ', 'God\'s temple is holy, and you are that temple'],
        ['JHN', 2, 2, 'ምኩራብ (እሑድ 3) — ቤተ መቅደሱን ከነጋዴዎች ማጽዳት', 'Mikurab (Sunday 3) — Cleansing the Temple', '«የአባቴን ቤት የንግድ ቤት አታድርጉት» (ምኩራብ)', 'Make not My Father\'s house a house of merchandise'],
        // Week 4: መጻጕዕ (Days 22-28)
        ['2KI', 5, 5, 'መጻጕዕ ቀን 22 — የንዕማን ከለምጽ መንጻት', 'Metsague Day 22 — Naaman Cleansed in the Jordan', 'በእምነትና በትሕትና የተገኘ ፈውስ', 'Healing through obedience and humility'],
        ['PSA', 32, 32, 'መጻጕዕ ቀን 23 — «መተላለፉ የቀረችለት ኃጢአቱም የተከደነችለት ምስጉን ነው»', 'Metsague Day 23 — Blessed Is the One Whose Sin Is Forgiven', 'ንስሐና የነፍስ ፈውስ ደስታ', 'I acknowledged my sin to You and You forgave its guilt'],
        ['PSA', 38, 38, 'መጻጕዕ ቀን 24 — በሕመምና በጸጸት ውስጥ ያለ ጸሎት', 'Metsague Day 24 — Prayer of the Penitent Sufferer', '«አቤቱ በጽድቅህ አትዘንብኝ፥ በቍጣህም አትቅሠፈኝ»', 'Do not forsake me, O Lord my God, my salvation'],
        ['MAT', 8, 8, 'መጻጕዕ ቀን 25 — ለምጻሙን፣ ሽባውንና ባሕሩን የፈወሰ ጌታ', 'Metsague Day 25 — Healing the Leper & Centurion\'s Servant', '«እርሱ ራሱ ድካማችንን ወሰደ ደዌአችንንም ተሸከመ»', 'He Himself took our infirmities and bore our diseases'],
        ['MAT', 9, 9, 'መጻጕዕ ቀን 26 — «ልጄ ሆይ አይዞህ፥ ኃጢአትህ ተሰረየችልህ»', 'Metsague Day 26 — Forgiving and Healing the Paralytic', 'ለሽባው ፈውስንና የኃጢአትን ስርየት የሰጠ ጌታ', 'The Son of Man has authority on earth to forgive sins'],
        ['MRK', 2, 2, 'መጻጕዕ ቀን 27 — «ኃጢአተኞችን ልጠራ እንጂ ጻድቃንን ልጠራ አልመጣሁም»', 'Metsague Day 27 — Healer of Souls Calls Sinners', 'ለበሽተኞች እንጂ ለጤነኞች ባለመድኃኒት አያስፈልጋቸውም', 'Those who are well have no need of a physician, but those who are sick'],
        ['JHN', 5, 5, 'መጻጕዕ (እሑድ 4) — የ38 ዓመቱን መጻጕዕ በቤተ ሳይዳ መፈወስ', 'Metsague (Sunday 4) — Healing at the Pool of Bethesda', '«ተነሣና አልጋህን ተሸክመህ ሂድ» (መጻጕዕ)', 'Rise, take up your bed, and walk'],
        // Week 5: ደብረ ዘይት (Days 29-35)
        ['PSA', 50, 50, 'ደብረ ዘይት ቀን 29 — «አምላካችን ይመጣል ዝምም አይልም»', 'Debre Zeyt Day 29 — Our God Comes and Does Not Keep Silence', 'በመንፈስና በምስጋና የሚቀርብ መሥዋዕት', 'Offer to God a sacrifice of thanksgiving and call upon Him'],
        ['ISA', 65, 65, 'ደብረ ዘይት ቀን 30 — አዲስ ሰማይና አዲስ ምድር', 'Debre Zeyt Day 30 — New Heavens and New Earth', 'የእግዚአብሔር የተስፋ መንግሥትና የጻድቃን ደስታ', 'Behold, I create new heavens and a new earth'],
        ['DAN', 7, 7, 'ደብረ ዘይት ቀን 31 — የዘመናት ሽማግሌና የፍርድ ዙፋን', 'Debre Zeyt Day 31 — Ancient of Days & Judgment Throne', 'በደመና ሰማይ የሚመጣው የሰው ልጅ የዘላለም መንግሥት', 'The Son of Man given dominion, glory, and an eternal kingdom'],
        ['JOL', 3, 3, 'ደብረ ዘይት ቀን 32 — አሕዛብ ሁሉ በፍርድ ሸለቆ የሚሰበሰቡበት ቀን', 'Debre Zeyt Day 32 — Gathering of All Nations Before the Lord', '«እግዚአብሔር ግን ለሕዝቡ መጠጊያ ይሆናል»', 'The Lord is a refuge for His people in the day of judgment'],
        ['MRK', 13, 13, 'ደብረ ዘይት ቀን 33 — «ቀኑንና ሰዓቱን አታውቁምና ትጉ ጸልዩም»', 'Debre Zeyt Day 33 — Watch and Pray, Be Ready', 'የጌታችን ምክር ስለ መንፈሳዊ ንቃትና ጽናት', 'Take heed, watch and pray; endure to the end'],
        ['1TH', 4, 5, 'ደብረ ዘይት ቀን 34 — የጌታ ዳግም ምጽአትና የብርሃን ልጆች (ምዕራፍ 4-5)', 'Debre Zeyt Day 34 — The Lord\'s Coming & Children of Light (Ch. 4–5)', '«እኛ ግን የቀን ልጆች ነንና እንንቃ በልብም እንጠንቀቅ»', 'Let us not sleep as others do, but watch and be sober'],
        ['MAT', 24, 24, 'ደብረ ዘይት (እሑድ 5) — በደብረ ዘይት ተራራ የተነገረ የምጽአት ምሥጢር', 'Debre Zeyt (Sunday 5) — Discourse on the Mount of Olives', '«መብረቅ ከምሥራቅ ወጥቶ እስከ ምዕራብ እንደሚታይ የሰው ልጅ መምጣት እንዲሁ ይሆናል» (ደብረ ዘይት)', 'As lightning shines from east to west, so will be the coming of the Son of Man'],
        // Week 6: ገብር ኄር (Days 36-42)
        ['PSA', 1, 1, 'ገብር ኄር ቀን 36 — በእግዚአብሔር ሕግ ደስ የሚለው ምስጉን ሰው', 'Gebre Her Day 36 — Blessedness of the Righteous', 'ቀንና ሌሊት በቃሉ የሚያሰላስል ፍሬያማ አገልጋይ', 'Like a tree planted by streams of water, yielding fruit in season'],
        ['PRO', 3, 3, 'ገብር ኄር ቀን 37 — «በፍጹም ልብህ በእግዚአብሔር ታመን»', 'Gebre Her Day 37 — Trust in the Lord With All Your Heart', 'መልካምነትንና እውነትን በአንገት ማሠር', 'Honor the Lord with your substance and walk safely'],
        ['LUK', 12, 12, 'ገብር ኄር ቀን 38 — «ወገባችሁ የታጠቀ መብራታችሁም የበራ ይሁን»', 'Gebre Her Day 38 — The Watchful & Faithful Steward', 'ጌታው ሲመጣ ሲተጋ የሚያገኘው ታማኝ አገልጋይ', 'Blessed are those servants whom the master finds awake'],
        ['LUK', 19, 19, 'ገብር ኄር ቀን 39 — የዘኬዎስ ንስሐና የአሥሩ ምናን ምሳሌ', 'Gebre Her Day 39 — Zacchaeus & Parable of the Ten Minas', 'በተሰጠን መክሊትና ጸጋ ትርፍ ማምጣት', 'Today salvation has come to this house; trade wisely until I come'],
        ['ROM', 12, 12, 'ገብር ኄር ቀን 40 — «ሰውነታችሁን ቅዱስና እግዚአብሔርን ደስ የሚያሰኝ መሥዋዕት አድርጋችሁ አቅርቡ»', 'Gebre Her Day 40 — Living Sacrifice & Service', 'በተሰጠን ጸጋ ወንድሞችን በትሕትናና በፍቅር ማገልገል', 'Do not be slothful in zeal; serve the Lord with a joyful spirit'],
        ['JAS', 2, 2, 'ገብር ኄር ቀን 41 — ከምግባር ጋር የተገለጠ ሕያው እምነት', 'Gebre Her Day 41 — Faith Proven Through Works of Mercy', '«ከሥራ የተለየ እምነት የሞተ ነው»', 'Show me your faith by your works of mercy and compassion'],
        ['MAT', 25, 25, 'ገብር ኄር (እሑድ 6) — «አንተ በጎ ታማኝም ባሪያ ወደ ጌታህ ደስታ ግባ»', 'Gebre Her (Sunday 6) — The Good & Faithful Servant', 'የ5ቱ መክሊትና የ10ሩ ቆነጃጅት ምሳሌ፤ «ከነዚህ ከታናናሾቹ ወንድሞቼ ለአንዱ ያደረጋችሁት ለእኔ አደረጋችሁት» (ገብር ኄር)', 'Well done, good and faithful servant; enter into the joy of your Lord'],
        // Week 7: ኒቆዲሞስ & ሆሣዕና (Days 43-49)
        ['EZK', 36, 36, 'ኒቆዲሞስ ቀን 43 — «አዲስ ልብና አዲስ መንፈስ በውስጣችሁ አኖራለሁ»', 'Nicodemus Day 43 — A New Heart and New Spirit', '«ጥሩ ውኃንም እረጭባችኋለሁ ትጠሩማላችሁ»', 'I will sprinkle clean water upon you and give you a new heart'],
        ['PSA', 27, 27, 'ኒቆዲሞስ ቀን 44 — «እግዚአብሔር ብርሃኔና መድኃኒቴ ነው»', 'Nicodemus Day 44 — The Lord Is My Light & Salvation', 'በጨለማ ጊዜ ወደ እግዚአብሔር ፊት መቅረብ (ዮሐ 3)', 'Your face, Lord, do I seek; be strong and wait for the Lord'],
        ['PSA', 42, 42, 'ኒቆዲሞስ ቀን 45 — «ዋላ ወደ ውኃ ምንጭ እንደሚናፍቅ ነፍሴ ወደ አንተ ትናፍቃለች»', 'Nicodemus Day 45 — My Soul Thirsts for the Living God', 'የነፍስ ናፍቆት ለሕያው አምላክ', 'Why are you cast down, O my soul? Hope in God!'],
        ['LUK', 15, 15, 'ኒቆዲሞስ ቀን 46 — የጠፋው ልጅ ወደ አባቱ መመለስ', 'Nicodemus Day 46 — The Prodigal Son & Father\'s Mercy', '«ልጄ ሞቶ ነበርና ሕያው ሆኗል፥ ጠፍቶም ነበር ተገኝቷል»', 'Joy in heaven over one sinner who repents'],
        ['ROM', 6, 6, 'ኒቆዲሞስ ቀን 47 — በጥምቀት ከክርስቶስ ጋር መቀበርና በአዲስ ሕይወት መነሣት', 'Nicodemus Day 47 — Buried & Raised in Newness of Life', '«በአዲስ ሕይወት እንድንመላለስ ከእርሱ ጋር ተቀበርን»', 'Walk in newness of life, dead to sin and alive to God'],
        ['JHN', 11, 11, 'ቀዳሜ አልዓዛር (ቀን 48) — «ትንሣኤና ሕይወት እኔ ነኝ»', 'Lazarus Saturday (Day 48) — I Am the Resurrection & the Life', 'ጌታችን አልዓዛርን ከአራት ቀን መቃብር ማስነሣቱ', 'Christ weeps at Bethany and raises Lazarus from the dead'],
        ['MAT', 21, 21, 'ሆሣዕና (እሑድ 7 / ቀን 49) — የክብር መግባት ወደ ኢየሩሳሌም', 'Hosanna (Palm Sunday / Day 49) — Entry into Jerusalem', '«ሆሣዕና ለዳዊት ልጅ! በጌታ ስም የሚመጣ የተባረከ ነው» (ሆሣዕና)', 'Hosanna to the Son of David! Blessed is He who comes in the name of the Lord'],
        // Week 8: ሰሞነ ሕማማት (Days 50-55, ending Holy Saturday)
        ['MRK', 11, 11, 'ሰሞነ ሕማማት ሰኞ (ቀን 50) — በለሲቱን መርገምና መቅደሱን ማጽዳት', 'Holy Monday (Day 50) — Fig Tree & Cleansing the Temple', 'ፍሬ የሌላትን በለስ ማድረቅና ለጸሎት መቅደስን ማጽዳት', 'Withering of the barren fig tree and cleansing the house of prayer'],
        ['LUK', 21, 21, 'ሰሞነ ሕማማት ማክሰኞ (ቀን 51) — «በመጽናታችሁ ነፍሳችሁን ታገኛላችሁ»', 'Holy Tuesday (Day 51) — Teaching in the Temple & Perseverance', 'የመበለቲቱ መባና በጸሎት መጽናት', 'The widow\'s mite and standing firm until redemption draws near'],
        ['MAT', 26, 26, 'ሰሞነ ሕማማት ረቡዕ (ቀን 52) — የቢታንያው ሽቶና የይሁዳ ምክክር', 'Holy Wednesday (Day 52) — Anointing at Bethany & Betrayal', 'ማርያም ሽቶ ማፍሰሷና የይሁዳ ክህደት', 'Precious ointment poured for His burial; covenant of betrayal'],
        ['JHN', 13, 14, 'ጸሎተ ሐሙስ (ቀን 53) — ሕጽበተ እግርና ምሥጢረ ቍርባን (ምዕራፍ 13-14)', 'Maundy Thursday (Day 53) — Washing Feet & Mystical Supper (Ch. 13–14)', 'የፍቅር ትእዛዝ፣ የእግር ማጠብ ትሕትናና የመንፈስ ቅዱስ ተስፋ', 'Jesus washes the disciples\' feet and promises the Comforter'],
        ['MAT', 27, 27, 'ስቅለተ ዓርብ (ቀን 54) — የጌታችን ሕማማትና በመስቀል ላይ መሞት', 'Good Friday (Day 54) — Crucifixion Upon the Cross', '«ተፈጸመ» — ስለ እኛ ኃጢአት የፈሰሰ ቅዱስ ደም', 'Our Lord suffers outside the gate and dies upon the Cross for our salvation'],
        ['PSA', 16, 16, 'ቀዳም ስዑር (ቀን 55) — በመቃብር ያረፈበት ቅዱስ ቀን', 'Holy Saturday (Day 55) — Rest in the Tomb & Joy Ahead', '«ነፍሴን በሲኦል አትተዋትምና፥ ቅዱስህንም መበስበስን ያይ ዘንድ አትተወውም»', 'In the silence of the tomb: You will not leave my soul in Sheol'],
      ]),
    ),

    // 8. ሰሞነ ሕማማት (Holy Passion Week - Hosanna to Easter, 8 Days)
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

    // 9. ጾመ ፍልሰታ (Fast of Assumption - Nehase 1 - 16, Last Fast in Liturgical Year)
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
          [2, 'ኦሪት ዘጸአት', 'Exodus', 3, 'በእሳት ነበልባል ሳትቃጠል የታየችው የሙሴ ዕፀ ጳጦስ ምሳሌ', 'The Burning Bush unconsumed by divine fire (Marian typology)', 'EXO'],
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

  static ReadingPlan? getPlanById(String id, {EthiopianDate? targetDate}) {
    if (id == 'apostles_fast') {
      return buildApostlesFastPlan(targetDate: targetDate);
    }
    for (final p in _staticPlans) {
      if (p.id == id) return p;
    }
    return null;
  }
}
