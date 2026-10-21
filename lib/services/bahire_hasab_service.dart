class EthiopianDate {
  final int year;
  final int month; // 1 to 13 (1=Meskerem, 13=Pagume)
  final int day;
  final int dayOfWeek; // 1=Mon, ..., 7=Sun

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
    required this.dayOfWeek,
  });

  static const List<String> monthNames = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሣሥ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜን',
  ];

  static const List<String> dayNames = [
    'ሰኞ',
    'ማክሰኞ',
    'ረቡዕ',
    'ሐሙስ',
    'ዓርብ',
    'ቅዳሜ',
    'እሑድ',
  ];

  static const List<String> monthNamesEn = [
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  static const List<String> dayNamesEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get monthName => monthNames[(month - 1).clamp(0, 12)];
  String get dayName => dayNames[(dayOfWeek - 1).clamp(0, 6)];

  String get monthNameEn => monthNamesEn[(month - 1).clamp(0, 12)];
  String get dayNameEn => dayNamesEn[(dayOfWeek - 1).clamp(0, 6)];

  String format({bool includeDayName = true, bool isEnglish = false}) {
    if (isEnglish) {
      if (includeDayName) {
        return '$dayNameEn, $monthNameEn $day, $year E.C.';
      }
      return '$monthNameEn $day, $year E.C.';
    }
    if (includeDayName) {
      return '$dayName፥ $monthName $day ቀን $year ዓ.ም.';
    }
    return '$monthName $day ቀን $year ዓ.ም.';
  }

  @override
  String toString() => format();
}

class LiturgicalEvent {
  final String title;
  final String titleEn;
  final String category; // 'ጾም' (Fast), 'በዓል' (Feast), 'ወቅት' (Season)
  final String categoryEn; // 'Fast', 'Feast', 'Season'
  final EthiopianDate date;
  final String description;
  final String descriptionEn;
  final String? matchingPlanId;

  const LiturgicalEvent({
    required this.title,
    this.titleEn = '',
    required this.category,
    this.categoryEn = '',
    required this.date,
    required this.description,
    this.descriptionEn = '',
    this.matchingPlanId,
  });

  String getDisplayTitle(bool isEnglish) {
    try {
      if (isEnglish && titleEn.isNotEmpty) return titleEn;
    } catch (_) {}
    return title;
  }

  String getDisplayCategory(bool isEnglish) {
    try {
      if (isEnglish && categoryEn.isNotEmpty) return categoryEn;
    } catch (_) {}
    return category;
  }

  String getDisplayDescription(bool isEnglish) {
    try {
      if (isEnglish && descriptionEn.isNotEmpty) return descriptionEn;
    } catch (_) {}
    return description;
  }
}

class BahireHasabService {
  BahireHasabService._();

