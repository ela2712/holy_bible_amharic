import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../models/reading_plan.dart';
import '../../providers/bible_state.dart';
import '../../providers/reading_plan_session_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/bahire_hasab_service.dart';

class ReadingPlansScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToReader;

  const ReadingPlansScreen({
    super.key,
    this.onNavigateToReader,
  });

  @override
  ConsumerState<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends ConsumerState<ReadingPlansScreen> {
  String _selectedCategory = 'ሁሉም';

  final List<String> _categories = [
    'ሁሉም',
    'ጾምና በዓላት',
    'ሐዲስ ኪዳን',
    'ጥበብና መዝሙር',
    'ዓመታዊ',
  ];

  IconData _getIconForName(String name) {
    switch (name) {
      case 'church':
        return Icons.church_outlined;
      case 'lightbulb':
        return Icons.lightbulb_outline_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'spa':
        return Icons.spa_outlined;
      case 'favorite':
        return Icons.favorite_border_rounded;
      case 'stars':
        return Icons.auto_awesome_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'visibility':
        return Icons.visibility_outlined;
      case 'menu_book':
        return Icons.menu_book_rounded;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  Future<void> _launchPlanPassageInReader(
    BuildContext context,
    ReadingPlan plan,
    DailyReadingPassage passage,
  ) async {
    ref.read(readingPlanSessionProvider.notifier).startReadingSession(plan, passage.day);

    final bibleState = ref.read(bibleStateProvider);
    final targetBook = CanonicalBookMap.resolveBook(
      books: bibleState.books,
      currentTranslationId: bibleState.currentTranslation?.id ?? 2,
      traditionalBookNumber: passage.bookNumber,
      bookName: passage.bookName,
    );

    if (targetBook != null) {
      await ref.read(bibleStateProvider.notifier).selectBook(
            targetBook,
            chapter: passage.startChapter,
          );
    }

    if (!context.mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Reader is Tab 0 in our Reader-first navigation shell
    widget.onNavigateToReader?.call(0);
  }

  void _showCustomPlanBuilderSheet(BuildContext context, ReaderThemeConfig themeConfig) {
    final titleController = TextEditingController();
    String selectedScope = 'GOSPELS';
    int selectedDays = 30;

    final scopes = [
      {'key': 'GOSPELS', 'label': 'አራቱ ወንጌላት (4 Gospels)'},
      {'key': 'NT', 'label': 'መላው ሐዲስ ኪዳን (New Testament)'},
      {'key': 'PSALMS_WISDOM', 'label': 'መዝሙርና ጥበብ (Psalms & Wisdom)'},
      {'key': 'PENTATEUCH', 'label': 'አምስቱ ብሔረ ኦሪት (Pentateuch)'},
      {'key': 'OT', 'label': 'ብሉይ ኪዳን (Old Testament)'},
      {'key': 'FULL', 'label': 'ሙሉ መጽሐፍ ቅዱስ (Full Bible)'},
    ];
    final dayOptions = [7, 14, 21, 30, 60, 90, 180, 365];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeConfig.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                16,
                22,
                MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: themeConfig.cardBorderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CUSTOM PLAN BUILDER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: themeConfig.accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'የራስዎን የንባብ ዕቅድ ይፍጠሩ',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.notoSansEthiopic(fontSize: 14, color: themeConfig.textColor),
                    decoration: InputDecoration(
                      labelText: 'የዕቅዱ ስም (Plan Title)',
                      hintText: 'ምሳሌ፦ የጠዋት የወንጌል ንባብ',
                      filled: true,
                      fillColor: themeConfig.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'የመጻሕፍት ክፍል ይምረጡ (Select Scope)፦',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: scopes.map((s) {
                      final isSelected = selectedScope == s['key'];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedScope = s['key']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? themeConfig.accentColor : themeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
                            ),
                          ),
                          child: Text(
                            s['label']!,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : themeConfig.textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'የቀናት ብዛት ይምረጡ (Duration in Days)፦',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dayOptions.map((d) {
                      final isSelected = selectedDays == d;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedDays = d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? themeConfig.goldAccent : themeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? themeConfig.goldAccent : themeConfig.cardBorderColor,
                            ),
                          ),
                          child: Text(
                            '$d ቀናት',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : themeConfig.textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeConfig.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final scopeLabel =
                          scopes.firstWhere((e) => e['key'] == selectedScope)['label']!;
                      final title = titleController.text.trim().isEmpty
                          ? '${scopeLabel.split(' (')[0]} በ$selectedDays ቀናት'
                          : titleController.text.trim();

                      await ref.read(readingPlanSessionProvider.notifier).createCustomPlan(
                            title: title,
                            scopeKey: selectedScope,
                            totalDays: selectedDays,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.add_task_rounded, size: 18),
                    label: Text(
                      'ዕቅዱን ፍጠርና ጀምር',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLiturgicalCalendarModal(
    BuildContext context,
    ReaderThemeConfig themeConfig,
    EthiopianDate ethDate,
    List<LiturgicalEvent> movableEvents,
    String evangelist,
    List<ReadingPlan> allPlans,
  ) {
    final ameteAlem = ethDate.year + 5500;
    final abektie = (ameteAlem % 19 * 11) % 30;
    final metqe = (abektie == 0) ? 30 : 30 - abektie;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: themeConfig.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: themeConfig.cardBorderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BAHIRE HASAB LITURGICAL CALENDAR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: themeConfig.goldAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'የባሕረ ሐሳብ አጽዋማትና በዓላት',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: themeConfig.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ethDate.year} ዓ.ም. • $evangelist • አበቅቴ፡ $abektie • መጥቅዕ፡ $metqe',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 11.5,
                                  color: themeConfig.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      itemCount: movableEvents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final event = movableEvents[idx];
                        final isFast = event.category == 'ጾም';
                        final matchingPlan = event.matchingPlanId != null
                            ? allPlans.where((p) => p.id == event.matchingPlanId).firstOrNull
                            : null;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: themeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFast
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                                  : themeConfig.goldAccent.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isFast
                                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                          : themeConfig.goldAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      event.category,
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isFast
                                            ? const Color(0xFF8B5CF6)
                                            : themeConfig.goldAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: themeConfig.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.event_outlined, size: 14, color: themeConfig.accentColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    event.date.format(),
                                    style: GoogleFonts.notoSansEthiopic(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: themeConfig.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.description,
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 12,
                                  color: themeConfig.secondaryTextColor,
                                  height: 1.4,
                                ),
                              ),
                              if (matchingPlan != null) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor: themeConfig.accentColor.withValues(alpha: 0.1),
                                      foregroundColor: themeConfig.accentColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _openPlanDetailModal(context, matchingPlan, themeConfig);
                                    },
                                    icon: const Icon(Icons.menu_book_rounded, size: 15),
                                    label: Text(
                                      'የ${matchingPlan.title} ዕቅድ ክፈት',
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final sessionState = ref.watch(readingPlanSessionProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;

    final allPlans = sessionState.allAvailablePlans;
    final liturgicalStatus = BahireHasabService.getCurrentLiturgicalStatus(DateTime.now());
    final EthiopianDate ethDate = liturgicalStatus['ethDate'];
    final String evangelist = liturgicalStatus['evangelist'];
    final String seasonTitle = liturgicalStatus['seasonTitle'];
    final String seasonCategory = liturgicalStatus['seasonCategory'];
    final String seasonDescription = liturgicalStatus['seasonDescription'];
    final String? recommendedPlanId = liturgicalStatus['recommendedPlanId'];
    final List<LiturgicalEvent> movableEvents = List<LiturgicalEvent>.from(liturgicalStatus['movableEvents']);

    var filteredPlans = _selectedCategory == 'ሁሉም'
        ? List<ReadingPlan>.from(allPlans)
        : allPlans.where((p) => p.category == _selectedCategory).toList();

    if (recommendedPlanId != null) {
      filteredPlans.sort((a, b) {
        if (a.id == recommendedPlanId) return -1;
        if (b.id == recommendedPlanId) return 1;
        return 0;
      });
    }

    int totalCompletedDays = 0;
    int activePlansCount = 0;
    for (final s in sessionState.completedDaysByPlan.values) {
      totalCompletedDays += s.length;
      if (s.isNotEmpty) activePlansCount++;
    }

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: sessionState.isLoading
          ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
          : SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // 1. Editorial Header + Create Custom Plan Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'READING PLANS & RHYTHMS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: themeConfig.accentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'የንባብ ዕቅዶች',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: themeConfig.textColor,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeConfig.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _showCustomPlanBuilderSheet(context, themeConfig),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              'ዕቅድ ፍጠር',
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Bahire Hasab Liturgical Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _showLiturgicalCalendarModal(
                          context,
                          themeConfig,
                          ethDate,
                          movableEvents,
                          evangelist,
                          allPlans,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: themeConfig.surfaceColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: themeConfig.goldAccent.withValues(alpha: 0.35),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeConfig.goldAccent.withValues(alpha: isDark ? 0.16 : 0.08),
                                themeConfig.surfaceColor,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: themeConfig.goldAccent.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_month_rounded,
                                          size: 13,
                                          color: themeConfig.goldAccent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'የባሕረ ሐሳብ ዘመን ቀመር',
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: themeConfig.goldAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: themeConfig.accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      evangelist,
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: themeConfig.accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ethDate.format(),
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w900,
                                            color: themeConfig.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$seasonTitle ($seasonCategory) • $seasonDescription',
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 12,
                                            color: themeConfig.secondaryTextColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: themeConfig.goldAccent,
                                      side: BorderSide(
                                        color: themeConfig.goldAccent.withValues(alpha: 0.5),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _showLiturgicalCalendarModal(
                                      context,
                                      themeConfig,
                                      ethDate,
                                      movableEvents,
                                      evangelist,
                                      allPlans,
                                    ),
                                    icon: const Icon(Icons.auto_stories_outlined, size: 15),
                                    label: Text(
                                      'አጽዋማት',
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Progress Summary Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeConfig.surfaceColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: themeConfig.cardBorderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: themeConfig.goldAccent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🔥 $activePlansCount በሂደት ላይ • ${allPlans.length} ዕቅዶች',
                                      style: GoogleFonts.notoSansEthiopic(
                                        color: themeConfig.goldAccent,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$totalCompletedDays ቀናት ተጠናቀዋል',
                                    style: GoogleFonts.notoSansEthiopic(
                                      color: themeConfig.textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ማንኛውንም ዕቅድ ሲጀምሩ በንባብ ገጹ ላይ ቀጥታ መከታተያ ይከፈታል።',
                                    style: GoogleFonts.notoSansEthiopic(
                                      color: themeConfig.secondaryTextColor,
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: themeConfig.accentColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_outlined,
                                color: themeConfig.accentColor,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Category Filter Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? themeConfig.textColor : themeConfig.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? themeConfig.textColor
                                      : themeConfig.cardBorderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? themeConfig.backgroundColor
                                        : themeConfig.textColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 4. Plans List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final plan = filteredPlans[index];
                          final completedSet =
                              sessionState.completedDaysByPlan[plan.id] ?? <int>{};
                          final progress = plan.totalDays > 0
                              ? (completedSet.length / plan.totalDays).clamp(0.0, 1.0)
                              : 0.0;

                          final isLiturgicalMatch = plan.id == recommendedPlanId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPlanCard(
                              context,
                              plan,
                              completedSet,
                              progress,
                              themeConfig,
                              isDark,
                              isLiturgicalMatch: isLiturgicalMatch,
                            ),
                          );
                        },
                        childCount: filteredPlans.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    ReadingPlan plan,
    Set<int> completedSet,
    double progress,
    ReaderThemeConfig themeConfig,
    bool isDark, {
    bool isLiturgicalMatch = false,
  }) {
    int nextDay = 1;
    for (int d = 1; d <= plan.totalDays; d++) {
      if (!completedSet.contains(d)) {
        nextDay = d;
        break;
      }
    }
    final nextPassage = plan.passages[(nextDay - 1).clamp(0, plan.passages.length - 1)];
    final isCustom = plan.id.startsWith('custom_');

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openPlanDetailModal(context, plan, themeConfig),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLiturgicalMatch
                ? themeConfig.goldAccent
                : themeConfig.cardBorderColor,
            width: isLiturgicalMatch ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getIconForName(plan.coverIcon),
                    color: themeConfig.accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLiturgicalMatch) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: themeConfig.goldAccent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars_rounded, size: 12, color: themeConfig.goldAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    'ወቅታዊ ዕቅድ',
                                    style: GoogleFonts.notoSansEthiopic(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: themeConfig.goldAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeConfig.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.badgeText,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.accentColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isCustom)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.redAccent),
                              onPressed: () {
                                ref
                                    .read(readingPlanSessionProvider.notifier)
                                    .deleteCustomPlan(plan.id);
                              },
                            )
                          else
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: progress > 0
                                    ? const Color(0xFF10B981)
                                    : themeConfig.secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.title,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: themeConfig.textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.subtitle,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 12.5,
                          color: themeConfig.secondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: themeConfig.cardBorderColor,
                valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ቀጣይ፦ ቀን $nextDay (${nextPassage.passageReference})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeConfig.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _launchPlanPassageInReader(context, plan, nextPassage),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(
                    completedSet.isEmpty ? 'ጀምር' : 'ቀጥል (ቀን $nextDay)',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openPlanDetailModal(
    BuildContext context,
    ReadingPlan plan,
    ReaderThemeConfig themeConfig,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final sessionState = ref.watch(readingPlanSessionProvider);
            final completedSet = sessionState.completedDaysByPlan[plan.id] ?? <int>{};

            return DraggableScrollableSheet(
              initialChildSize: 0.84,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: themeConfig.backgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: themeConfig.cardBorderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.title,
                                    style: GoogleFonts.notoSansEthiopic(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: themeConfig.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${completedSet.length} ከ ${plan.totalDays} ቀናት ተጠናቋል',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: themeConfig.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(18),
                          itemCount: plan.passages.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final passage = plan.passages[idx];
                            final isDone = completedSet.contains(passage.day);

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeConfig.surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDone
                                      ? const Color(0xFF10B981).withValues(alpha: 0.45)
                                      : themeConfig.cardBorderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      ref
                                          .read(readingPlanSessionProvider.notifier)
                                          .toggleDayComplete(plan.id, passage.day);
                                    },
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? const Color(0xFF10B981)
                                            : themeConfig.accentColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: isDone
                                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                                            : Text(
                                                '${passage.day}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                  color: themeConfig.accentColor,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          passage.title,
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.5,
                                            color: themeConfig.textColor,
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          passage.passageReference,
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: themeConfig.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _launchPlanPassageInReader(context, plan, passage);
                                    },
                                    icon: const Icon(Icons.menu_book_rounded, size: 15),
                                    label: Text(
                                      'አንብብ',
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
