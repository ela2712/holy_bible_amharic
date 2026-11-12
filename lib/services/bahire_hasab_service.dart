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

class FastSeasonInfo {
  final String planId;
  final bool isSeasonal;
  final bool isUnlocked;
  final int daysUntilStart;
  final int daysRemaining;
  final EthiopianDate? startDate;
  final EthiopianDate? endDate;

  const FastSeasonInfo({
    required this.planId,
    required this.isSeasonal,
    required this.isUnlocked,
    this.daysUntilStart = 0,
    this.daysRemaining = 0,
    this.startDate,
    this.endDate,
  });

  String getCountdownText({required bool isEnglish}) {
    if (!isSeasonal || isUnlocked) return '';
    if (startDate != null) {
      final dateStr = isEnglish
          ? '${startDate!.monthNameEn} ${startDate!.day}'
          : '${startDate!.monthName} ${GeezNumbers.toGeez(startDate!.day)}';
      return isEnglish
          ? 'Unlocks in $daysUntilStart ${daysUntilStart == 1 ? "day" : "days"} • $dateStr'
          : 'ከ $daysUntilStart ቀናት በኋላ ይከፈታል • $dateStr';
    }
    return isEnglish
        ? 'Unlocks in $daysUntilStart ${daysUntilStart == 1 ? "day" : "days"}'
        : 'ከ $daysUntilStart ቀናት በኋላ ይከፈታል';
  }

  String getSeasonRangeText({required bool isEnglish}) {
    if (startDate == null || endDate == null) return '';
    if (isEnglish) {
      if (startDate!.month == endDate!.month) {
        return '${startDate!.monthNameEn} ${startDate!.day}–${endDate!.day}';
      }
      return '${startDate!.monthNameEn} ${startDate!.day} – ${endDate!.monthNameEn} ${endDate!.day}';
    } else {
      if (startDate!.month == endDate!.month) {
        return '${startDate!.monthName} ${GeezNumbers.toGeez(startDate!.day)} - ${GeezNumbers.toGeez(endDate!.day)}';
      }
      return '${startDate!.monthName} ${GeezNumbers.toGeez(startDate!.day)} - ${endDate!.monthName} ${GeezNumbers.toGeez(endDate!.day)}';
    }
  }
}

class BahireHasabService {
  BahireHasabService._();

  static const Set<String> seasonalPlanIds = {
    'advent_prophets_43',
    'nineveh_3',
    'great_lent_55',
    'passion_week',
    'apostles_fast',
    'filseta_16',
  };

  static const Set<String> eotcCuratedPlanIds = {
    'canonical_365',
    'deuterocanon_90',
    'advent_prophets_43',
    'nineveh_3',
    'great_lent_55',
    'passion_week',
    'apostles_fast',
    'filseta_16',
  };

  /// Total days in an Ethiopian Year (365, or 366 in leap year)
  static int daysInEthYear(int ethYear) => isLeapYear(ethYear) ? 366 : 365;

  /// Day of the year (1-based: 1 to 365/366) for an Ethiopian date
  static int dayOfYear(EthiopianDate date) {
    return ((date.month - 1) * 30) + date.day;
  }

  /// Calculates the exact number of days from [from] to [to].
  /// Returns a positive number if [to] is after [from].
  static int daysBetween(EthiopianDate from, EthiopianDate to) {
    if (from.year == to.year) {
      return dayOfYear(to) - dayOfYear(from);
    }
    if (to.year > from.year) {
      int days = daysInEthYear(from.year) - dayOfYear(from);
      for (int y = from.year + 1; y < to.year; y++) {
        days += daysInEthYear(y);
      }
      days += dayOfYear(to);
      return days;
    } else {
      return -daysBetween(to, from);
    }
  }

  /// Returns day of week (1=Mon, ..., 7=Sun) for any Ethiopian Date
  static int getDayOfWeek(int ethYear, int ethMonth, int ethDay) {
    final ameteAlem = ethYear + 5500;
    final meteneRabiet = ameteAlem ~/ 4;
    final meskerem1Day = (ameteAlem + meteneRabiet) % 7; // 0=Mon, ..., 6=Sun
    final dayNum = ((ethMonth - 1) * 30) + ethDay;
    final dow0 = (meskerem1Day + (dayNum - 1)) % 7;
    return dow0 + 1; // 1=Mon, ..., 7=Sun
  }

