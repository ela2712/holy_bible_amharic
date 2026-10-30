import '../core/utils/geez_numbers.dart';

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

  /// Format date using traditional Ge'ez numerals (e.g. ጥቅምት ፲፱ ቀን ፪ሺ፲፱ ዓ.ም.)
  String toGeezString({bool includeDayName = true}) {
    final dayGeez = GeezNumbers.toGeez(day);
    final yearGeez = GeezNumbers.toGeez(year);
    if (includeDayName) {
      return '$dayName፥ $monthName $dayGeez ቀን $yearGeez ዓ.ም.';
    }
    return '$monthName $dayGeez ቀን $yearGeez ዓ.ም.';
  }

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

class SynaxariumEntry {
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final int bookNumber;
  final String bookName;
  final String bookNameEn;
  final int chapter;
  final int verse;
  final String passage;
  final String passageEn;

  const SynaxariumEntry({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.bookNumber,
    required this.bookName,
    required this.bookNameEn,
    required this.chapter,
    required this.verse,
    required this.passage,
    required this.passageEn,
  });

  String getDisplayTitle(bool isEnglish) => isEnglish && titleEn.isNotEmpty ? titleEn : title;
  String getDisplayDescription(bool isEnglish) => isEnglish && descriptionEn.isNotEmpty ? descriptionEn : description;
  String getDisplayPassage(bool isEnglish) => isEnglish && passageEn.isNotEmpty ? passageEn : passage;
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

