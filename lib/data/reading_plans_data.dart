import '../models/reading_plan.dart';

class _BookDef {
  final int num;
  final String name;
  final int chapters;
  const _BookDef(this.num, this.name, this.chapters);
}

class ReadingPlansData {
  ReadingPlansData._();

  static const List<_BookDef> _otBooks = [
    _BookDef(1, 'ኦሪት ዘፍጥረት', 50),
    _BookDef(2, 'ኦሪት ዘጸአት', 40),
    _BookDef(3, 'ኦሪት ዘሌዋውያን', 27),
    _BookDef(4, 'ኦሪት ዘኍልቍ', 36),
    _BookDef(5, 'ኦሪት ዘዳግም', 34),
    _BookDef(6, 'መጽሐፈ ኢያሱ ወልደ ነዌ', 24),
    _BookDef(7, 'መጽሐፈ መሳፍንት', 21),
    _BookDef(8, 'መጽሐፈ ሩት', 4),
    _BookDef(9, 'መጽሐፈ ሳሙኤል ቀዳማዊ', 31),
    _BookDef(10, 'መጽሐፈ ሳሙኤል ካልዕ', 24),
    _BookDef(11, 'መጽሐፈ ነገሥት ቀዳማዊ', 22),
    _BookDef(12, 'መጽሐፈ ነገሥት ካልዕ', 25),
    _BookDef(13, 'መጽሐፈ ዜና መዋዕል ቀዳማዊ', 29),
    _BookDef(14, 'መጽሐፈ ዜና መዋዕል ካልዕ', 36),
    _BookDef(15, 'መጽሐፈ ዕዝራ', 10),
    _BookDef(16, 'መጽሐፈ ነህምያ', 13),
    _BookDef(17, 'መጽሐፈ አስቴር', 10),
    _BookDef(18, 'መጽሐፈ ኢዮብ', 42),
    _BookDef(19, 'መዝሙረ ዳዊት', 150),
    _BookDef(20, 'መጽሐፈ ምሳሌ', 31),
    _BookDef(21, 'መጽሐፈ መክብብ', 12),
    _BookDef(22, 'መኃልየ መኃልይ ዘሰሎሞን', 8),
    _BookDef(23, 'ትንቢተ ኢሳይያስ', 66),
    _BookDef(24, 'ትንቢተ ኤርምያስ', 52),
    _BookDef(25, 'ሰቆቃወ ኤርምያስ', 5),
    _BookDef(26, 'ትንቢተ ሕዝቅኤል', 48),
    _BookDef(27, 'ትንቢተ ዳንኤል', 12),
    _BookDef(28, 'ትንቢተ ሆሴዕ', 14),
    _BookDef(29, 'ትንቢተ ዮኤል', 3),
    _BookDef(30, 'ትንቢተ አሞጽ', 9),
    _BookDef(31, 'ትንቢተ አብድዩ', 1),
    _BookDef(32, 'ትንቢተ ዮናስ', 4),
    _BookDef(33, 'ትንቢተ ሚክያስ', 7),
    _BookDef(34, 'ትንቢተ ናሆም', 3),
    _BookDef(35, 'ትንቢተ ዕንባቆም', 3),
    _BookDef(36, 'ትንቢተ ሶፎንያስ', 3),
    _BookDef(37, 'ትንቢተ ሐጌ', 2),
    _BookDef(38, 'ትንቢተ ዘካርያስ', 14),
    _BookDef(39, 'ትንቢተ ሚልክያስ', 4),
  ];