  /// Create an EthiopianDate with calculated day of week
  static EthiopianDate createEthiopianDate(int year, int month, int day) {
    return EthiopianDate(
      year: year,
      month: month,
      day: day,
      dayOfWeek: getDayOfWeek(year, month, day),
    );
  }

  static Map<String, EthiopianDate> _getPlanSeasonDates(String planId, int ethYear) {
    switch (planId) {
      case 'filseta_16':
        return {
          'start': createEthiopianDate(ethYear, 12, 1),
          'end': createEthiopianDate(ethYear, 12, 16),
        };
      case 'advent_prophets_43':
        return {
          'start': createEthiopianDate(ethYear, 3, 15),
          'end': createEthiopianDate(ethYear, 4, 28),
        };
      case 'nineveh_3':
        final nineveh = getNinevehDate(ethYear);
        final end = addDays(nineveh, 2);
        return {'start': nineveh, 'end': end};
      case 'great_lent_55':
        final nineveh = getNinevehDate(ethYear);
        final start = addDays(nineveh, 14);
        final end = addDays(nineveh, 68);
        return {'start': start, 'end': end};
      case 'passion_week':
        final nineveh = getNinevehDate(ethYear);
        final start = addDays(nineveh, 62);
        final end = addDays(nineveh, 69);
        return {'start': start, 'end': end};
      case 'apostles_fast':
        final nineveh = getNinevehDate(ethYear);
        final start = addDays(nineveh, 119); // Monday after Pentecost
        final end = createEthiopianDate(ethYear, 11, 4); // Hamle 4 (Eve of Peter & Paul)
        return {'start': start, 'end': end};
      default:
        throw ArgumentError('Not a seasonal plan: $planId');
    }
  }

  /// Accurate real-time calculation of seasonal status, lock state, and days until start
  static FastSeasonInfo getFastSeasonInfo(String planId, EthiopianDate today) {
    if (!seasonalPlanIds.contains(planId)) {
      return FastSeasonInfo(
        planId: planId,
        isSeasonal: false,
        isUnlocked: true,
      );
    }

    final curRange = _getPlanSeasonDates(planId, today.year);
    final curStart = curRange['start']!;
    final curEnd = curRange['end']!;

    final daysToStart = daysBetween(today, curStart);
    final daysToEnd = daysBetween(today, curEnd);

    if (daysToStart > 0) {
      // Before this year's fast
      return FastSeasonInfo(
        planId: planId,
        isSeasonal: true,
        isUnlocked: false,
        daysUntilStart: daysToStart,
        daysRemaining: 0,
        startDate: curStart,
        endDate: curEnd,
      );
    } else if (daysToEnd >= 0) {
      // Currently active fast! (daysToStart <= 0 and daysToEnd >= 0)
      return FastSeasonInfo(
        planId: planId,
        isSeasonal: true,
        isUnlocked: true,
        daysUntilStart: 0,
        daysRemaining: daysToEnd + 1,
        startDate: curStart,
        endDate: curEnd,
      );
    } else {
      // This year's fast has already passed, next occurrence is in today.year + 1
      final nextRange = _getPlanSeasonDates(planId, today.year + 1);
      final nextStart = nextRange['start']!;
      final nextEnd = nextRange['end']!;
      final daysToNextStart = daysBetween(today, nextStart);

      return FastSeasonInfo(
        planId: planId,
        isSeasonal: true,
        isUnlocked: false,
        daysUntilStart: daysToNextStart,
        daysRemaining: 0,
        startDate: nextStart,
        endDate: nextEnd,
      );
    }
  }

  static Map<String, FastSeasonInfo> getAllSeasonalPlansInfo(EthiopianDate today) {
    final map = <String, FastSeasonInfo>{};
    for (final id in seasonalPlanIds) {
      map[id] = getFastSeasonInfo(id, today);
    }
    return map;
  }


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
        matchingPlanId: 'nineveh_3',
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
        matchingPlanId: 'apostles_fast',
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

