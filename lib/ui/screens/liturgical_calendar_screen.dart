import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/bahire_hasab_service.dart';
import '../widgets/ethiopian_cross_painter.dart';

class LiturgicalCalendarScreen extends ConsumerStatefulWidget {
  const LiturgicalCalendarScreen({super.key});

  @override
  ConsumerState<LiturgicalCalendarScreen> createState() => _LiturgicalCalendarScreenState();
}

class _LiturgicalCalendarScreenState extends ConsumerState<LiturgicalCalendarScreen> {
  late int _selectedMonth; // 1 to 13
  late int _selectedYear;
  late int _selectedDay;
  late EthiopianDate _todayEth;

  // Fixed Canonical EOTC Feasts & Fasts (Month: 1-13, Day: 1-30)
  static const List<Map<String, dynamic>> _fixedAnnualEvents = [
    // Meskerem (Month 1)
    {
      'month': 1,
      'day': 1,
      'title': 'እንቁጣጣሽ (ቅዱስ ዮሐንስ / ርእሰ ዓውደ ዓመት)',
      'titleEn': 'Enkutatash (Ethiopian New Year)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የኢትዮጵያ አዲስ ዓመት መባቻ፤ የመጥምቁ ቅዱስ ዮሐንስ መታሰቢያ።',
      'descriptionEn': 'Ethiopian New Year celebration and memorial of St. John the Baptist.',
    },
    {
      'month': 1,
      'day': 17,
      'title': 'መስቀል (ደመራ)',
      'titleEn': 'Meskel (Finding of True Cross)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ንግሥት ዕሌኒ የጌታችንን ክቡር መስቀል በደመራ ጭስ የመረመረችበት ታላቅ በዓል።',
      'descriptionEn': 'Commemoration of the Discovery of the True Cross by Queen Helena.',
    },
    {
      'month': 1,
      'day': 26,
      'title': 'ዘመነ ጽጌ መግቢያ',
      'titleEn': 'Start of Season of Flowers (Tsigie)',
      'category': 'ወቅት',
      'categoryEn': 'Season',
      'description': 'የእመቤታችን የስደቷ መታሰቢያና የማኅሌተ ጽጌ ምስጋና ወቅት መጀመሪያ።',
      'descriptionEn': 'Start of the liturgical Season of Flowers commemorating the Holy Family\'s flight to Egypt.',
    },
    // Tikimt (Month 2)
    {
      'month': 2,
      'day': 14,
      'title': 'አቡነ አረጋዊ',
      'titleEn': 'Abune Aregawi',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ከተስዓቱ ቅዱሳን አንዱ የሆኑት የታላቁ አባት የአቡነ አረጋዊ ዓመታዊ በዓል።',
      'descriptionEn': 'Annual feast of Abba Aregawi, one of the Nine Saints of Ethiopia.',
    },
    // Hidar (Month 3)
    {
      'month': 3,
      'day': 6,
      'title': 'ቁስቋም (የስደት ፍጻሜ / የዘመነ ጽጌ ማብቂያ)',
      'titleEn': 'Qusqwam (End of Flight to Egypt)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'እመቤታችን ከልጇ ጋር ከግብጽ ስደት ወደ ናዝሬት የተመለሰችበት ታላቅ መታሰቢያ።',
      'descriptionEn': 'Commemoration of the Holy Family\'s return to Nazareth from exile in Egypt.',
    },
    {
      'month': 3,
      'day': 12,
      'title': 'ቅዱስ ሚካኤል (ኅዳር ሚካኤል)',
      'titleEn': 'St. Michael the Archangel',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የሊቀ መላእክት ቅዱስ ሚካኤል ዓመታዊ ታላቅ በዓል።',
      'descriptionEn': 'Major annual feast of Archangel Michael.',
    },
    {
      'month': 3,
      'day': 15,
      'title': 'ጾመ ነቢያት መግቢያ (የገና ጾም)',
      'titleEn': 'Start of Fast of the Prophets (Advent)',
      'category': 'ጾም',
      'categoryEn': 'Fast',
      'description': 'የ43 ቀናት የጌታችን የልደት ዝግጅት ጾም መጀመሪያ።',
      'descriptionEn': 'Start of the 43-day Fast of the Prophets in preparation for Christmas.',
    },
    {
      'month': 3,
      'day': 21,
      'title': 'ጽዮን ማርያም (ኅዳር ጽዮን)',
      'titleEn': 'Saint Mary of Zion (Hidar Tsion)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ጽላተ ኪዳኑ ወደ ኢትዮጵያ (አክሱም ጽዮን) የገባበት ታላቅ በዓል።',
      'descriptionEn': 'Feast of the Ark of the Covenant arriving in Axum, Ethiopia.',
    },
    // Tahsas (Month 4)
    {
      'month': 4,
      'day': 19,
      'title': 'ቅዱስ ገብርኤል (ታኅሣሥ ገብርኤል)',
      'titleEn': 'St. Gabriel the Archangel (Kulubi)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ሠለስቱ ደቂቅን ከእቶን እሳት ያዳነበት የሊቀ መላእክት ቅዱስ ገብርኤል ታላቅ በዓል።',
      'descriptionEn': 'Feast of the Archangel Gabriel saving the Three Youths from the furnace.',
    },
    {
      'month': 4,
      'day': 29,
      'title': 'በዓለ ልደት (ገና)',
      'titleEn': 'Holy Nativity (Christmas / Gena)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የጌታችን የመድኃኒታችን የኢየሱስ ክርስቶስ የልደት በዓል።',
      'descriptionEn': 'The Nativity of our Lord, God, and Savior Jesus Christ.',
    },
    // Tir (Month 5)
    {
      'month': 5,
      'day': 11,
      'title': 'በዓለ ጥምቀት (ኤጲፋንያ)',
      'titleEn': 'Timkat (Epiphany)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ጌታችን በዮርዳኖስ ወንዝ በእደ ዮሐንስ የተጠመቀበት ታላቅ በዓል።',
      'descriptionEn': 'The Baptism of Christ in the Jordan River by John the Baptist.',
    },
    {
      'month': 5,
      'day': 12,
      'title': 'ቃና ዘገሊላ',
      'titleEn': 'Kana Zegalila (Wedding at Cana)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ጌታችን ውኃውን ወደ ወይን የለወጠበት የመጀመሪያው ተአምር መታሰቢያ።',
      'descriptionEn': 'First miracle of Christ turning water into wine at the wedding in Cana.',
    },
    {
      'month': 5,
      'day': 21,
      'title': 'አስተርእዮ ማርያም',
      'titleEn': 'Aster\'eyo Maryam',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የእመቤታችን የቅድስት ድንግል ማርያም የዕረፍቷ መታሰቢያ።',
      'descriptionEn': 'Commemoration of the repose/dormition of the Virgin Mary.',
    },
    // Megabit (Month 7)
    {
      'month': 7,
      'day': 10,
      'title': 'መድኃኔዓለም',
      'titleEn': 'Medhane Alem (Savior of the World)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የጌታችን የመድኃኒታችን የኢየሱስ ክርስቶስ የምሕረት በዓል።',
      'descriptionEn': 'Feast of the Savior of the World.',
    },
    {
      'month': 7,
      'day': 29,
      'title': 'በዓለ ብሥራት',
      'titleEn': 'Feast of the Annunciation',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'መልአኩ ቅዱስ ገብርኤል ለእመቤታችን ጌታን እንደምትወልድ ያበሠረበት ቀን።',
      'descriptionEn': 'Archangel Gabriel announces the Incarnation to the Virgin Mary.',
    },
    // Ginbot (Month 9)
    {
      'month': 9,
      'day': 1,
      'title': 'ልደታ ለማርያም',
      'titleEn': 'Nativity of the Virgin Mary',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የእመቤታችን የቅድስት ድንግል ማርያም የልደት በዓል።',
      'descriptionEn': 'Nativity of the Blessed Virgin Mary.',
    },
    {
      'month': 9,
      'day': 12,
      'title': 'አቡነ ተክለ ሃይማኖት',
      'titleEn': 'Abune Tekle Haymanot',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የኢትዮጵያ ፀሐይ የታላቁ ጻድቅ የአቡነ ተክለ ሃይማኖት ልደት።',
      'descriptionEn': 'Feast commemorating the birth of St. Tekle Haymanot.',
    },
    // Sene (Month 10)
    {
      'month': 10,
      'day': 21,
      'title': 'ሕንጸተ ቤተክርስቲያን (ሰኔ ጎልጎታ)',
      'titleEn': 'Seney Golgota (First Church Dedicated to Mary)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'በፊልጵስዩስ በእመቤታችን ስም የመጀመሪያዋ ቤተክርስቲያን የተመሠረተችበት ቀን።',
      'descriptionEn': 'Dedication of the first church in honor of the Virgin Mary at Philippi.',
    },
    // Hamle (Month 11)
    {
      'month': 11,
      'day': 5,
      'title': 'ጴጥሮስ ወጳውሎስ (የሐዋርያት ጾም ማብቂያ)',
      'titleEn': 'Sts. Peter and Paul',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የቅዱሳን ሐዋርያት የጴጥሮስና የጳውሎስ የሰማዕትነት በዓልና የጾሙ ፍጻሜ።',
      'descriptionEn': 'Feast of the Apostles Peter & Paul, and conclusion of the Apostles Fast.',
    },
    {
      'month': 11,
      'day': 19,
      'title': 'ቅዱስ ቂርቆስና ኢየሉጣ',
      'titleEn': 'St. Cyricus and Julitta (Qirqos)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የሕፃኑ የቅዱስ ቂርቆስና የእናቱ የቅድስት ኢየሉጣ ዓመታዊ የሰማዕትነት መታሰቢያ።',
      'descriptionEn': 'Martyrdom of the Child Saint Cyricus (Qirqos) and his mother Julitta.',
    },
    // Nehase (Month 12)
    {
      'month': 12,
      'day': 1,
      'title': 'ጾመ ፍልሰታ መግቢያ',
      'titleEn': 'Start of Fast of the Assumption (Filseta)',
      'category': 'ጾም',
      'categoryEn': 'Fast',
      'description': 'የ16 ቀናት የእመቤታችን የዕርገቷና የትንሣኤዋ ጾም መጀመሪያ።',
      'descriptionEn': 'Start of the 16-day Fast of the Assumption of the Virgin Mary.',
    },
    {
      'month': 12,
      'day': 13,
      'title': 'ደብረ ታቦር (ቡሄ)',
      'titleEn': 'Transfiguration (Debre Tabor / Buhe)',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'ጌታችን በደብረ ታቦር ተራራ ክብሩንና መለኮታዊ ብርሃኑን የገለጠበት ታላቅ በዓል።',
      'descriptionEn': 'The Transfiguration of our Lord on Mount Tabor.',
    },
    {
      'month': 12,
      'day': 16,
      'title': 'ፍልሰታ ለማርያም (ትንሣኤዋና ዕርገቷ)',
      'titleEn': 'Assumption of the Virgin Mary',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የእመቤታችን የቅድስት ድንግል ማርያም የትንሣኤዋና የዕርገቷ ታላቅ በዓል።',
      'descriptionEn': 'Feast of the Assumption (Resurrection & Ascension) of the Virgin Mary.',
    },
    // Pagume (Month 13)
    {
      'month': 13,
      'day': 3,
      'title': 'ቅዱስ ሩፋኤል',
      'titleEn': 'St. Raphael the Archangel',
      'category': 'በዓል',
      'categoryEn': 'Feast',
      'description': 'የፈዋሹ መልአክ የሊቀ መላእክት ቅዱስ ሩፋኤል በዓልና የጳጉሜን ጾም ወቅት።',
      'descriptionEn': 'Feast of Archangel Raphael the healer and the Pagume fasting period.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _todayEth = BahireHasabService.fromGregorian(DateTime.now());
    _selectedYear = _todayEth.year;
    _selectedMonth = _todayEth.month;
    _selectedDay = _todayEth.day;
  }

  List<LiturgicalEvent> _getAllEventsForDay(int month, int day) {
    final List<LiturgicalEvent> events = [];

    // 1. Check fixed events
    for (final e in _fixedAnnualEvents) {
      if (e['month'] == month && e['day'] == day) {
        events.add(
          LiturgicalEvent(
            title: e['title'] as String,
            titleEn: e['titleEn'] as String,
            category: e['category'] as String,
            categoryEn: e['categoryEn'] as String,
            date: EthiopianDate(
              year: _selectedYear,
              month: month,
              day: day,
              dayOfWeek: 1,
            ),
            description: e['description'] as String,
            descriptionEn: e['descriptionEn'] as String,
          ),
        );
      }
    }

    // 2. Check movable events
    final movable = BahireHasabService.getMovableEvents(_selectedYear);
    for (final m in movable) {
      if (m.date.month == month && m.date.day == day) {
        events.add(m);
      }
    }

    return events;
  }

  bool _isDayFast(int month, int day, int dayOfWeek) {
    // 1. Wednesday & Friday are fasting days except in Paschal Season (Easter to Pentecost)
    final movable = BahireHasabService.getMovableEvents(_selectedYear);
    final easter = movable.firstWhere((e) => e.title.contains('ትንሣኤ'), orElse: () => movable.first);
    final pentecost = movable.firstWhere((e) => e.title.contains('ጰራቅሊጦስ') || e.title.contains('በዓለ ኀምሳ') || e.titleEn.contains('Pentecost'), orElse: () => easter);

    // Canonical fast periods:
    // Advent / Fast of Prophets: Hidar 15 - Tahsas 28
    if (month == 3 && day >= 15) return true;
    if (month == 4 && day <= 28) return true;

    // Filseta: Nehase 1 - 16
    if (month == 12 && day <= 16) return true;

    // Pagume: Pagume 1 - 5/6
    if (month == 13) return true;

    // Great Lent (55 days): check range between Lent and Easter
    final lent = movable.firstWhere((e) => e.title.contains('ዐቢይ ጾም'), orElse: () => easter);
    if (_isDateBetween(month, day, lent.date, easter.date)) return true;

    // Fast of Nineveh (3 days)
    final nineveh = movable.firstWhere((e) => e.title.contains('ነነዌ'), orElse: () => easter);
    final ninevehEnd = BahireHasabService.addDays(nineveh.date, 3);
    if (_isDateBetween(month, day, nineveh.date, ninevehEnd)) return true;

    // Fast of Apostles: Pentecost Monday to Hamle 4
    final apostlesFast = movable.firstWhere((e) => e.title.contains('ሐዋርያት') || e.category == 'ጾም', orElse: () => easter);
    if (_isDateBetween(month, day, apostlesFast.date, EthiopianDate(year: _selectedYear, month: 11, day: 4, dayOfWeek: 1))) {
      return true;
    }

    // Weekly Wednesday (dayOfWeek == 3) & Friday (dayOfWeek == 5)
    if (dayOfWeek == 3 || dayOfWeek == 5) {
      // Check if in 50 days of Easter (non-fasting)
      if (!_isDateBetween(month, day, easter.date, pentecost.date)) {
        return true;
      }
    }

    return false;
  }

  bool _isDateBetween(int m, int d, EthiopianDate start, EthiopianDate end) {
    final curVal = m * 30 + d;
    final startVal = start.month * 30 + start.day;
    final endVal = end.month * 30 + end.day;
    return curVal >= startVal && curVal <= endVal;
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);

    final evangelist = BahireHasabService.getEvangelist(_selectedYear, isEnglish: isEnglish);
    final monthName = isEnglish
        ? EthiopianDate.monthNamesEn[_selectedMonth - 1]
        : EthiopianDate.monthNames[_selectedMonth - 1];

    final daysInMonth = _selectedMonth == 13
        ? (BahireHasabService.isLeapYear(_selectedYear) ? 6 : 5)
        : 30;

    // Find first day of week relative to today
    final daysDiff = (_selectedMonth - _todayEth.month) * 30 + (1 - _todayEth.day);
    final firstDayOfWeek = (((_todayEth.dayOfWeek - 1 + daysDiff) % 7) + 7) % 7 + 1;

    final selectedDayEvents = _getAllEventsForDay(_selectedMonth, _selectedDay);
    final isSelectedDayFast = _isDayFast(
      _selectedMonth,
      _selectedDay,
      (((firstDayOfWeek - 1 + (_selectedDay - 1)) % 7) + 1),
    );

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeConfig.backgroundColor,
        elevation: 0,
        title: Text(
          isEnglish ? 'Liturgical Calendar' : 'የኢትዮጵያ አጽዋማትና በዓላት',
          style: themeConfig.getAppStyle(
            isEnglish: isEnglish,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeConfig.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: isEnglish ? 'Go to Today' : 'ወደ ዛሬ ቀን ተመለስ',
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedYear = _todayEth.year;
                _selectedMonth = _todayEth.month;
                _selectedDay = _todayEth.day;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Year & Evangelist Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1A16), const Color(0xFF2C2219)]
                        : [const Color(0xFFFBF8F2), const Color(0xFFF3ECE0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeConfig.goldAccent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    OrthodoxCrossIcon(
                      size: 22,
                      color: themeConfig.goldAccent,
                      style: EthiopianCrossStyle.lalibela,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEnglish
                                ? '$_selectedYear Ethiopian Calendar'
                                : '$_selectedYear ዓመተ ምሕረት (ባሕረ ሐሳብ)',
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: themeConfig.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEnglish ? 'Cycle of Evangelist $evangelist' : 'ዘመነ $evangelist (የአራቱ ወንጌላውያን ዑደት)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeConfig.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Month Selector Strip
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 13,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final monthIndex = idx + 1;
                    final isSelected = monthIndex == _selectedMonth;
                    final isCurrentMonth = monthIndex == _todayEth.month;
                    final name = isEnglish
                        ? EthiopianDate.monthNamesEn[idx]
                        : EthiopianDate.monthNames[idx];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedMonth = monthIndex;
                          if (_selectedDay > (monthIndex == 13 ? 5 : 30)) {
                            _selectedDay = 1;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeConfig.accentColor
                              : (isCurrentMonth
                                  ? themeConfig.goldAccent.withValues(alpha: 0.15)
                                  : themeConfig.surfaceColor),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? themeConfig.accentColor
                                : (isCurrentMonth ? themeConfig.goldAccent : themeConfig.cardBorderColor),
                            width: isSelected || isCurrentMonth ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            name,
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : themeConfig.textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 3. Calendar Month Grid Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Column(
                  children: [
                    // Month Name & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$monthName $_selectedYear',
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                        Text(
                          isEnglish ? '$daysInMonth Days' : '$daysInMonth ቀናት',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: themeConfig.secondaryTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Day of Week Headers (ሰኞ -> እሑድ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        final label = isEnglish
                            ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]
                            : ['ሰ', 'ማ', 'ረ', 'ሐ', 'ዓ', 'ቅ', 'እ'][i];
                        final isWeekend = i >= 5;
                        final isFastHeader = i == 2 || i == 4;
                        return SizedBox(
                          width: 36,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isFastHeader
                                  ? const Color(0xFFDC2626)
                                  : (isWeekend ? themeConfig.goldAccent : themeConfig.secondaryTextColor),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: (firstDayOfWeek - 1) + daysInMonth,
                      itemBuilder: (context, idx) {
                        if (idx < firstDayOfWeek - 1) {
                          return const SizedBox.shrink();
                        }

                        final dayNum = idx - (firstDayOfWeek - 1) + 1;
                        final dayOfWeek = (idx % 7) + 1;
                        final isSelected = dayNum == _selectedDay;
                        final isToday = _selectedMonth == _todayEth.month &&
                            dayNum == _todayEth.day &&
                            _selectedYear == _todayEth.year;

                        final events = _getAllEventsForDay(_selectedMonth, dayNum);
                        final hasFeast = events.any((e) => e.category == 'በዓል' || e.categoryEn == 'Feast');
                        final isFast = _isDayFast(_selectedMonth, dayNum, dayOfWeek);

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedDay = dayNum);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeConfig.accentColor
                                  : (isToday ? themeConfig.goldAccent.withValues(alpha: 0.18) : Colors.transparent),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? themeConfig.accentColor
                                    : (isToday ? themeConfig.goldAccent : Colors.transparent),
                                width: isSelected || isToday ? 1.5 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  themeConfig.useGeezNumerals && !isEnglish
                                      ? GeezNumbers.toGeez(dayNum)
                                      : '$dayNum',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isToday ? themeConfig.goldAccent : themeConfig.textColor),
                                  ),
                                ),
                                if (hasFeast || isFast)
                                  Positioned(
                                    bottom: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasFeast)
                                          Container(
                                            width: 4.5,
                                            height: 4.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.amberAccent : const Color(0xFFF59E0B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (isFast)
                                          Container(
                                            width: 4.5,
                                            height: 4.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white70 : const Color(0xFFDC2626),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Selected Day Detail View
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEnglish
                              ? '$monthName $_selectedDay, $_selectedYear E.C.'
                              : '$monthName $_selectedDay ቀን $_selectedYear ዓ.ም.',
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelectedDayFast
                                ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                                : const Color(0xFF047857).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSelectedDayFast
                                ? (isEnglish ? 'Fasting Day' : 'የጾም ቀን')
                                : (isEnglish ? 'Feasting / Non-Fast' : 'የፈሰክ ቀን'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelectedDayFast ? const Color(0xFFDC2626) : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (selectedDayEvents.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: themeConfig.secondaryTextColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEnglish
                                    ? 'Daily liturgical office and ordinary prayer service.'
                                    : 'መደበኛ የዕለቱ ጸሎትና ምስጋና።',
                                style: TextStyle(fontSize: 13, color: themeConfig.secondaryTextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ...selectedDayEvents.map((evt) {
                        final isFeast = evt.category == 'በዓል' || evt.categoryEn == 'Feast';
                        final badgeColor = isFeast ? const Color(0xFFD97706) : const Color(0xFFDC2626);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      evt.getDisplayCategory(isEnglish),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      evt.getDisplayTitle(isEnglish),
                                      style: themeConfig.getAppStyle(
                                        isEnglish: isEnglish,
                                        fontWeight: FontWeight.w800,
                                        fontSize: isEnglish ? 13.5 : 14,
                                        color: themeConfig.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                evt.getDisplayDescription(isEnglish),
                                style: themeConfig.getAppStyle(
                                  isEnglish: isEnglish,
                                  fontSize: isEnglish ? 12 : 12.5,
                                  height: 1.45,
                                  color: themeConfig.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