  /// Accurate Gregorian to Ethiopian calendar conversion using Julian Day algorithm
  static EthiopianDate fromGregorian(DateTime gregorian) {
    final year = gregorian.year;
    final month = gregorian.month;
    final day = gregorian.day;

    // Convert Gregorian to Julian Day Number (JDN)
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    int jdn = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Convert JDN to Ethiopian Date
    const int ethEra = 1723856;
    final r = (jdn - ethEra) % 1461;
    final n = (r % 365) + 365 * (r ~/ 1460);

    final ethYear = 4 * ((jdn - ethEra) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    final ethMonth = (n ~/ 30) + 1;
    final ethDay = (n % 30) + 1;

    final dayOfWeek = gregorian.weekday; // 1 = Monday, 7 = Sunday
    return EthiopianDate(
      year: ethYear,
      month: ethMonth,
      day: ethDay,
      dayOfWeek: dayOfWeek,
    );
  }

  /// Get Evangelist (ወንጌላዊ) of the Ethiopian year
  static String getEvangelist(int ethYear, {bool isEnglish = false}) {
    final ameteAlem = ethYear + 5500;
    final r = ameteAlem % 4;
    switch (r) {
      case 1:
        return isEnglish ? 'Year of Matthew' : 'ዘመነ ማቴዎስ';
      case 2:
        return isEnglish ? 'Year of Mark' : 'ዘመነ ማርቆስ';
      case 3:
        return isEnglish ? 'Year of Luke' : 'ዘመነ ሉቃስ';
      case 0:
      default:
        return isEnglish ? 'Year of John' : 'ዘመነ ዮሐንስ';
    }
  }

  /// Calculates Fast of Nineveh (ጾመ ነነዌ) for an Ethiopian Year
  static EthiopianDate getNinevehDate(int ethYear) {
    final ameteAlem = ethYear + 5500;

    // አበቅቴ (Abektie)
    final abektie = (ameteAlem % 19 * 11) % 30;

    // መጥቅዕ (Metq'e)
    final metqe = (abektie == 0) ? 30 : 30 - abektie;

    // ወርሐ መጥቅዕ
    final metqeMonth = (metqe > 14) ? 1 : 2; // 1 = Meskerem, 2 = Tikimt

    // ዕለተ ዮሐንስ (Meskerem 1 Day of Week: 0=Sun, 1=Mon, ..., 6=Sat)
    final meteneRabiet = ameteAlem ~/ 4;
    final meskerem1Day = (ameteAlem + meteneRabiet) % 7;

    // Day of week of Metq'e
    int metqeDayOfWeek;
    if (metqeMonth == 1) {
      metqeDayOfWeek = (meskerem1Day + (metqe - 1)) % 7;
    } else {
      metqeDayOfWeek = (meskerem1Day + 30 + (metqe - 1)) % 7;
    }

    // ተውሳክ (Tewsak) for Nineveh based on day of week of Metq'e
    // 0=Sun->7, 1=Mon->6, 2=Tue->5, 3=Wed->4, 4=Thu->3, 5=Fri->2, 6=Sat->8
    const tewsak = [7, 6, 5, 4, 3, 2, 8];
    final t = tewsak[metqeDayOfWeek];

    // Nineveh calculation
    int ninevehDay = metqe + t;
    int ninevehMonth = 6; // የካቲት (Yekatit)

    if (metqeMonth == 1) {
      // Meskerem Metq'e means Nineveh falls in Tir (5) or Yekatit (6)
      if (ninevehDay > 30) {
        ninevehDay = ninevehDay - 30;
        ninevehMonth = 6; // የካቲት
      } else {
        ninevehMonth = 5; // ጥር
      }
    } else {
      // Tikimt Metq'e
      if (ninevehDay > 30) {
        ninevehDay = ninevehDay - 30;
        ninevehMonth = 6; // የካቲት
      } else {
        ninevehMonth = 6;
      }
    }

    return EthiopianDate(
      year: ethYear,
      month: ninevehMonth,
      day: ninevehDay,
      dayOfWeek: 1, // Nineveh is always a Monday (ሰኞ)
    );
  }

  /// Add days to an Ethiopian Date
  static EthiopianDate addDays(EthiopianDate date, int days) {
    int curYear = date.year;
    int curMonth = date.month;
    int curDay = date.day + days;

    while (curDay > (curMonth == 13 ? (isLeapYear(curYear) ? 6 : 5) : 30)) {
      final maxDays = (curMonth == 13 ? (isLeapYear(curYear) ? 6 : 5) : 30);
      curDay -= maxDays;
      curMonth++;
      if (curMonth > 13) {
        curMonth = 1;
        curYear++;
      }
    }

    final newDayOfWeek = ((date.dayOfWeek - 1 + days) % 7) + 1;
    return EthiopianDate(
      year: curYear,
      month: curMonth,
      day: curDay,
      dayOfWeek: newDayOfWeek,
    );
  }

  static bool isLeapYear(int ethYear) {
    return (ethYear + 5500) % 4 == 3;
  }

  /// Calculates all Movable Feasts & Fasts for the given Ethiopian year
  static List<LiturgicalEvent> getMovableEvents(int ethYear) {
    final nineveh = getNinevehDate(ethYear);

    final lent = addDays(nineveh, 14);
    final debreZeyt = addDays(nineveh, 41);
    final hosanna = addDays(nineveh, 62);
    final goodFriday = addDays(nineveh, 67);
    final easter = addDays(nineveh, 69);
    final rikbeKahnat = addDays(nineveh, 93);
    final ascension = addDays(nineveh, 108);
    final pentecost = addDays(nineveh, 118);
    final apostlesFast = addDays(nineveh, 119);
    final dihnetFast = addDays(nineveh, 121);

    return [
      LiturgicalEvent(
        title: 'ጾመ ነነዌ',
        titleEn: 'Fast of Nineveh',
        category: 'ጾም',
        categoryEn: 'Fast',
        date: nineveh,
        description: 'የሦስት ቀን የነነዌ ጾምና የንስሐ ጸሎት።',
        descriptionEn: 'Three-day fast of repentance and prayer of Nineveh.',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ዐቢይ ጾም',
        titleEn: 'Great Lent',
        category: 'ጾም',
        categoryEn: 'Fast',
        date: lent,
        description: 'የጌታችን የ55 ቀናት የዐቢይ ጾም መጀመሪያ (ዘወረደ)።',
        descriptionEn: 'Start of our Lord\'s 55-day Great Lent (Zewerede).',
        matchingPlanId: 'great_lent_55',
      ),
      LiturgicalEvent(
        title: 'ደብረ ዘይት',
        titleEn: 'Mount of Olives',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: debreZeyt,
        description: 'የዐቢይ ጾም እኩሌታ፤ የጌታችን ዳግም ምጽአት መታሰቢያ።',
        descriptionEn: 'Mid-Lent commemoration of Christ\'s Second Coming.',
        matchingPlanId: 'great_lent_55',
      ),
      LiturgicalEvent(
        title: 'ሆሣዕና',
        titleEn: 'Palm Sunday (Hosanna)',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: hosanna,
        description: 'ጌታችን በክብር ወደ ኢየሩሳሌም መግባቱ፤ የሰሞነ ሕማማት መጀመሪያ።',
        descriptionEn: 'Triumphal entry of Christ into Jerusalem; start of Passion Week.',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ስቅለተ ዓርብ',
        titleEn: 'Good Friday',
        category: 'ጾም',
        categoryEn: 'Fast',
        date: goodFriday,
        description: 'ጌታችን ኢየሱስ ክርስቶስ ስለ ሰው ልጆች በመስቀል ላይ የዋለበት ታላቅ ቀን።',
        descriptionEn: 'Crucifixion and sacrifice of our Lord Jesus Christ for salvation.',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ትንሣኤ / ፋሲካ',
        titleEn: 'Holy Easter (Fasika)',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: easter,
        description: 'ክርስቶስ ተነሥቷል! የትንሣኤ በዓለ ኀምሳ መጀመሪያ።',
        descriptionEn: 'Christ is risen! Start of the 50-day Paschal season.',
        matchingPlanId: 'gospels_30',
      ),
      LiturgicalEvent(
        title: 'ርክበ ካህናት',
        titleEn: 'Synod of Priests (Rikbe Kahnat)',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: rikbeKahnat,
        description: 'የካህናት ጉባኤና መንፈሳዊ ምክክር በዓል።',
        descriptionEn: 'Assembly and spiritual synod of priests.',
      ),
      LiturgicalEvent(
        title: 'ዕርገተ ክርስቶስ',
        titleEn: 'Ascension of Christ',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: ascension,
        description: 'ጌታችን በክብር ወደ ሰማይ ያረገበት 40ኛው ቀን።',
        descriptionEn: 'The 40th day commemorating our Lord\'s glorious Ascension into heaven.',
        matchingPlanId: 'gospels_30',
      ),
      LiturgicalEvent(
        title: 'በዓለ ጰራቅሊጦስ',
        titleEn: 'Pentecost (Paraclete)',
        category: 'በዓል',
        categoryEn: 'Feast',
        date: pentecost,
        description: 'መንፈስ ቅዱስ በሐዋርያት ላይ የወረደበት የቤተክርስቲያን ልደት።',
        descriptionEn: 'Descent of the Holy Spirit upon the Apostles; birth of the Church.',
        matchingPlanId: 'nt_90',
      ),
      LiturgicalEvent(
        title: 'ጾመ ሐዋርያት',
        titleEn: 'Fast of the Apostles',
        category: 'ጾም',
        categoryEn: 'Fast',
        date: apostlesFast,
        description: 'ከበዓለ ጰራቅሊጦስ ማግሥት የሚጀመረው የቅዱሳን ሐዋርያት ጾም።',
        descriptionEn: 'Fast of the Holy Apostles beginning the day after Pentecost.',
        matchingPlanId: 'nt_90',
      ),
      LiturgicalEvent(
        title: 'ጾመ ድኅነት',
        titleEn: 'Fast of Salvation',
        category: 'ጾም',
        categoryEn: 'Fast',
        date: dihnetFast,
        description: 'ረቡዕና ዓርብ በጾም የሚቀጥልበት የድኅነት ጾም መጀመሪያ።',
        descriptionEn: 'Resumption of regular Wednesday and Friday fasting.',
      ),
    ];
  }

  /// Detects the current Liturgical Season or Fast for today's Ethiopian Date
  static Map<String, dynamic> getCurrentLiturgicalStatus(DateTime now) {
    final ethDate = fromGregorian(now);
    final evangelist = getEvangelist(ethDate.year, isEnglish: false);
    final evangelistEn = getEvangelist(ethDate.year, isEnglish: true);
    final movable = getMovableEvents(ethDate.year);

    final lentEvent = movable.firstWhere((e) => e.title.contains('ዐቢይ ጾም'));
    final easterEvent = movable.firstWhere((e) => e.title.contains('ትንሣኤ'));
    final ninevehEvent = movable.firstWhere((e) => e.title.contains('ነነዌ'));
    final apostlesFastEvent = movable.firstWhere((e) => e.title.contains('ሐዋርያት'));

    String seasonTitle = 'ዘመነ $evangelist';
    String seasonTitleEn = evangelistEn;
    String seasonCategory = 'ወቅት';
    String seasonCategoryEn = 'Season';
    String? recommendedPlanId;
    String seasonDescription = '${ethDate.format()} • $evangelist';
    String seasonDescriptionEn = '${ethDate.format(isEnglish: true)} • $evangelistEn';

    // 1. Fast of Assumption (ጾመ ፍልሰታ - ነሐሴ 1 - 16)
    if (ethDate.month == 12 && ethDate.day >= 1 && ethDate.day <= 16) {
      seasonTitle = 'ጾመ ፍልሰታ';
      seasonTitleEn = 'Fast of the Assumption';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'filseta_16';
      seasonDescription = 'የእመቤታችን ጾመ ፍልሰታ — ቀን ${ethDate.day}';
      seasonDescriptionEn = 'Fast of St. Mary (Filseta) — Day ${ethDate.day}';
    }
    // 2. Fast of Nineveh (ጾመ ነነዌ - 3 ቀናት)
    else if (ethDate.month == ninevehEvent.date.month &&
        ethDate.day >= ninevehEvent.date.day &&
        ethDate.day < ninevehEvent.date.day + 3) {
      seasonTitle = 'ጾመ ነነዌ';
      seasonTitleEn = 'Fast of Nineveh';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'passion_week';
      seasonDescription = 'የሦስት ቀናት የነነዌ ጾምና የንስሐ ጸሎት';
      seasonDescriptionEn = 'Three days of fasting and repentance of Nineveh';
    }
    // 3. Fast of the Prophets / Advent (ጾመ ነቢያት - ኅዳር 15 - ታኅሣሥ 28)
    else if ((ethDate.month == 3 && ethDate.day >= 15) ||
        (ethDate.month == 4 && ethDate.day <= 28)) {
      seasonTitle = 'ጾመ ነቢያት';
      seasonTitleEn = 'Fast of the Prophets (Advent)';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'advent_prophets_43';
      seasonDescription = 'የገና ጾምና የነቢያት ትንቢት ወቅት';
      seasonDescriptionEn = 'Nativity fast and prophecies of Christ';
    }
    // 4. Season of Flowers (ዘመነ ጽጌ - መስከረም 26 - ኅዳር 5)
    else if ((ethDate.month == 1 && ethDate.day >= 26) ||
        (ethDate.month == 2) ||
        (ethDate.month == 3 && ethDate.day <= 5)) {
      seasonTitle = 'ዘመነ ጽጌ';
      seasonTitleEn = 'Season of Flowers';
      seasonCategory = 'ወቅት';
      seasonCategoryEn = 'Season';
      recommendedPlanId = 'filseta_16';
      seasonDescription = 'የማሕሌተ ጽጌና የእመቤታችን ስደት መታሰቢያ ወቅት';
      seasonDescriptionEn = 'Season of Tsigie and flight of the Holy Family';
    }
    // 5. Holy Passion Week / Great Lent (ዐቢይ ጾም)
    else if (ethDate.month == lentEvent.date.month && ethDate.day >= lentEvent.date.day ||
        (ethDate.month == easterEvent.date.month && ethDate.day <= easterEvent.date.day)) {
      seasonTitle = 'ዐቢይ ጾም';
      seasonTitleEn = 'Holy Great Lent';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'great_lent_55';
      seasonDescription = 'የሁዳዴ ጾም፣ ጸሎትና ንስሐ ወቅት';
      seasonDescriptionEn = 'Great Lent, prayer and repentance season';
    }
    // 6. Easter 50 Days (በዓለ ኀምሳ)
    else if (ethDate.month == easterEvent.date.month && ethDate.day > easterEvent.date.day ||
        (ethDate.month == apostlesFastEvent.date.month &&
            ethDate.day < apostlesFastEvent.date.day)) {
      seasonTitle = 'የትንሣኤ በዓለ ኀምሳ';
      seasonTitleEn = 'Holy Easter Season (50 Days)';
      seasonCategory = 'በዓል';
      seasonCategoryEn = 'Feast';
      recommendedPlanId = 'gospels_30';
      seasonDescription = 'ክርስቶስ ተነሥቷል! የሐሤትና የምስጋና ወቅት';
      seasonDescriptionEn = 'Christ is risen! Season of joy and thanksgiving';
    }
    // 7. Fast of the Apostles (ጾመ ሐዋርያት)
    else if (ethDate.month == apostlesFastEvent.date.month &&
        ethDate.day >= apostlesFastEvent.date.day) {
      seasonTitle = 'ጾመ ሐዋርያት';
      seasonTitleEn = 'Fast of the Apostles';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'nt_90';
      seasonDescription = 'የቅዱሳን ሐዋርያት የስብከትና የጾም ወቅት';
      seasonDescriptionEn = 'Holy Apostles preaching and fast season';
    }

    return {
      'ethDate': ethDate,
      'evangelist': evangelist,
      'evangelistEn': evangelistEn,
      'seasonTitle': seasonTitle,
      'seasonTitleEn': seasonTitleEn,
      'seasonCategory': seasonCategory,
      'seasonCategoryEn': seasonCategoryEn,
      'seasonDescription': seasonDescription,
      'seasonDescriptionEn': seasonDescriptionEn,
      'recommendedPlanId': recommendedPlanId,
      'movableEvents': movable,
    };
  }
}