  static const List<_BookDef> _ntBooks = [
    _BookDef(40, 'የማቴዎስ ወንጌል', 28),
    _BookDef(41, 'የማርቆስ ወንጌል', 16),
    _BookDef(42, 'የሉቃስ ወንጌል', 24),
    _BookDef(43, 'የዮሐንስ ወንጌል', 21),
    _BookDef(44, 'የሐዋርያት ሥራ', 28),
    _BookDef(45, 'ወደ ሮሜ ሰዎች', 16),
    _BookDef(46, 'ወደ ቆሮንቶስ ሰዎች 1ኛ', 16),
    _BookDef(47, 'ወደ ቆሮንቶስ ሰዎች 2ኛ', 13),
    _BookDef(48, 'ወደ ገላትያ ሰዎች', 6),
    _BookDef(49, 'ወደ ኤፌሶን ሰዎች', 6),
    _BookDef(50, 'ወደ ፊልጵስዩስ ሰዎች', 4),
    _BookDef(51, 'ወደ ቆላስይስ ሰዎች', 4),
    _BookDef(52, 'ወደ ተሰሎንቄ ሰዎች 1ኛ', 5),
    _BookDef(53, 'ወደ ተሰሎንቄ ሰዎች 2ኛ', 3),
    _BookDef(54, 'ወደ ጢሞቴዎስ 1ኛ', 6),
    _BookDef(55, 'ወደ ጢሞቴዎስ 2ኛ', 4),
    _BookDef(56, 'ወደ ቲቶ', 3),
    _BookDef(57, 'ወደ ፊልሞና', 1),
    _BookDef(58, 'ወደ ዕብራውያን', 13),
    _BookDef(59, 'የያዕቆብ መልእክት', 5),
    _BookDef(60, 'የጴጥሮስ መልእክት 1ኛ', 5),
    _BookDef(61, 'የጴጥሮስ መልእክት 2ኛ', 3),
    _BookDef(62, 'የዮሐንስ መልእክት 1ኛ', 5),
    _BookDef(63, 'የዮሐንስ መልእክት 2ኛ', 1),
    _BookDef(64, 'የዮሐንስ መልእክት 3ኛ', 1),
    _BookDef(65, 'የይሁዳ መልእክት', 1),
    _BookDef(66, 'የዮሐንስ ራእይ', 22),
  ];

  static const List<_BookDef> _chronologicalOrder = [
    _BookDef(1, 'ኦሪት ዘፍጥረት', 50),
    _BookDef(18, 'መጽሐፈ ኢዮብ', 42),
    _BookDef(2, 'ኦሪት ዘጸአት', 40),
    _BookDef(3, 'ኦሪት ዘሌዋውያን', 27),
    _BookDef(4, 'ኦሪት ዘኍልቍ', 36),
    _BookDef(5, 'ኦሪት ዘዳግም', 34),
    _BookDef(6, 'መጽሐፈ ኢያሱ ወልደ ነዌ', 24),
    _BookDef(7, 'መጽሐፈ መሳፍንት', 21),
    _BookDef(8, 'መጽሐፈ ሩት', 4),
    _BookDef(9, 'መጽሐፈ ሳሙኤል ቀዳማዊ', 31),
    _BookDef(10, 'መጽሐፈ ሳሙኤል ካልዕ', 24),
    _BookDef(19, 'መዝሙረ ዳዊት', 150),
    _BookDef(11, 'መጽሐፈ ነገሥት ቀዳማዊ', 22),
    _BookDef(20, 'መጽሐፈ ምሳሌ', 31),
    _BookDef(21, 'መጽሐፈ መክብብ', 12),
    _BookDef(22, 'መኃልየ መኃልይ ዘሰሎሞን', 8),
    _BookDef(12, 'መጽሐፈ ነገሥት ካልዕ', 25),
    _BookDef(23, 'ትንቢተ ኢሳይያስ', 66),
    _BookDef(24, 'ትንቢተ ኤርምያስ', 52),
    _BookDef(26, 'ትንቢተ ሕዝቅኤል', 48),
    _BookDef(27, 'ትንቢተ ዳንኤል', 12),
    _BookDef(15, 'መጽሐፈ ዕዝራ', 10),
    _BookDef(16, 'መጽሐፈ ነህምያ', 13),
    _BookDef(17, 'መጽሐፈ አስቴር', 10),
    _BookDef(41, 'የማርቆስ ወንጌል', 16),
    _BookDef(40, 'የማቴዎስ ወንጌል', 28),
    _BookDef(42, 'የሉቃስ ወንጌል', 24),
    _BookDef(43, 'የዮሐንስ ወንጌል', 21),
    _BookDef(44, 'የሐዋርያት ሥራ', 28),
    _BookDef(45, 'ወደ ሮሜ ሰዎች', 16),
    _BookDef(46, 'ወደ ቆሮንቶስ ሰዎች 1ኛ', 16),
    _BookDef(58, 'ወደ ዕብራውያን', 13),
    _BookDef(66, 'የዮሐንስ ራእይ', 22),
  ];