    final daysFromEaster = daysBetween(easterEvent.date, ethDate);
    final bool isEasterFifty = daysFromEaster > 0 && daysBetween(ethDate, apostlesFastEvent.date) > 0;

    bool isSeasonalFast = false;

    final filsetaInfo = getFastSeasonInfo('filseta_16', ethDate);
    final adventInfo = getFastSeasonInfo('advent_prophets_43', ethDate);
    final lentInfo = getFastSeasonInfo('great_lent_55', ethDate);
    final passionInfo = getFastSeasonInfo('passion_week', ethDate);
    final apostlesInfo = getFastSeasonInfo('apostles_fast', ethDate);

    // 1. Fast of Assumption (ጾመ ፍልሰታ - ነሐሴ 1 - 16)
    if (filsetaInfo.isUnlocked) {
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
    else if (daysBetween(ninevehEvent.date, ethDate) >= 0 &&
        daysBetween(ethDate, addDays(ninevehEvent.date, 2)) >= 0) {
      seasonTitle = 'ጾመ ነነዌ';
      seasonTitleEn = 'Fast of Nineveh';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'nineveh_3';
      seasonDescription = 'የሦስት ቀናት የነነዌ ጾምና የንስሐ ጸሎት';
      seasonDescriptionEn = 'Three days of fasting and repentance of Nineveh';
      isSeasonalFast = true;
    }
    // 3. Fast of the Prophets / Advent (ጾመ ነቢያት - ኅዳር 15 - ታኅሣሥ 28)
    else if (adventInfo.isUnlocked) {
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
      recommendedPlanId = null;
      seasonDescription = 'የማሕሌተ ጽጌና የእመቤታችን ስደት መታሰቢያ ወቅት';
      seasonDescriptionEn = 'Season of Tsigie and flight of the Holy Family';
    }
    // 5. Holy Passion Week (ሰሞነ ሕማማት)
    else if (passionInfo.isUnlocked) {
      seasonTitle = 'ሰሞነ ሕማማት';
      seasonTitleEn = 'Holy Passion Week';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'passion_week';
      seasonDescription = 'የክርስቶስ የመስቀል መከራና የሰሞነ ሕማማት ምንባባት';
      seasonDescriptionEn = 'Holy Passion Week and readings of Christ\'s crucifixion';
      isSeasonalFast = true;
    }
    // 6. Great Lent (ዐቢይ ጾም)
    else if (lentInfo.isUnlocked) {
      seasonTitle = 'ዐቢይ ጾም';
      seasonTitleEn = 'Holy Great Lent';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'great_lent_55';
      seasonDescription = 'የሁዳዴ ጾም፣ ጸሎትና ንስሐ ወቅት';
      seasonDescriptionEn = 'Great Lent, prayer and repentance season';
      isSeasonalFast = true;
    }
    // 7. Easter 50 Days (በዓለ ኀምሳ)
    else if (isEasterFifty) {
      seasonTitle = 'የትንሣኤ በዓለ ኀምሳ';
      seasonTitleEn = 'Holy Easter Season (50 Days)';
      seasonCategory = 'በዓል';
      seasonCategoryEn = 'Feast';
      recommendedPlanId = 'gospels_30';
      seasonDescription = 'ክርስቶስ ተነሥቷል! የሐሤትና የምስጋና ወቅት';
      seasonDescriptionEn = 'Christ is risen! Season of joy and thanksgiving';
    }
    // 8. Fast of the Apostles (ጾመ ሐዋርያት)
    else if (apostlesInfo.isUnlocked) {
      seasonTitle = 'ጾመ ሐዋርያት';
      seasonTitleEn = 'Fast of the Apostles';
      seasonCategory = 'ጾም';
      seasonCategoryEn = 'Fast';
      recommendedPlanId = 'apostles_fast';
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
        'title': 'ጾመ ሐዋርያት',
        'titleEn': 'Fast of the Apostles',
        'month': apostlesFastEvent.date.month,
        'day': apostlesFastEvent.date.day,
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
    };
  }
}