  /// Calculates Fast of Nineveh (ጾመ ነነዌ) for an Ethiopian Year according to authentic EOTC Bahire Hasab
  static EthiopianDate getNinevehDate(int ethYear) {
    final ameteAlem = ethYear + 5500;

    // መደብ (Medeb) & ወንበር (Wenber)
    final medeb = ameteAlem % 19;
    final wenber = (medeb == 0 ? 19 : medeb) - 1;

    // አበቅቴ (Abektie)
    final abektie = (wenber * 11) % 30;

    // መጥቅዕ (Metq'e): Inviolable rule: abektie + metqe = 30
    final metqe = (abektie == 0) ? 30 : (30 - abektie);

    // ወርሐ መጥቅዕ: if metqe > 14 -> Meskerem (1); else -> Tikimt (2)
    final metqeMonth = (metqe > 14) ? 1 : 2;

    // ዕለተ ዮሐንስ (Meskerem 1 Day of Week: 0=Mon, 1=Tue, ..., 6=Sun)
    final meteneRabiet = ameteAlem ~/ 4;
    final meskerem1Day = (ameteAlem + meteneRabiet) % 7;

    // Day of week of Metq'e
    int metqeDayOfWeek;
    if (metqeMonth == 1) {
      metqeDayOfWeek = (meskerem1Day + (metqe - 1)) % 7;
    } else {
      metqeDayOfWeek = (meskerem1Day + 30 + (metqe - 1)) % 7;
    }

    // የዕለታት ተውሳክ (Day Tewsak for EOTC):
    // 0=Mon->6, 1=Tue->5, 2=Wed->4, 3=Thu->3, 4=Fri->2, 5=Sat->8, 6=Sun->7
    const tewsak = [6, 5, 4, 3, 2, 8, 7];
    final t = tewsak[metqeDayOfWeek];

    // መባጃ ሐመር (Mebaja Hamer) = Metq'e + Tewsak
    final mebajaHamer = metqe + t;
    int ninevehDay;
    int ninevehMonth;

    if (metqeMonth == 1) {
      // Meskerem Metq'e: if mebajaHamer > 30, it rolls into Yekatit (6); else Tir (5)
      if (mebajaHamer > 30) {
        ninevehDay = mebajaHamer - 30;
        ninevehMonth = 6; // የካቲት
      } else {
        ninevehDay = mebajaHamer;
        ninevehMonth = 5; // ጥር
      }
    } else {
      // Tikimt Metq'e: always falls in Yekatit (6)
      ninevehDay = (mebajaHamer > 30) ? mebajaHamer - 30 : mebajaHamer;
      ninevehMonth = 6; // የካቲት
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

    final bool isEasterFifty = (ethDate.month == easterEvent.date.month && ethDate.day > easterEvent.date.day) ||
        (ethDate.month == apostlesFastEvent.date.month && ethDate.day < apostlesFastEvent.date.day);

    bool isSeasonalFast = false;

    // 1. Fast of Assumption (ጾመ ፍልሰታ - ነሐሴ 1 - 16)
    if (ethDate.month == 12 && ethDate.day >= 1 && ethDate.day <= 16) {
      seasonTitle = 'ጾመ ፍልሰታ';
      seasonTitleEn = 'Fast of the Assumption';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'filseta_16';
      seasonDescription = 'የእመቤታችን ጾመ ፍልሰታ — ቀን ${ethDate.day}';
      seasonDescriptionEn = 'Fast of St. Mary (Filseta) — Day ${ethDate.day}';
      isSeasonalFast = true;
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
      isSeasonalFast = true;
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
      isSeasonalFast = true;
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
      isSeasonalFast = true;
    }
    // 6. Easter 50 Days (በዓለ ኀምሳ)
    else if (isEasterFifty) {
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
        ethDate.day >= apostlesFastEvent.date.day &&
        (ethDate.month < 11 || (ethDate.month == 11 && ethDate.day <= 4))) {
      seasonTitle = 'ጾመ ሐዋርያት';
      seasonTitleEn = 'Fast of the Apostles';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'nt_90';
      seasonDescription = 'የቅዱሳን ሐዋርያት የስብከትና የጾም ወቅት';
      seasonDescriptionEn = 'Holy Apostles preaching and fast season';
      isSeasonalFast = true;
    }

    // Authentic EOTC Fasting Rule:
    // Wednesday (3) & Friday (5) are fasting days year-round, except during the 50 days of Easter (በዓለ ኀምሳ).
    final bool isWedOrFri = (ethDate.dayOfWeek == 3 || ethDate.dayOfWeek == 5);
    final bool isFastDay = isSeasonalFast || (isWedOrFri && !isEasterFifty);

    String fastLabel;
    String fastLabelEn;
    if (isSeasonalFast) {
      fastLabel = '$seasonTitle (የጾም ወቅት)';
      fastLabelEn = '$seasonTitleEn (Fast Season)';
    } else if (isFastDay) {
      fastLabel = ethDate.dayOfWeek == 3
          ? 'ረቡዕ — የጾም ቀን (ምክረ አይሁድ)'
          : 'ዓርብ — የጾም ቀን (ስቅለተ ክርስቶስ)';
      fastLabelEn = ethDate.dayOfWeek == 3
          ? 'Wednesday Fast (Conspiracy of Betrayal)'
          : 'Friday Fast (Crucifixion of Christ)';
    } else {
      fastLabel = isEasterFifty ? 'የትንሣኤ በዓለ ኀምሳ' : '';
      fastLabelEn = isEasterFifty ? 'Paschal 50 Days' : '';
    }

    // Next upcoming major feast or fast countdown
    final allUpcoming = <Map<String, dynamic>>[
      {
        'title': 'ጾመ ነቢያት',
        'titleEn': 'Fast of the Prophets',
        'month': 3,
        'day': 15,
      },
      {
        'title': 'ልደተ ክርስቶስ (ገና)',
        'titleEn': 'Nativity of Christ (Genna)',
        'month': 4,
        'day': 29,
      },
      {
        'title': 'ጥምቀት',
        'titleEn': 'Epiphany (Timkat)',
        'month': 5,
        'day': 11,
      },
      {
        'title': 'ጾመ ነነዌ',
        'titleEn': 'Fast of Nineveh',
        'month': ninevehEvent.date.month,
        'day': ninevehEvent.date.day,
      },
      {
        'title': 'ዐቢይ ጾም (ዘወረደ)',
        'titleEn': 'Great Lent',
        'month': lentEvent.date.month,
        'day': lentEvent.date.day,
      },
      {
        'title': 'ሆሣዕና',
        'titleEn': 'Palm Sunday (Hosanna)',
        'month': movable.firstWhere((e) => e.title.contains('ሆሣዕና')).date.month,
        'day': movable.firstWhere((e) => e.title.contains('ሆሣዕና')).date.day,
      },
      {
        'title': 'ትንሣኤ / ፋሲካ',
        'titleEn': 'Holy Easter (Fasika)',
        'month': easterEvent.date.month,
        'day': easterEvent.date.day,
      },
      {
        'title': 'ጾመ ፍልሰታ',
        'titleEn': 'Fast of the Assumption',
        'month': 12,
        'day': 1,
      },
    ];

    final currentDayOfYear = (ethDate.month - 1) * 30 + ethDate.day;
    Map<String, dynamic>? nextEvent;
    int minDaysDiff = 9999;

    for (final ev in allUpcoming) {
      final evDayOfYear = ((ev['month'] as int) - 1) * 30 + (ev['day'] as int);
      int diff = evDayOfYear - currentDayOfYear;
      if (diff < 0) {
        diff += 365; // wrap around to next year
      }
      if (diff > 0 && diff < minDaysDiff) {
        minDaysDiff = diff;
        nextEvent = ev;
      }
    }

    final daysToNext = minDaysDiff < 9999 ? minDaysDiff : 0;
    final nextEventTitle = nextEvent != null ? nextEvent['title'] as String : '';
    final nextEventTitleEn = nextEvent != null ? nextEvent['titleEn'] as String : '';

    // EOTC Daily Lectionary Readings (የዕለቱ ምንባባት)
    final lectionary = _getDailyLectionary(ethDate);

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
      'isFastDay': isFastDay,
      'fastLabel': fastLabel,
      'fastLabelEn': fastLabelEn,
      'daysToNextEvent': daysToNext,
      'nextEventTitle': nextEventTitle,
      'nextEventTitleEn': nextEventTitleEn,
      'dailyLectionary': lectionary,
      'dailySynaxarium': getDailySynaxarium(ethDate),
    };
  }