  static List<DailyReadingPassage> _distributeBooksAcrossDays({
    required List<_BookDef> books,
    required int totalDays,
    required String titlePrefix,
    required String descPrefix,
  }) {
    final flatChapters = <Map<String, dynamic>>[];
    for (final b in books) {
      for (int ch = 1; ch <= b.chapters; ch++) {
        flatChapters.add({
          'bookNum': b.num,
          'bookName': b.name,
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
      final bookName = first['bookName'] as String;
      final startCh = first['chapter'] as int;

      int endCh = startCh;
      for (int k = startIdx; k <= endIdx; k++) {
        if (flatChapters[k]['bookNum'] == bookNum) {
          endCh = flatChapters[k]['chapter'] as int;
        }
      }

      passages.add(
        DailyReadingPassage(
          day: day,
          title: '$titlePrefix — ቀን $day',
          bookNumber: bookNum,
          bookName: bookName,
          startChapter: startCh,
          endChapter: endCh,
          description: startCh == endCh
              ? '$descPrefix • $bookName ምዕራፍ $startCh'
              : '$descPrefix • $bookName ምዕራፍ $startCh እስከ $endCh',
        ),
      );
    }
    return passages;
  }

  /// Dynamically builds a custom reading plan for user-selected scope & duration
  static ReadingPlan buildCustomPlan({
    required String id,
    required String title,
    required String scopeKey, // 'GOSPELS', 'NT', 'PSALMS_WISDOM', 'PENTATEUCH', 'OT', 'FULL'
    required int totalDays,
  }) {
    List<_BookDef> selectedBooks;
    String category;
    String subtitle;

    switch (scopeKey) {
      case 'GOSPELS':
        selectedBooks = _ntBooks.sublist(0, 4);
        category = 'ሐዲስ ኪዳን';
        subtitle = 'የአራቱ ወንጌላት የግል የንባብ ዕቅድ ($totalDays ቀናት)';
        break;
      case 'NT':
        selectedBooks = _ntBooks;
        category = 'ሐዲስ ኪዳን';
        subtitle = 'መላው ሐዲስ ኪዳን በ$totalDays ቀናት';
        break;
      case 'PSALMS_WISDOM':
        selectedBooks = _otBooks.where((b) => b.num >= 18 && b.num <= 22).toList();
        category = 'ጥበብና መዝሙር';
        subtitle = 'መዝሙረ ዳዊትና የጥበብ መጻሕፍት በ$totalDays ቀናት';
        break;
      case 'PENTATEUCH':
        selectedBooks = _otBooks.sublist(0, 5);
        category = 'ዓመታዊ';
        subtitle = 'አምስቱ የሙሴ የኦሪት መጻሕፍት በ$totalDays ቀናት';
        break;
      case 'OT':
        selectedBooks = _otBooks;
        category = 'ዓመታዊ';
        subtitle = 'የብሉይ ኪዳን መጻሕፍት በ$totalDays ቀናት';
        break;
      case 'FULL':
      default:
        selectedBooks = [..._otBooks, ..._ntBooks];
        category = 'ዓመታዊ';
        subtitle = 'ሙሉ መጽሐፍ ቅዱስ በ$totalDays ቀናት የግል ዕቅድ';
        break;
    }

    return ReadingPlan(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      totalDays: totalDays,
      coverIcon: 'auto_stories',
      badgeText: '$totalDays ቀናት • የግል ዕቅድ',
      passages: _distributeBooksAcrossDays(
        books: selectedBooks,
        totalDays: totalDays,
        titlePrefix: title,
        descPrefix: 'የግል ንባብ ዕቅድ',
      ),
    );
  }

  static final List<ReadingPlan> allPlans = [
    // 1. መላው መጽሐፍ ቅዱስ በ365 ቀናት (Canonical 1-Year - Accurate Mapping)
    ReadingPlan(
      id: 'canonical_365',
      title: 'መላው መጽሐፍ ቅዱስ በ365 ቀናት',
      subtitle: 'ከኦሪት ዘፍጥረት እስከ የዮሐንስ ራእይ በቅደም ተከተል በዓመት ይጨርሱ',
      category: 'ዓመታዊ',
      totalDays: 365,
      coverIcon: 'auto_stories',
      badgeText: '365 ቀናት • ~3 ምዕራፍ/ቀን',
      passages: _distributeBooksAcrossDays(
        books: [..._otBooks, ..._ntBooks],
        totalDays: 365,
        titlePrefix: 'ዓመታዊ ቀኖናዊ ንባብ',
        descPrefix: 'ዕለታዊ የመጽሐፍ ቅዱስ ጉዞ',
      ),
    ),

    // 2. የታሪክ ቅደም ተከተል ዕቅድ (Chronological Bible Plan - 365 Days)
    ReadingPlan(
      id: 'chronological_365',
      title: 'የታሪክ ቅደም ተከተል ዕቅድ (Chronological)',
      subtitle: 'መጽሐፍ ቅዱስን ታሪኮቹ በተፈጸሙበት የዘመን ቅደም ተከተል በዓመት ያንብቡ',
      category: 'ዓመታዊ',
      totalDays: 365,
      coverIcon: 'visibility',
      badgeText: '365 ቀናት • ታሪካዊ ቅደም ተከተል',
      passages: _distributeBooksAcrossDays(
        books: _chronologicalOrder,
        totalDays: 365,
        titlePrefix: 'የታሪክ ቅደም ተከተል',
        descPrefix: 'በዘመን ቅደም ተከተል የተዘጋጀ ንባብ',
      ),
    ),

    // 3. የሮበርት ማክቼይን ዕቅድ (M'Cheyne Classical Plan - 180 Days Intensive)
    ReadingPlan(
      id: 'mcheyne_180',
      title: 'የብሉይና ሐዲስ ኪዳን ጥምር ዕቅድ (M\'Cheyne)',
      subtitle: 'ከብሉይ ኪዳን፣ ከመዝሙራትና ከሐዲስ ኪዳን የተቀናጀ የጥናት ጉዞ',
      category: 'ዓመታዊ',
      totalDays: 180,
      coverIcon: 'auto_stories',
      badgeText: '180 ቀናት • ጥምር ጥናት',
      passages: _distributeBooksAcrossDays(
        books: [..._ntBooks, ..._otBooks.sublist(0, 20)],
        totalDays: 180,
        titlePrefix: 'ጥምር መንፈሳዊ ንባብ',
        descPrefix: 'የብሉይና ሐዲስ ኪዳን ስምምነት',
      ),
    ),

    // 4. ሐዲስ ኪዳን በ90 ቀናት (New Testament in 90 Days)
    ReadingPlan(
      id: 'nt_90',
      title: 'ሐዲስ ኪዳን በ90 ቀናት',
      subtitle: '4ቱን ወንጌላት፣ የሐዋርያት ሥራ፣ መልእክታትና ራእይን በ3 ወራት ይጨርሱ',
      category: 'ሐዲስ ኪዳን',
      totalDays: 90,
      coverIcon: 'menu_book',
      badgeText: '90 ቀናት • 3 ምዕራፍ/ቀን',
      passages: _distributeBooksAcrossDays(
        books: _ntBooks,
        totalDays: 90,
        titlePrefix: 'የሐዲስ ኪዳን ጉዞ',
        descPrefix: 'የወንጌልና የሐዋርያት ትምህርት',
      ),
    ),

    // 5. አራቱ ወንጌላት በ30 ቀናት (The Four Gospels in 30 Days)
    ReadingPlan(
      id: 'gospels_30',
      title: 'አራቱ ወንጌላት በ30 ቀናት',
      subtitle: 'የጌታችን የኢየሱስ ክርስቶስን ሕይወት፣ ትምህርት፣ መስቀልና ትንሣኤ በ1 ወር ያንብቡ',
      category: 'ሐዲስ ኪዳን',
      totalDays: 30,
      coverIcon: 'menu_book',
      badgeText: '30 ቀናት • ማቴ፣ ማር፣ ሉቃ፣ ዮሐ',
      passages: _distributeBooksAcrossDays(
        books: _ntBooks.sublist(0, 4),
        totalDays: 30,
        titlePrefix: 'የወንጌል ብርሃን',
        descPrefix: 'የአራቱ ወንጌላት ንባብ',
      ),
    ),

    // 6. ሰሞነ ሕማማት (Holy Passion Week - 8 Days)
    ReadingPlan(
      id: 'passion_week',
      title: 'ሰሞነ ሕማማት (Holy Passion Week)',
      subtitle: 'ከሆሣዕና እስከ ትንሣኤ የክርስቶስን የመስቀል ጉዞና የግብረ ሕማማት ምንባባት ይከተሉ',
      category: 'ጾምና በዓላት',
      totalDays: 8,
      coverIcon: 'church',
      badgeText: '8 ቀናት • ግብረ ሕማማት',
      passages: const [
        DailyReadingPassage(
          day: 1,
          title: 'ሆሣዕና — የክብር ግስጋሴ ወደ ኢየሩሳሌም',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: 21,
          endChapter: 21,
          description: 'ጌታችን በአህያ ውርንጭላ ላይ ተቀምጦ ወደ ኢየሩሳሌም በክብር መግባቱ።',
        ),
        DailyReadingPassage(
          day: 2,
          title: 'ሰኞ — በለሲቱን መርገም እና ቤተ መቅደስን ማጽዳት',
          bookNumber: 41,
          bookName: 'የማርቆስ ወንጌል',
          startChapter: 11,
          endChapter: 11,
          description: 'ፍሬ የሌላትን በለስ ማድረቅና ቤተ መቅደስን ከነጋዴዎች ማጽዳት።',
        ),
        DailyReadingPassage(
          day: 3,
          title: 'ማክሰኞ — የትምህርትና የጥያቄ ቀን (ደብረ ዘይት)',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: 24,
          endChapter: 25,
          description: 'የዓለም ፍጻሜ ምልክቶችና የ10ሩ ቆነጃጅት ምሳሌ።',
        ),
        DailyReadingPassage(
          day: 4,
          title: 'ረቡዕ — የምክክርና የሽቶ ቀን',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: 26,
          endChapter: 26,
          description: 'ማርያም የከበረ ሽቶ በጌታ ራስ ላይ ማፍሰሷና የአስቆሮቱ ይሁዳ ክህደት።',
        ),
        DailyReadingPassage(
          day: 5,
          title: 'ጸሎተ ሐሙስ — ሕጽበተ እግርና ምሥጢረ ቍርባን',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          startChapter: 13,
          endChapter: 14,
          description: 'ጌታችን የደቀመዛሙርቱን እግር ማጠቡና ቅዱስ ሥጋውንና ደሙን መስጠቱ።',
        ),
        DailyReadingPassage(
          day: 6,
          title: 'ስቅለተ ዓርብ — የድኅነት ቀን በመስቀል ላይ',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: 27,
          endChapter: 27,
          description: 'ጌታችን መድኃኒታችን ኢየሱስ ክርስቶስ ስለ እኛ ኃጢአት በመስቀል ላይ መሞቱ።',
        ),
        DailyReadingPassage(
          day: 7,
          title: 'ቀዳም ስዑር — በመቃብር ያረፈበት ቀን',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          startChapter: 16,
          endChapter: 16,
          description: '«ነፍሴን በሲኦል አትተዋትምና፥ ቅዱስህንም መበስበስን ያይ ዘንድ አትተወውም።»',
        ),
        DailyReadingPassage(
          day: 8,
          title: 'ትንሣኤ — ሞትን ድል አድርጎ ተነሣ!',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          startChapter: 20,
          endChapter: 21,
          description: 'ክርስቶስ ተነሥቷል! በሞቱ ሞትን ሻረልን፤ ዘላለማዊ ሕይወትን ሰጠን።',
        ),
      ],
    ),

    // 7. የዐቢይ ጾም 8ቱ ሳምንታትና ዕለታዊ ጉዞ (Great Lent - 55 Days)
    ReadingPlan(
      id: 'great_lent_55',
      title: 'የዐቢይ ጾም ጉዞ (Great Lent - 55 Days)',
      subtitle: 'ዘወረደ፣ ቅድስት፣ ምኩራብ፣ መጻጕዕ፣ ደብረ ዘይት፣ ገብር ኄር፣ ኒቆዲሞስና ሆሣዕና',
      category: 'ጾምና በዓላት',
      totalDays: 55,
      coverIcon: 'spa',
      badgeText: '55 ቀናት • ጾመ ሁዳዴ',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(40, 'የማቴዎስ ወንጌል', 28),
          const _BookDef(43, 'የዮሐንስ ወንጌል', 21),
          const _BookDef(59, 'የያዕቆብ መልእክት', 5),
        ],
        totalDays: 55,
        titlePrefix: 'የዐቢይ ጾም ምንባብ',
        descPrefix: 'የንስሐ፣ የጸሎትና የምጽዋት ጉዞ',
      ),
    ),

    // 8. ጾመ ነቢያት / የገና ጾም (Fast of the Prophets / Advent - 43 Days)
    ReadingPlan(
      id: 'advent_prophets_43',
      title: 'ጾመ ነቢያት (Fast of the Prophets - 43 Days)',
      subtitle: 'ከኅዳር 15 እስከ ልደተ ክርስቶስ የነቢያት ትንቢትና የልደቱ ምሥጢር ምንባባት',
      category: 'ጾምና በዓላት',
      totalDays: 43,
      coverIcon: 'church',
      badgeText: '43 ቀናት • ጾመ ነቢያት',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(23, 'ትንቢተ ኢሳይያስ', 66),
          const _BookDef(33, 'ትንቢተ ሚክያስ', 7),
          const _BookDef(42, 'የሉቃስ ወንጌል', 2),
        ],
        totalDays: 43,
        titlePrefix: 'ጾመ ነቢያት',
        descPrefix: 'ስለ አማኑኤል ልደት የተነገረ ትንቢት',
      ),
    ),

