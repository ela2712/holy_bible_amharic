import '../models/reading_plan.dart';

class ReadingPlansData {
  ReadingPlansData._();

  static final List<ReadingPlan> allPlans = [
    // 1. መላው መጽሐፍ ቅዱስ በ365 ቀናት (Canonical 1-Year)
    ReadingPlan(
      id: 'canonical_365',
      title: 'መላው መጽሐፍ ቅዱስ በ365 ቀናት',
      subtitle: 'ኦሪት ዘፍጥረትን ጀምሮ እስከ የዮሐንስ ራእይ በዓመት ይጨርሱ',
      category: 'ዓመታዊ',
      totalDays: 365,
      coverIcon: 'auto_stories',
      badgeText: '365 ቀናት • 3 ምዕራፍ/ቀን',
      passages: List.generate(365, (i) {
        final day = i + 1;
        final startCh = (i * 3) + 1;
        final endCh = startCh + 2;
        return DailyReadingPassage(
          day: day,
          title: 'ቀን $day ንባብ',
          bookNumber: 1,
          bookName: 'መጽሐፍ ቅዱስ',
          startChapter: startCh,
          endChapter: endCh,
          description: 'ዕለታዊ የ3 ምዕራፍ ሥርዓተ ንባብ',
        );
      }),
    ),

    // 2. ሐዲስ ኪዳን በ90 ቀናት (New Testament in 90 Days)
    ReadingPlan(
      id: 'nt_90',
      title: 'ሐዲስ ኪዳን በ90 ቀናት',
      subtitle: '4ቱን ወንጌላት፣ የሐዋርያት ሥራና መልእክታትን በ3 ወራት ያንብቡ',
      category: 'ሐዲስ ኪዳን',
      totalDays: 90,
      coverIcon: 'menu_book',
      badgeText: '90 ቀናት • 2-3 ምዕራፍ/ቀን',
      passages: List.generate(90, (i) {
        final day = i + 1;
        String bookName = 'የማቴዎስ ወንጌል';
        int bookNum = 40;
        int ch = (day % 28) + 1;
        if (day > 28 && day <= 44) {
          bookName = 'የማርቆስ ወንጌል';
          bookNum = 41;
          ch = (day - 28);
        } else if (day > 44 && day <= 68) {
          bookName = 'የሉቃስ ወንጌል';
          bookNum = 42;
          ch = (day - 44);
        } else if (day > 68) {
          bookName = 'የዮሐንስ ወንጌል';
          bookNum = 43;
          ch = (day - 68);
        }
        return DailyReadingPassage(
          day: day,
          title: 'የሐዲስ ኪዳን ጉዞ — ቀን $day',
          bookNumber: bookNum,
          bookName: bookName,
          startChapter: ch,
          endChapter: ch,
          description: '$bookName ምዕራፍ $ch',
        );
      }),
    ),

    // 3. ሰሞነ ሕማማት (Holy Passion Week - 8 Days)
    ReadingPlan(
      id: 'passion_week',
      title: 'ሰሞነ ሕማማት (Holy Passion Week)',
      subtitle: 'ከሆሣዕና እስከ ትንሣኤ የክርስቶስን የመስቀል ጉዞ ይከተሉ',
      category: 'ጾምና በዓላት',
      totalDays: 8,
      coverIcon: 'church',
      badgeText: '8 ቀናት • ታላቅ በረከት',
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
          title: 'ማክሰኞ — የትምህርትና የጥያቄ ቀን',
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
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: 27,
          endChapter: 27,
          description: 'ክርስቶስ በመቃብር አደረ፤ በነፍስ ወደ ሲኦል ወርዶ ምርኮኞችን ነጻ አወጣ።',
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

    // 4. መጽሐፈ ምሳሌ በ31 ቀናት (Proverbs Wisdom - 31 Days)
    ReadingPlan(
      id: 'proverbs_31',
      title: 'መጽሐፈ ምሳሌ በ31 ቀናት',
      subtitle: 'በየቀኑ አንድ ምዕራፍ በማንበብ ሰማያዊ ጥበብን ገንዘብ ያድርጉ',
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

    // 5. መዝሙረ ዳዊት በ60 ቀናት (Psalms of David - 60 Days)
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
        final endCh = (((i + 1) * 150) ~/ 60);
        return DailyReadingPassage(
          day: day,
          title: 'የጸሎትና የምስጋና መዝሙር — ቀን $day',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          startChapter: startCh,
          endChapter: endCh.clamp(startCh, 150),
          description: 'መዝሙረ ዳዊት ምዕራፍ $startCh እስከ $endCh',
        );
      }),
    ),