  /// Appointed scripture readings for the Ethiopian Orthodox Liturgical Day
  static Map<String, dynamic> _getDailyLectionary(EthiopianDate ethDate) {
    // Curated liturgical cycle for EOTC
    final dayOfWeek = ethDate.dayOfWeek;
    switch (dayOfWeek) {
      case 7: // እሑድ (Sunday - Resurrection)
        return {
          'title': 'የእሑድ ምንባብ — የትንሣኤ ምስክርነት',
          'titleEn': 'Sunday Lectionary — Resurrection Witness',
          'canonicalId': 'JHN',
          'bookName': 'የዮሐንስ ወንጌል',
          'bookNameEn': 'John',
          'bookNumber': 43,
          'chapter': 20,
          'passage': 'የዮሐንስ ወንጌል ምዕራፍ 20',
          'passageEn': 'Gospel of John Chapter 20',
          'description': 'ክርስቶስ በክብር ተነሣ፤ ማርያም መግደላዊትና ሐዋርያት ባዶውን መቃብር አዩ።',
          'descriptionEn': 'Christ is risen in glory; Mary Magdalene and disciples witness the empty tomb.',
        };
      case 3: // ረቡዕ (Wednesday - Fast of Betrayal)
        return {
          'title': 'የረቡዕ ምንባብ — የድኅነት ምሥጢር',
          'titleEn': 'Wednesday Lectionary — Mystery of Salvation',
          'canonicalId': 'GAL',
          'bookName': 'ወደ ገላትያ ሰዎች',
          'bookNameEn': 'Galatians',
          'bookNumber': 48,
          'chapter': 2,
          'passage': 'ወደ ገላትያ ሰዎች ምዕራፍ 2',
          'passageEn': 'Galatians Chapter 2',
          'description': '«ከክርስቶስ ጋር ተሰቅያለሁ፤ እኔም አሁን ሕያው ሆኜ አልኖርም ክርስቶስ ግን በእኔ ይኖራል»',
          'descriptionEn': '«I have been crucified with Christ and I no longer live, but Christ lives in me.»',
        };
      case 5: // ዓርብ (Friday - Fast of Crucifixion)
        return {
          'title': 'የዓርብ ምንባብ — የጌታ የመስቀል መከራ',
          'titleEn': 'Friday Lectionary — Passion of the Cross',
          'canonicalId': 'ROM',
          'bookName': 'ወደ ሮሜ ሰዎች',
          'bookNameEn': 'Romans',
          'bookNumber': 45,
          'chapter': 5,
          'passage': 'ወደ ሮሜ ሰዎች ምዕራፍ 5',
          'passageEn': 'Romans Chapter 5',
          'description': '«ገና ደካሞች ሳለን ክርስቶስ በዘመኑ ስለ ኃጢአተኞች ሞቶአልና።»',
          'descriptionEn': '«While we were still helpless, Christ died for the ungodly at the appointed time.»',
        };
      case 6: // ቅዳሜ (Saturday - Sabbath rest)
        return {
          'title': 'የቀዳሚት ምንባብ — የጽድቅና የምስጋና መዝሙር',
          'titleEn': 'Sabbath Lectionary — Psalm of Righteousness',
          'canonicalId': 'PSA',
          'bookName': 'መዝሙረ ዳዊት',
          'bookNameEn': 'Psalms',
          'bookNumber': 19,
          'chapter': 92,
          'passage': 'መዝሙረ ዳዊት ምዕራፍ 92',
          'passageEn': 'Psalms Chapter 92',
          'description': 'የሰንበት ቀን የምስጋና መዝሙር፤ «እግዚአብሔርን ማመስገን፥ መልካም ነው።»',
          'descriptionEn': 'A song for the Sabbath day: «It is good to give thanks to the Lord.»',
        };
      case 1: // ሰኞ (Monday - Angels & Repentance)
      case 2: // ማክሰኞ (Tuesday)
      case 4: // ሐሙስ (Thursday - Holy Eucharist)
      default:
        // Cyclic readings based on day of month
        final ch = (ethDate.day % 28) + 1;
        return {
          'title': 'የዕለቱ ምንባብ — የሐዋርያት ትምህርት',
          'titleEn': 'Daily Lectionary — Apostolic Teaching',
          'canonicalId': 'ACT',
          'bookName': 'የሐዋርያት ሥራ',
          'bookNameEn': 'Acts',
          'bookNumber': 44,
          'chapter': ch,
          'passage': 'የሐዋርያት ሥራ ምዕራፍ $ch',
          'passageEn': 'Acts of the Apostles Chapter $ch',
          'description': 'የቀደመችው ቤተ ክርስቲያን ጽናት፣ መንፈስ ቅዱስ ሥራና የስብከት ኃይል',
          'descriptionEn': 'Early church perseverance, work of the Holy Spirit, and the power of the Gospel',
        };
    }
  }