    // 9. ጾመ ፍልሰታ (Fast of Assumption - 16 Days)
    ReadingPlan(
      id: 'filseta_16',
      title: 'ጾመ ፍልሰታ (Fast of the Assumption)',
      subtitle: 'ከነሐሴ 1 እስከ 16 የእመቤታችንን ነገረ ማርያምና የወንጌል ምንባባት',
      category: 'ጾምና በዓላት',
      totalDays: 16,
      coverIcon: 'favorite',
      badgeText: '16 ቀናት • ነሐሴ 1-16',
      passages: List.generate(16, (i) {
        final day = i + 1;
        const refs = [
          [42, 'የሉቃስ ወንጌል', 1, 'የመልአኩ ቅዱስ ገብርኤል ብሥራትና የእመቤታችን ትሕትና'],
          [42, 'የሉቃስ ወንጌል', 2, 'የጌታችን ልደት በቤተልሔምና የእረኞች ምስጋና'],
          [43, 'የዮሐንስ ወንጌል', 2, 'በቃና ዘገሊላ የተደረገው የመጀመሪያው ተአምር'],
          [43, 'የዮሐንስ ወንጌል', 19, 'በመስቀሉ ሥር ለዮሐንስ የተሰጠች የሁላችን እናት'],
          [44, 'የሐዋርያት ሥራ', 1, 'ከሐዋርያት ጋር በአንድ ልብ በጸሎት መትጋቷ'],
          [19, 'መዝሙረ ዳዊት', 45, '«ንግሥቲቱ በቀኝህ ትቆማለች» — የዳዊት መዝሙር'],
          [19, 'መዝሙረ ዳዊት', 87, '«መሠረቶቹ በተቀደሱ ተራሮች ናቸው»'],
          [19, 'መዝሙረ ዳዊት', 132, '«እግዚአብሔር ጽዮንን መርጦአታልና፥ ማደሪያውም ትሆን ዘንድ ወድዷታል»'],
          [23, 'ትንቢተ ኢሳይያስ', 7, '«እነሆ፥ ድንግል ትፀንሳለች ልጅም ትወልዳለች»'],
          [26, 'ትንቢተ ሕዝቅኤል', 44, 'የተዘጋችው የምሥራቅ ደጅ ምሳሌ'],
          [22, 'መኃልየ መኃልይ ዘሰሎሞን', 4, '«ወዳጄ ሆይ፥ ሁለንተናሽ ውብ ነው፥ ነውርም የለብሽም»'],
          [20, 'መጽሐፈ ምሳሌ', 8, 'የሰማያዊት ጥበብ ምስጋና'],
          [20, 'መጽሐፈ ምሳሌ', 31, '«ልባም ሴትን ማን ሊያገኛት ይችላል?»'],
          [48, 'ወደ ገላትያ ሰዎች', 4, '«የዘመኑ ፍጻሜ በደረሰ ጊዜ እግዚአብሔር ከሴት የተወለደውን ልጁን ላከ»'],
          [66, 'የዮሐንስ ራእይ', 12, 'ፀሐይን ተጎናጽፋ ጨረቃ ከእግሮቿ በታች ያላት ሴት'],
          [19, 'መዝሙረ ዳዊት', 150, 'የፍልሰታ ፍጻሜና የምስጋና መዝሙር'],
        ];
        final r = refs[i];
        return DailyReadingPassage(
          day: day,
          title: 'ጾመ ፍልሰታ — ቀን $day',
          bookNumber: r[0] as int,
          bookName: r[1] as String,
          startChapter: r[2] as int,
          endChapter: r[2] as int,
          description: r[3] as String,
        );
      }),
    ),