    // 6. የዐቢይ ጾም ጉዞ (Great Lent - 55 Days)
    ReadingPlan(
      id: 'great_lent_55',
      title: 'የዐቢይ ጾም ጉዞ (Great Lent)',
      subtitle: 'ዘወረደ፣ ቅድስት፣ ምኩራብ፣ መጻጕዕ፣ ደብረ ዘይት፣ ገብር ኄር፣ ኒቆዲሞስና ሆሣዕና',
      category: 'ጾምና በዓላት',
      totalDays: 55,
      coverIcon: 'spa',
      badgeText: '55 ቀናት • ንስሐና ጾም',
      passages: List.generate(55, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'የዐቢይ ጾም ጸሎትና ንባብ — ቀን $day',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          startChapter: ((day % 28) + 1),
          endChapter: ((day % 28) + 1),
          description: 'የንስሐና የጸሎት ወቅት መንፈሳዊ ንባብ',
        );
      }),
    ),

    // 7. ጾመ ፍልሰታ (Fast of Assumption - 16 Days)
    ReadingPlan(
      id: 'filseta_16',
      title: 'ጾመ ፍልሰታ (Fast of the Assumption)',
      subtitle: 'ከነሐሴ 1 እስከ 16 የእመቤታችንን በረከት የሚዘክሩ ንባባት',
      category: 'ጾምና በዓላት',
      totalDays: 16,
      coverIcon: 'favorite',
      badgeText: '16 ቀናት • በረከተ እመቤታችን',
      passages: const [
        DailyReadingPassage(
          day: 1,
          title: 'የብሥራቷ ዜና',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          startChapter: 1,
          endChapter: 1,
          description: 'መልአኩ ቅዱስ ገብርኤል ለእመቤታችን ያበሠረው ቃል',
        ),
        DailyReadingPassage(
          day: 2,
          title: 'የማርያም ምስጋና (ማግኒፊካት)',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          startChapter: 1,
          endChapter: 1,
          description: '«ነፍሴ ጌታን ታከብረዋለች፤ መንፈሴም በአምላኬ በመድኃኒቴ ሐሴት ታደርጋለች።»',
        ),
        DailyReadingPassage(
          day: 3,
          title: 'የልደቱ ምሥጢር በቤተልሔም',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          startChapter: 2,
          endChapter: 2,
          description: 'ክርስቶስ በድንግልና ተወልዶ በግርግም መተኛቱ',
        ),
        DailyReadingPassage(
          day: 4,
          title: 'በቃና ዘገሊላ የመጀመሪያው ተአምር',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          startChapter: 2,
          endChapter: 2,
          description: '«የሚላችሁን ሁሉ አድርጉ» — የእናቱ አማላጅነት በሠርግ ቤት',
        ),
        DailyReadingPassage(
          day: 5,
          title: 'በመስቀሉ ሥር',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          startChapter: 19,
          endChapter: 19,
          description: '«እነኋት እናትህ» — ለሰው ልጆች ሁሉ የተሰጠች እናት',
        ),
      ],
    ),

    // 8. የክርስቶስ ተአምራትና ምሳሌዎች (Miracles of Christ - 21 Days)
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
          startChapter: (day % 21) + 1,
          endChapter: (day % 21) + 1,
          description: 'የክርስቶስ ድንቅ የማዳን ሥራና ተአምራት',
        );
      }),
    ),

    // 9. የእምነትና የጽናት ቃላት (Faith & Endurance - 30 Days)
    ReadingPlan(
      id: 'faith_30',
      title: 'የእምነትና የጽናት ቃላት (Faith & Courage)',
      subtitle: 'በፈተና ጊዜ ብርታትና ሰላም የሚሰጡ የተመረጡ ጥቅሶች',
      category: 'ጥበብና መዝሙር',
      totalDays: 30,
      coverIcon: 'shield',
      badgeText: '30 ቀናት • ጽናትና እምነት',
      passages: List.generate(30, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'የብርታት ቃል — ቀን $day',
          bookNumber: 45,
          bookName: 'ወደ ሮሜ ሰዎች',
          startChapter: (day % 16) + 1,
          endChapter: (day % 16) + 1,
          description: 'በክርስቶስ ፍቅር ድል አድራጊዎች ነን',
        );
      }),
    ),

    // 10. የትንቢተ ነቢያት ጉዞ (Messianic Prophecies - 40 Days)
    ReadingPlan(
      id: 'prophecies_40',
      title: 'የነቢያት ትንቢት ስለ ክርስቶስ',
      subtitle: 'ኢሳይያስ፣ ዳንኤል፣ ሚክያስና ዘካርያስ ስለ መድኃኔዓለም የተናገሩት',
      category: 'ዓመታዊ',
      totalDays: 40,
      coverIcon: 'visibility',
      badgeText: '40 ቀናት • ትንቢት',
      passages: List.generate(40, (i) {
        final day = i + 1;
        return DailyReadingPassage(
          day: day,
          title: 'የመሲሑ ትንቢት — ቀን $day',
          bookNumber: 23,
          bookName: 'ትንቢተ ኢሳይያስ',
          startChapter: (day % 66) + 1,
          endChapter: (day % 66) + 1,
          description: 'ስለ ክርስቶስ መወለድ፣ መከራና ክብር የተነገረ ትንቢት',
        );
      }),
    ),
  ];

  static ReadingPlan? getPlanById(String id) {
    for (final p in allPlans) {
      if (p.id == id) return p;
    }
    return null;
  }
}
