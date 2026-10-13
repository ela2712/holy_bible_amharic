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

  String get monthName => monthNames[(month - 1).clamp(0, 12)];
  String get dayName => dayNames[(dayOfWeek - 1).clamp(0, 6)];

  String format({bool includeDayName = true}) {
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
  final String category; // 'ጾም' (Fast), 'በዓል' (Feast), 'ወቅት' (Season)
  final EthiopianDate date;
  final String description;
  final String? matchingPlanId;

  const LiturgicalEvent({
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    this.matchingPlanId,
  });
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
  static String getEvangelist(int ethYear) {
    final ameteAlem = ethYear + 5500;
    final r = ameteAlem % 4;
    switch (r) {
      case 1:
        return 'ዘመነ ማቴዎስ';
      case 2:
        return 'ዘመነ ማርቆስ';
      case 3:
        return 'ዘመነ ሉቃስ';
      case 0:
      default:
        return 'ዘመነ ዮሐንስ';
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
        title: 'ጾመ ነነዌ (Fast of Nineveh)',
        category: 'ጾም',
        date: nineveh,
        description: 'የሦስት ቀን የነነዌ ጾምና የንስሐ ጸሎት።',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ዐቢይ ጾም (Great Lent / ሁዳዴ)',
        category: 'ጾም',
        date: lent,
        description: 'የጌታችን የ55 ቀናት የዐቢይ ጾም መጀመሪያ (ዘወረደ)።',
        matchingPlanId: 'great_lent_55',
      ),
      LiturgicalEvent(
        title: 'ደብረ ዘይት (Mount of Olives)',
        category: 'በዓል',
        date: debreZeyt,
        description: 'የዐቢይ ጾም እኩሌታ፤ የጌታችን ዳግም ምጽአት መታሰቢያ።',
        matchingPlanId: 'great_lent_55',
      ),
      LiturgicalEvent(
        title: 'ሆሣዕና (Palm Sunday)',
        category: 'በዓል',
        date: hosanna,
        description: 'ጌታችን በክብር ወደ ኢየሩሳሌም መግባቱ፤ የሰሞነ ሕማማት መጀመሪያ።',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ስቅለተ ዓርብ (Good Friday)',
        category: 'ጾም',
        date: goodFriday,
        description: 'ጌታችን ኢየሱስ ክርስቶስ ስለ ሰው ልጆች በመስቀል ላይ የዋለበት ታላቅ ቀን።',
        matchingPlanId: 'passion_week',
      ),
      LiturgicalEvent(
        title: 'ትንሣኤ / ፋሲካ (Holy Easter)',
        category: 'በዓል',
        date: easter,
        description: 'ክርስቶስ ተነሥቷል! የትንሣኤ በዓለ ኀምሳ መጀመሪያ።',
        matchingPlanId: 'gospels_30',
      ),
      LiturgicalEvent(
        title: 'ርክበ ካህናት (Assembly of Priests)',
        category: 'በዓል',
        date: rikbeKahnat,
        description: 'የካህናት ጉባኤና መንፈሳዊ ምክክር በዓል።',
      ),
      LiturgicalEvent(
        title: 'ዕርገተ ክርስቶስ (Ascension)',
        category: 'በዓል',
        date: ascension,
        description: 'ጌታችን በክብር ወደ ሰማይ ያረገበት 40ኛው ቀን።',
        matchingPlanId: 'gospels_30',
      ),
      LiturgicalEvent(
        title: 'በዓለ ጰራቅሊጦስ (Pentecost)',
        category: 'በዓል',
        date: pentecost,
        description: 'መንፈስ ቅዱስ በሐዋርያት ላይ የወረደበት የቤተክርስቲያን ልደት።',
        matchingPlanId: 'nt_90',
      ),
      LiturgicalEvent(
        title: 'ጾመ ሐዋርያት (Fast of the Apostles)',
        category: 'ጾም',
        date: apostlesFast,
        description: 'ከበዓለ ጰራቅሊጦስ ማግሥት የሚጀመረው የቅዱሳን ሐዋርያት ጾም።',
        matchingPlanId: 'nt_90',
      ),
      LiturgicalEvent(
        title: 'ጾመ ድኅነት (Fast of Salvation)',
        category: 'ጾም',
        date: dihnetFast,
        description: 'ረቡዕና ዓርብ በጾም የሚቀጥልበት የድኅነት ጾም መጀመሪያ።',
      ),
    ];
  }

  /// Detects the current Liturgical Season or Fast for today's Ethiopian Date
  static Map<String, dynamic> getCurrentLiturgicalStatus(DateTime now) {
    final ethDate = fromGregorian(now);
    final evangelist = getEvangelist(ethDate.year);
    final movable = getMovableEvents(ethDate.year);

    final lentEvent = movable.firstWhere((e) => e.title.contains('ዐቢይ ጾም'));
    final easterEvent = movable.firstWhere((e) => e.title.contains('ትንሣኤ'));
    final ninevehEvent = movable.firstWhere((e) => e.title.contains('ነነዌ'));
    final apostlesFastEvent = movable.firstWhere((e) => e.title.contains('ሐዋርያት'));

    String seasonTitle = 'ዘመነ $evangelist';
    String seasonCategory = 'ወቅት';
    String? recommendedPlanId;
    String seasonDescription = '${ethDate.format()} • $evangelist';

    // 1. Fast of Assumption (ጾመ ፍልሰታ - ነሐሴ 1 - 16)
    if (ethDate.month == 12 && ethDate.day >= 1 && ethDate.day <= 16) {
      seasonTitle = 'ጾመ ፍልሰታ (Fast of Assumption)';
      seasonCategory = 'ጾም';
      recommendedPlanId = 'filseta_16';
      seasonDescription = 'የእመቤታችን ጾመ ፍልሰታ — ቀን ${ethDate.day}';
    }
    // 2. Fast of Nineveh (ጾመ ነነዌ - 3 ቀናት)
    else if (ethDate.month == ninevehEvent.date.month &&
        ethDate.day >= ninevehEvent.date.day &&
        ethDate.day < ninevehEvent.date.day + 3) {
      seasonTitle = 'ጾመ ነነዌ (Fast of Nineveh)';
      seasonCategory = 'ጾም';
      recommendedPlanId = 'passion_week';
      seasonDescription = 'የሦስት ቀናት የነነዌ ጾምና የንስሐ ጸሎት';
    }
    // 3. Fast of the Prophets / Advent (ጾመ ነቢያት - ኅዳር 15 - ታኅሣሥ 28)
    else if ((ethDate.month == 3 && ethDate.day >= 15) ||
        (ethDate.month == 4 && ethDate.day <= 28)) {
      seasonTitle = 'ጾመ ነቢያት (Advent / Fast of the Prophets)';
      seasonCategory = 'ጾም';
      recommendedPlanId = 'advent_prophets_43';
      seasonDescription = 'የገና ጾምና የነቢያት ትንቢት ወቅት';
    }
    // 4. Season of Flowers (ዘመነ ጽጌ - መስከረም 26 - ኅዳር 5)
    else if ((ethDate.month == 1 && ethDate.day >= 26) ||
        (ethDate.month == 2) ||
        (ethDate.month == 3 && ethDate.day <= 5)) {
      seasonTitle = 'ዘመነ ጽጌ (Season of Flowers)';
      seasonCategory = 'ወቅት';
      recommendedPlanId = 'filseta_16';
      seasonDescription = 'የማሕሌተ ጽጌና የእመቤታችን ስደት መታሰቢያ ወቅት';
    }
    // 4. Holy Passion Week / Great Lent (ዐቢይ ጾም)
    else if (ethDate.month == lentEvent.date.month && ethDate.day >= lentEvent.date.day ||
        (ethDate.month == easterEvent.date.month && ethDate.day <= easterEvent.date.day)) {
      seasonTitle = 'ዐቢይ ጾም (Holy Great Lent)';
      seasonCategory = 'ጾም';
      recommendedPlanId = 'great_lent_55';
      seasonDescription = 'የሁዳዴ ጾም፣ ጸሎትና ንስሐ ወቅት';
    }
    // 5. Easter 50 Days (በዓለ ኀምሳ)
    else if (ethDate.month == easterEvent.date.month && ethDate.day > easterEvent.date.day ||
        (ethDate.month == apostlesFastEvent.date.month &&
            ethDate.day < apostlesFastEvent.date.day)) {
      seasonTitle = 'የትንሣኤ በዓለ ኀምሳ (Easter Season)';
      seasonCategory = 'በዓል';
      recommendedPlanId = 'gospels_30';
      seasonDescription = 'ክርስቶስ ተነሥቷል! የሐሤትና የምስጋና ወቅት';
    }
    // 6. Fast of the Apostles (ጾመ ሐዋርያት)
    else if (ethDate.month == apostlesFastEvent.date.month &&
        ethDate.day >= apostlesFastEvent.date.day) {
      seasonTitle = 'ጾመ ሐዋርያት (Fast of the Apostles)';
      seasonCategory = 'ጾም';
      recommendedPlanId = 'nt_90';
      seasonDescription = 'የቅዱሳን ሐዋርያት የስብከትና የጾም ወቅት';
    }

    return {
      'ethDate': ethDate,
      'evangelist': evangelist,
      'seasonTitle': seasonTitle,
      'seasonCategory': seasonCategory,
      'seasonDescription': seasonDescription,
      'recommendedPlanId': recommendedPlanId,
      'movableEvents': movable,
    };
  }
}