  /// Appointed Synaxarium (የዕለቱ ስንክሳር) saint and martyr commemoration
  static SynaxariumEntry getDailySynaxarium(EthiopianDate ethDate) {
    if (ethDate.month == 13) {
      switch (ethDate.day) {
        case 1:
          return const SynaxariumEntry(
            title: 'ቅዱስ ዮሐንስ መጥምቅ',
            titleEn: 'St. John the Baptist',
            description: 'የጌታችን የመንገዱ ጠራጊና መጥምቅ ቅዱስ ዮሐንስ መታሰቢያ',
            descriptionEn: 'Commemoration of St. John the Baptist and Forerunner of Christ',
            bookNumber: 42,
            bookName: 'የሉቃስ ወንጌል',
            bookNameEn: 'Luke',
            chapter: 3,
            verse: 1,
            passage: 'የሉቃስ ወንጌል 3:1-18',
            passageEn: 'Luke 3:1-18',
          );
        case 2:
          return const SynaxariumEntry(
            title: 'ቅዱስ ቲቶ ሐዋርያ',
            titleEn: 'St. Titus the Apostle',
            description: 'የቅዱስ ጳውሎስ ረዳትና ታማኝ የክርስቶስ ሐዋርያ ቅዱስ ቲቶ',
            descriptionEn: 'St. Titus, loyal disciple and apostle of Christ',
            bookNumber: 56,
            bookName: 'ወደ ቲቶ',
            bookNameEn: 'Titus',
            chapter: 2,
            verse: 1,
            passage: 'ወደ ቲቶ 2:1-15',
            passageEn: 'Titus 2:1-15',
          );
        case 3:
          return const SynaxariumEntry(
            title: 'ቅዱስ ሩፋኤል ሊቀ መላእክት',
            titleEn: 'St. Raphael the Archangel',
            description: 'ፈዋሽና አስደሳች መልአክ፤ የጦቢትና የሣራ አዳኝ ቅዱስ ሩፋኤል',
            descriptionEn: 'The healing Archangel, deliverer of Tobit and Sarah',
            bookNumber: 17,
            bookName: 'መጽሐፈ ጦቢት',
            bookNameEn: 'Tobit',
            chapter: 12,
            verse: 1,
            passage: 'መጽሐፈ ጦቢት 12:1-22',
            passageEn: 'Tobit 12:1-22',
          );
        case 4:
          return const SynaxariumEntry(
            title: 'ቅዱስ ዮሐንስ ወንጌላዊ',
            titleEn: 'St. John the Evangelist',
            description: 'ፍቁረ እግዚእ፤ የፍቅር ሐዋርያና ምሥጢረ መለኮት ተርጓሚ',
            descriptionEn: 'The Beloved Disciple and Apostle of Divine Love',
            bookNumber: 62,
            bookName: '1ኛ የዮሐንስ መልእክት',
            bookNameEn: '1 John',
            chapter: 4,
            verse: 7,
            passage: '1ኛ ዮሐንስ 4:7-21',
            passageEn: '1 John 4:7-21',
          );
        case 5:
          return const SynaxariumEntry(
            title: 'ቅዱሳን ጴጥሮስ ወጳውሎስ',
            titleEn: 'Sts. Peter & Paul',
            description: 'የሐዋርያት አለቆችና የቤተ ክርስቲያን መሠረቶች መታሰቢያ',
            descriptionEn: 'Commemoration of the Chiefs of the Apostles',
            bookNumber: 60,
            bookName: '1ኛ የጴጥሮስ መልእክት',
            bookNameEn: '1 Peter',
            chapter: 1,
            verse: 3,
            passage: '1ኛ ጴጥሮስ 1:3-12',
            passageEn: '1 Peter 1:3-12',
          );
        case 6:
        default:
          return const SynaxariumEntry(
            title: 'ምጽአተ ክርስቶስ',
            titleEn: 'Second Coming of Christ',
            description: 'ጌታችን መድኃኒታችን ኢየሱስ ክርስቶስ በክብር የሚመጣበት ቀን መታሰቢያ',
            descriptionEn: 'Remembrance of the Glorious Second Coming of Christ',
            bookNumber: 40,
            bookName: 'የማቴዎስ ወንጌል',
            bookNameEn: 'Matthew',
            chapter: 24,
            verse: 29,
            passage: 'የማቴዎስ ወንጌል 24:29-44',
            passageEn: 'Matthew 24:29-44',
          );
      }
    }

    switch (ethDate.day) {
      case 1:
        return const SynaxariumEntry(
          title: 'ልደታ ለማርያም / ኤልያስ ነቢይ',
          titleEn: 'Nativity of St. Mary & Elijah',
          description: 'የእመቤታችን ቅድስት ድንግል ማርያም ልደትና የነቢዩ ቅዱስ ኤልያስ መታሰቢያ',
          descriptionEn: 'Nativity of the Virgin Mary & remembrance of Elijah the Prophet',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 1,
          verse: 26,
          passage: 'የሉቃስ ወንጌል 1:26-38',
          passageEn: 'Luke 1:26-38',
        );
      case 2:
        return const SynaxariumEntry(
          title: 'ታዴዎስ ሐዋርያ',
          titleEn: 'St. Thaddaeus the Apostle',
          description: 'ከአሥራ ሁለቱ ሐዋርያት አንዱ የሆነው የቅዱስ ታዴዎስ ሐዋርያ መታሰቢያ',
          descriptionEn: 'Commemoration of St. Thaddaeus, one of the Twelve Apostles',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 10,
          verse: 1,
          passage: 'የማቴዎስ ወንጌል 10:1-15',
          passageEn: 'Matthew 10:1-15',
        );
      case 3:
        return const SynaxariumEntry(
          title: 'በዓታ ለማርያም',
          titleEn: 'Presentation of St. Mary',
          description: 'እመቤታችን ቅድስት ድንግል ማርያም ወደ ቤተ መቅደስ የገባችበት መታሰቢያ',
          descriptionEn: 'Entry of the Virgin Mary into the Holy Temple',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          bookNameEn: 'Psalms',
          chapter: 45,
          verse: 9,
          passage: 'መዝሙረ ዳዊት 45:9-17',
          passageEn: 'Psalms 45:9-17',
        );
      case 4:
        return const SynaxariumEntry(
          title: 'ዮሐንስ ወልደ ነጎድጓድ',
          titleEn: 'St. John the Evangelist',
          description: 'ወንጌላዊው ቅዱስ ዮሐንስ፤ ፍቅርና የሕይወት ቃል ሰባኪ',
          descriptionEn: 'St. John the Apostle, son of thunder and preacher of love',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          chapter: 1,
          verse: 1,
          passage: 'የዮሐንስ ወንጌል 1:1-14',
          passageEn: 'John 1:1-14',
        );
      case 5:
        return const SynaxariumEntry(
          title: 'አቡነ ገብረ መንፈስ ቅዱስ',
          titleEn: 'Abune Gebre Menfes Kidus',
          description: 'ጻድቁ አባታችን አቡነ ገብረ መንፈስ ቅዱስ፤ የታላቅ ተጋድሎና ጸሎት አባት',
          descriptionEn: 'Our Holy Father Abune Gebre Menfes Kidus of great ascetic devotion',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 11,
          verse: 25,
          passage: 'የማቴዎስ ወንጌል 11:25-30',
          passageEn: 'Matthew 11:25-30',
        );
      case 6:
        return const SynaxariumEntry(
          title: 'ቁስቋም ማርያም',
          titleEn: 'Our Lady of Qusqwam',
          description: 'እመቤታችን ከልጇ ጋር ወደ ግብፅ ምድረ በዳ የተሰደደችበት መታሰቢያ',
          descriptionEn: 'Commemoration of the Holy Family refuge in Egypt at Mount Qusqwam',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 2,
          verse: 13,
          passage: 'የማቴዎስ ወንጌል 2:13-23',
          passageEn: 'Matthew 2:13-23',
        );
      case 7:
        return const SynaxariumEntry(
          title: 'ቅድስት ሥላሴ',
          titleEn: 'The Holy Trinity',
          description: 'የአብ፣ የወልድ፣ የመንፈስ ቅዱስ የአንድነትና የሦስትነት ምስጋና መታሰቢያ',
          descriptionEn: 'Feast of the Holy and Undivided Trinity: Father, Son, and Holy Spirit',
          bookNumber: 1,
          bookName: 'ኦሪት ዘፍጥረት',
          bookNameEn: 'Genesis',
          chapter: 18,
          verse: 1,
          passage: 'ኦሪት ዘፍጥረት 18:1-15',
          passageEn: 'Genesis 18:1-15',
        );
      case 8:
        return const SynaxariumEntry(
          title: 'ኪዳነ ምሕረት / አባ ኪሮስ',
          titleEn: 'Covenant of Mercy & Abba Kiros',
          description: 'የምሕረት ቃል ኪዳን መታሰቢያና የባሕታዊው አባ ኪሮስ በዓል',
          descriptionEn: 'The Covenant of Mercy and remembrance of Abba Kiros',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          bookNameEn: 'Psalms',
          chapter: 89,
          verse: 1,
          passage: 'መዝሙረ ዳዊት 89:1-8',
          passageEn: 'Psalms 89:1-8',
        );
      case 9:
        return const SynaxariumEntry(
          title: 'ሠለስቱ ምዕት (318ቱ ሊቃውንት)',
          titleEn: '318 Fathers of Nicaea',
          description: 'በኒቂያ የተሰበሰቡ 318ቱ የኦርቶዶክስ ተዋሕዶ ሃይማኖት አበው',
          descriptionEn: 'The 318 Holy Fathers of the First Ecumenical Council of Nicaea',
          bookNumber: 44,
          bookName: 'የሐዋርያት ሥራ',
          bookNameEn: 'Acts',
          chapter: 20,
          verse: 17,
          passage: 'የሐዋርያት ሥራ 20:17-32',
          passageEn: 'Acts 20:17-32',
        );
      case 10:
        return const SynaxariumEntry(
          title: 'መስቀለ ክርስቶስ',
          titleEn: 'Feast of the Holy Cross',
          description: 'የጌታችን የመድኃኒታችን የኢየሱስ ክርስቶስ የከበረ የመስቀሉ ኃይል',
          descriptionEn: 'The Life-giving Cross of our Lord and Savior Jesus Christ',
          bookNumber: 46,
          bookName: '1ኛ ወደ ቆሮንቶስ ሰዎች',
          bookNameEn: '1 Corinthians',
          chapter: 1,
          verse: 18,
          passage: '1ኛ ቆሮንቶስ 1:18-25',
          passageEn: '1 Corinthians 1:18-25',
        );
      case 11:
        return const SynaxariumEntry(
          title: 'ቅድስት ሐና እና ቅዱስ ኢያቄም',
          titleEn: 'Sts. Joachim & Anne',
          description: 'የእመቤታችን ቅድስት ድንግል ማርያም ወላጆች ቅዱስ ኢያቄምና ቅድስት ሐና',
          descriptionEn: 'St. Joachim and St. Anne, blessed parents of the Theotokos',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 1,
          verse: 46,
          passage: 'የሉቃስ ወንጌል 1:46-56',
          passageEn: 'Luke 1:46-56',
        );
      case 12:
        return const SynaxariumEntry(
          title: 'ቅዱስ ሚካኤል ሊቀ መላእክት',
          titleEn: 'St. Michael the Archangel',
          description: 'የእስራኤል አለቃ፤ የድኅነት መልአክና ታላቁ ሊቀ መላእክት ቅዱስ ሚካኤል',
          descriptionEn: 'Chief of the Heavenly Hosts, protector and intercessor St. Michael',
          bookNumber: 66,
          bookName: 'የዮሐንስ ራእይ',
          bookNameEn: 'Revelation',
          chapter: 12,
          verse: 7,
          passage: 'የዮሐንስ ራእይ 12:7-12',
          passageEn: 'Revelation 12:7-12',
        );
      case 13:
        return const SynaxariumEntry(
          title: 'እግዚአብሔር አብ / ቅዱስ ሩፋኤል',
          titleEn: 'God the Father / St. Raphael',
          description: 'የእግዚአብሔር አብ በዓልና የፈዋሹ ሊቀ መላእክት ቅዱስ ሩፋኤል መታሰቢያ',
          descriptionEn: 'Feast of God the Father and commemoration of St. Raphael the Archangel',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 15,
          verse: 11,
          passage: 'የሉቃስ ወንጌል 15:11-32',
          passageEn: 'Luke 15:11-32',
        );
      case 14:
        return const SynaxariumEntry(
          title: 'አባ አረጋዊ ዘደብረ ዳሞ',
          titleEn: 'Abba Aregawi',
          description: 'ከተሰዓቱ ቅዱሳን አንዱ የሆኑት ጻድቁ አባታችን አባ አረጋዊ መታሰቢያ',
          descriptionEn: 'Abba Aregawi of Debre Damo, one of the Nine Saints of Ethiopia',
          bookNumber: 58,
          bookName: 'ወደ ዕብራውያን ሰዎች',
          bookNameEn: 'Hebrews',
          chapter: 11,
          verse: 32,
          passage: 'ወደ ዕብራውያን 11:32-40',
          passageEn: 'Hebrews 11:32-40',
        );
      case 15:
        return const SynaxariumEntry(
          title: 'ቅዱስ ቂርቆስና ቅድስት ኢየሉጣ',
          titleEn: 'Sts. Cyricus & Julitta',
          description: 'ሕፃኑ ሰማዕት ቅዱስ ቂርቆስና እናቱ ቅድስት ኢየሉጣ በክርስቶስ ስም የጸኑበት',
          descriptionEn: 'The child martyr St. Cyricus and his mother St. Julitta',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 18,
          verse: 1,
          passage: 'የማቴዎስ ወንጌል 18:1-10',
          passageEn: 'Matthew 18:1-10',
        );
      case 16:
        return const SynaxariumEntry(
          title: 'ኪዳነ ምሕረት (ኪዳነ ማርያም)',
          titleEn: 'Covenant of Mercy',
          description: 'እመቤታችን ቅድስት ድንግል ማርያም ከልጇ የተቀበለችው የይቅርታ ቃል ኪዳን',
          descriptionEn: 'Solemn Covenant of Mercy bestowed upon the Holy Virgin Mary',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 1,
          verse: 39,
          passage: 'የሉቃስ ወንጌል 1:39-56',
          passageEn: 'Luke 1:39-56',
        );
      case 17:
        return const SynaxariumEntry(
          title: 'ቅዱስ እስጢፋኖስ ቀዳሜ ሰማዕት',
          titleEn: 'St. Stephen the Protomartyr',
          description: 'የሰማዕታት የመጀመሪያ የሆነው ቀዳሜ ሰማዕትና ሊቀ ዲያቆናት እስጢፋኖስ',
          descriptionEn: 'St. Stephen, first deacon and protomartyr of the Christian Church',
          bookNumber: 44,
          bookName: 'የሐዋርያት ሥራ',
          bookNameEn: 'Acts',
          chapter: 7,
          verse: 54,
          passage: 'የሐዋርያት ሥራ 7:54-60',
          passageEn: 'Acts 7:54-60',
        );
      case 18:
        return const SynaxariumEntry(
          title: 'ፊልጶስ ሐዋርያ',
          titleEn: 'St. Philip the Apostle',
          description: 'ለኢትዮጵያዊው ጃንደረባ የሕይወት ቃል ያበሠረ ቅዱስ ፊልጶስ ሐዋርያ',
          descriptionEn: 'St. Philip the Apostle who guided the Ethiopian official to Christ',
          bookNumber: 44,
          bookName: 'የሐዋርያት ሥራ',
          bookNameEn: 'Acts',
          chapter: 8,
          verse: 26,
          passage: 'የሐዋርያት ሥራ 8:26-39',
          passageEn: 'Acts 8:26-39',
        );
      case 19:
        return const SynaxariumEntry(
          title: 'ቅዱስ ገብርኤል ሊቀ መላእክት',
          titleEn: 'St. Gabriel the Archangel',
          description: 'የምሥራች አብሳሪውና የሠለስቱ ደቂቅ አዳኝ ቅዱስ ገብርኤል ሊቀ መላእክት',
          descriptionEn: 'The Angel of Good Tidings and deliverer of the Three Youths',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 1,
          verse: 11,
          passage: 'የሉቃስ ወንጌል 1:11-20',
          passageEn: 'Luke 1:11-20',
        );
      case 20:
        return const SynaxariumEntry(
          title: 'ሕንፀተ ቤተ ክርስቲያን (ጽዮን)',
          titleEn: 'Dedication of the Church of Zion',
          description: 'በፊልጵስዩስ የመጀመሪያዋ የእመቤታችን ቤተ ክርስቲያን የታነጸችበት መታሰቢያ',
          descriptionEn: 'Dedication of the first church consecrated to St. Mary',
          bookNumber: 19,
          bookName: 'መዝሙረ ዳዊት',
          bookNameEn: 'Psalms',
          chapter: 132,
          verse: 13,
          passage: 'መዝሙረ ዳዊት 132:13-18',
          passageEn: 'Psalms 132:13-18',
        );
      case 21:
        return const SynaxariumEntry(
          title: 'እመቤታችን ቅድስት ድንግል ማርያም',
          titleEn: 'Holy Virgin Mary (Theotokos)',
          description: 'የወላዲተ አምላክ የቅድስት ድንግል ማርያም ወርሃዊ የበረከት መታሰቢያ',
          descriptionEn: 'Monthly commemoration of Our Lady the Holy Virgin Mary Mother of God',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 1,
          verse: 26,
          passage: 'የሉቃስ ወንጌል 1:26-38',
          passageEn: 'Luke 1:26-38',
        );
      case 22:
        return const SynaxariumEntry(
          title: 'ቅዱስ ዑራኤል ሊቀ መላእክት',
          titleEn: 'St. Uriel the Archangel',
          description: 'ለዕዝራ ሱቱኤል ጥበብን ያበሠረና የጌታን ደም በጽዋ ያቀረበ መልአክ',
          descriptionEn: 'The Archangel of Light and divine wisdom revealed to Ezra',
          bookNumber: 45,
          bookName: 'ወደ ሮሜ ሰዎች',
          bookNameEn: 'Romans',
          chapter: 8,
          verse: 31,
          passage: 'ወደ ሮሜ 8:31-39',
          passageEn: 'Romans 8:31-39',
        );
      case 23:
        return const SynaxariumEntry(
          title: 'ቅዱስ ጊዮርጊስ ሊቀ ሰማዕታት',
          titleEn: 'St. George the Martyr',
          description: 'የሰማዕታት አለቃና ኮከብ፤ በክርስቶስ ፍቅር ድል የነሣው ቅዱስ ጊዮርጊስ',
          descriptionEn: 'Chief of Martyrs and triumphant warrior of Christ St. George',
          bookNumber: 55,
          bookName: '2ኛ ወደ ጢሞቴዎስ ሰዎች',
          bookNameEn: '2 Timothy',
          chapter: 4,
          verse: 6,
          passage: '2ኛ ጢሞቴዎስ 4:6-18',
          passageEn: '2 Timothy 4:6-18',
        );
      case 24:
        return const SynaxariumEntry(
          title: 'አቡነ ተክለ ሃይማኖት',
          titleEn: 'Abune Tekle Haymanot',
          description: 'የኢትዮጵያ ፀሐይ፤ ሐዋርያዊው ጻድቅ አባታችን አቡነ ተክለ ሃይማኖት',
          descriptionEn: 'Our Apostolic Father Abune Tekle Haymanot, the sun of Ethiopia',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 19,
          verse: 27,
          passage: 'የማቴዎስ ወንጌል 19:27-30',
          passageEn: 'Matthew 19:27-30',
        );
      case 25:
        return const SynaxariumEntry(
          title: 'ቅዱስ መርቆሬዎስ ሰማዕት',
          titleEn: 'St. Mercurius the Martyr',
          description: 'ባለ ሁለት ሰይፍ ሰማዕት፤ በሃይማኖቱ የጸና የከበረ ቅዱስ መርቆሬዎስ',
          descriptionEn: 'The two-sword martyr St. Mercurius who overcame evil in Christ',
          bookNumber: 49,
          bookName: 'ወደ ኤፌሶን ሰዎች',
          bookNameEn: 'Ephesians',
          chapter: 6,
          verse: 10,
          passage: 'ወደ ኤፌሶን 6:10-20',
          passageEn: 'Ephesians 6:10-20',
        );
      case 26:
        return const SynaxariumEntry(
          title: 'ቶማስ ሐዋርያ',
          titleEn: 'St. Thomas the Apostle',
          description: '«ጌታዬና አምላኬ» ብሎ የክርስቶስን ትንሣኤ የመሰከረ ቅዱስ ቶማስ',
          descriptionEn: 'St. Thomas the Apostle: «My Lord and my God»',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          chapter: 20,
          verse: 24,
          passage: 'የዮሐንስ ወንጌል 20:24-31',
          passageEn: 'John 20:24-31',
        );
      case 27:
        return const SynaxariumEntry(
          title: 'መድኃኔ ዓለም',
          titleEn: 'Medhane Alem (Savior of the World)',
          description: 'የዓለም መድኃኒት የሆነው የጌታችን የኢየሱስ ክርስቶስ የማዳን ሥራ መታሰቢያ',
          descriptionEn: 'Feast of Jesus Christ, Medhane Alem, the Savior of the World',
          bookNumber: 43,
          bookName: 'የዮሐንስ ወንጌል',
          bookNameEn: 'John',
          chapter: 3,
          verse: 16,
          passage: 'የዮሐንስ ወንጌል 3:16-21',
          passageEn: 'John 3:16-21',
        );
      case 28:
        return const SynaxariumEntry(
          title: 'አማኑኤል (እግዚአብሔር ከእኛ ጋር)',
          titleEn: 'Emmanuel (God With Us)',
          description: '«እነሆ ድንግል ትፀንሳለች ወንድ ልጅም ትወልዳለች ስሙንም አማኑኤል ትለዋለች»',
          descriptionEn: '«The virgin shall conceive and bear a Son, and shall call His name Emmanuel»',
          bookNumber: 40,
          bookName: 'የማቴዎስ ወንጌል',
          bookNameEn: 'Matthew',
          chapter: 1,
          verse: 18,
          passage: 'የማቴዎስ ወንጌል 1:18-25',
          passageEn: 'Matthew 1:18-25',
        );
      case 29:
        return const SynaxariumEntry(
          title: 'በዓለ ወልድ (ልደተ ክርስቶስ)',
          titleEn: 'Feast of the Incarnation',
          description: 'የአምላካችን የኢየሱስ ክርስቶስ የሰው መሆንና የማዳን ምሥጢር መታሰቢያ',
          descriptionEn: 'Monthly commemoration of the Incarnation and Nativity of Christ',
          bookNumber: 42,
          bookName: 'የሉቃስ ወንጌል',
          bookNameEn: 'Luke',
          chapter: 2,
          verse: 1,
          passage: 'የሉቃስ ወንጌል 2:1-20',
          passageEn: 'Luke 2:1-20',
        );
      case 30:
      default:
        return const SynaxariumEntry(
          title: 'ቅዱስ ማርቆስ ወንጌላዊ',
          titleEn: 'St. Mark the Evangelist',
          description: 'የወንጌል ጸሐፊ፤ የእስክንድርያና የአፍሪካ የመጀመሪያው ፓትርያርክ ቅዱስ ማርቆስ',
          descriptionEn: 'St. Mark the Apostle and Evangelist, apostle to Africa',
          bookNumber: 41,
          bookName: 'የማርቆስ ወንጌል',
          bookNameEn: 'Mark',
          chapter: 1,
          verse: 1,
          passage: 'የማርቆስ ወንጌል 1:1-15',
          passageEn: 'Mark 1:1-15',
        );
    }
  }
}