    // 10. መጽሐፈ ምሳሌ በ31 ቀናት (Proverbs Wisdom - 31 Days)
    ReadingPlan(
      id: 'proverbs_31',
      title: 'መጽሐፈ ምሳሌ በ31 ቀናት',
      subtitle: 'በየቀኑ አንድ ምዕራፍ በማንበብ ሰማያዊ ጥበብንና ማስተዋልን ገንዘብ ያድርጉ',
      category: 'ጥበብና መዝሙር',
      totalDays: 31,
      coverIcon: 'lightbulb',
      badgeText: '31 ቀናት • 1 ምዕራፍ/ቀን',
      passages: List.generate(31, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'የጥበብ ቃል — ቀን $day',
          bookNumber: 20,
          bookName: 'መጽሐፈ ምሳሌ',
          startChapter: day,
          endChapter: day,
          description: 'መጽሐፈ ምሳሌ ምዕራፍ $day ንባብ',
        );
      }),
    ),

    // 11. መዝሙረ ዳዊት በ60 ቀናት (Psalms of David - 60 Days)
    ReadingPlan(
      id: 'psalms_60',
      title: 'መዝሙረ ዳዊት በ60 ቀናት',
      subtitle: 'የዳዊት 150 መዝሙራትን በጸሎትና በምስጋና መንፈስ ያንብቡ',
      category: 'ጥበብና መዝሙር',
      totalDays: 60,
      coverIcon: 'music_note',
      badgeText: '60 ቀናት • 2-3 መዝሙር/ቀን',
      passages: List.generate(60, (i) {
        final day = i + 1;
        final startCh = ((i * 150) ~/ 60) + 1;
        final endCh = (((i + 1) * 150) ~/ 60).clamp(startCh, 150);
        return DailyReadingPassage(
          day: day,
          title: 'የጸሎትና የምስጋና መዝሙር — ቀን $day',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          startChapter: startCh,
          endChapter: endCh,
          description: 'መዝሙረ ዳዊት ምዕራፍ $startCh እስከ $endCh',
        );
      }),
    ),

    // 12. የክርስቶስ ተአምራትና ምሳሌዎች (Miracles & Parables - 21 Days)
    ReadingPlan(
      id: 'miracles_21',
      title: 'የክርስቶስ ተአምራትና ምሳሌዎች',
      subtitle: 'ዕውራንን ማብራት፣ አልዓዛርን ማስነሣትና የጠፋው ልጅ ምሳሌ',
      category: 'ሐዲስ ኪዳን',
      totalDays: 21,
      coverIcon: 'stars',
      badgeText: '21 ቀናት • ተአምራት',
      passages: List.generate(21, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'ተአምረ ኢየሱስ — ቀን $day',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          startChapter: day,
          endChapter: day,
          description: 'የዮሐንስ ወንጌል ምዕራፍ $day • የክርስቶስ የማዳን ሥራና ምሥጢራዊ ትምህርት',
        );
      }),
    ),

    // 13. የእምነትና የጽናት ቃላት (Faith & Endurance - 30 Days)
    ReadingPlan(
      id: 'faith_30',
      title: 'የእምነትና የጽናት ቃላት (Faith & Courage)',
      subtitle: 'በፈተና ጊዜ ብርታትና ሰላም የሚሰጡ የሐዋርያት መልእክታት',
      category: 'ጥበብና መዝሙር',
      totalDays: 30,
      coverIcon: 'shield',
      badgeText: '30 ቀናት • ጽናትና እምነት',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(45, 'ወደ ሮሜ ሰዎች', 16),
          const _BookDef(58, 'ወደ ዕብራውያን', 13),
          const _BookDef(59, 'የያዕቆብ መልእክት', 5),
        ],
        totalDays: 30,
        titlePrefix: 'የእምነትና የጽናት ቃል',
        descPrefix: 'በእምነት መጽናትና መንፈሳዊ ብርታት',
      ),
    ),

    // 14. የነቢያት ትንቢት ስለ ክርስቶስ (Messianic Prophecies - 40 Days)
    ReadingPlan(
      id: 'prophecies_40',
      title: 'የነቢያት ትንቢት ስለ ክርስቶስ',
      subtitle: 'ኢሳይያስ፣ ዳንኤል፣ ሚክያስና ዘካርያስ ስለ መድኃኔዓለም የተናገሩት',
      category: 'ዓመታዊ',
      totalDays: 40,
      coverIcon: 'visibility',
      badgeText: '40 ቀናት • ትንቢተ ነቢያት',
      passages: _distributeBooksAcrossDays(
        books: [
          const _BookDef(23, 'ትንቢተ ኢሳይያስ', 66),
          const _BookDef(27, 'ትንቢተ ዳንኤል', 12),
          const _BookDef(38, 'ትንቢተ ዘካርያስ', 14),
        ],
        totalDays: 40,
        titlePrefix: 'የመሲሑ ትንቢት',
        descPrefix: 'ስለ ክርስቶስ መወለድ፣ መከራና ክብር የተነገረ ትንቢት',
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
