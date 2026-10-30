import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../models/reading_plan.dart';
import '../../providers/app_language_provider.dart';
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
  int _selectedCategoryIndex = 0;

  static const List<String> _categoriesAm = [
    'ሁሉም',
    'የኢ/ኦ/ተ/ቤ/ክ ቀኖና',
    'ጾምና በዓላት',
    'ሐዲስ ኪዳን',
    'ጥበብና መዝሙር',
    'ዓመታዊ',
  ];

  static const List<String> _categoriesEn = [
    'All',
    'EOTC Canon',
    'Fasts & Feasts',
    'New Testament',
    'Wisdom & Psalms',
    'Annual',
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
      canonicalId: passage.canonicalId.isNotEmpty ? passage.canonicalId : null,
      bookName: passage.bookName,
    );

    // Jump straight to the first unread chapter of this day
    final readSet = ref.read(readingPlanSessionProvider).getReadChapters(plan.id, passage.day);
    int targetChapter = passage.startChapter;
    for (int ch = passage.startChapter; ch <= passage.endChapter; ch++) {
      if (!readSet.contains(ch)) {
        targetChapter = ch;
        break;
      }
    }

    if (targetBook != null) {
      await ref.read(bibleStateProvider.notifier).selectBook(
            targetBook,
            chapter: targetChapter,
          );
    }

    if (!context.mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Reader is Tab 0 in our Reader-first navigation shell
    widget.onNavigateToReader?.call(0);
  }

  Future<void> _confirmResetPlan(
    BuildContext context,
    ReadingPlan plan,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: themeConfig.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnglish ? 'Reset Reading Plan?' : 'ዕቅዱን እንደገና መጀመር ይፈልጋሉ?',
                  style: isEnglish
                      ? GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w800, color: themeConfig.textColor)
                      : GoogleFonts.notoSansEthiopic(fontSize: 16.5, fontWeight: FontWeight.w800, color: themeConfig.textColor),
                ),
              ),
            ],
          ),
          content: Text(
            isEnglish
                ? 'Are you sure you want to restart "${plan.getDisplayTitle(true)}"? All completed days and read chapters will be reset back to Day 1.'
                : 'የ"${plan.getDisplayTitle(false)}" ዕቅድን እንደገና መጀመር ይፈልጋሉ? የተጠናቀቁት ቀናትና የተነበቡት ምዕራፎች በሙሉ ተሰርዘው ከቀን ፩ (1) ይጀምራል።',
            style: isEnglish
                ? GoogleFonts.inter(fontSize: 13, color: themeConfig.secondaryTextColor, height: 1.45)
                : GoogleFonts.notoSansEthiopic(fontSize: 13, color: themeConfig.secondaryTextColor, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                isEnglish ? 'Cancel' : 'ይቅር',
                style: isEnglish
                    ? GoogleFonts.inter(fontWeight: FontWeight.w700, color: themeConfig.secondaryTextColor)
                    : GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, color: themeConfig.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                isEnglish ? 'Reset to Day 1' : 'እንደገና ጀምር',
                style: isEnglish
                    ? GoogleFonts.inter(fontWeight: FontWeight.w800)
                    : GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(readingPlanSessionProvider.notifier).resetPlan(plan.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish
                ? '"${plan.getDisplayTitle(true)}" has been reset to Day 1.'
                : 'የ"${plan.getDisplayTitle(false)}" ዕቅድ ከቀን ፩ እንደገና ተጀምሯል።',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCustomPlanBuilderSheet(
    BuildContext context,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) {
    final titleController = TextEditingController();
    String selectedScope = 'GOSPELS';
    int selectedDays = 30;

    final scopes = [
      {
        'key': 'GOSPELS',
        'label': isEnglish ? 'Four Gospels' : 'አራቱ ወንጌላት',
      },
      {
        'key': 'NT',
        'label': isEnglish ? 'New Testament' : 'መላው ሐዲስ ኪዳን',
      },
      {
        'key': 'PSALMS_WISDOM',
        'label': isEnglish ? 'Psalms & Wisdom' : 'መዝሙርና ጥበብ',
      },
      {
        'key': 'PENTATEUCH',
        'label': isEnglish ? 'Pentateuch (Torah)' : 'አምስቱ ብሔረ ኦሪት',
      },
      {
        'key': 'OT',
        'label': isEnglish ? 'Old Testament' : 'ብሉይ ኪዳን',
      },
      {
        'key': 'FULL',
        'label': isEnglish ? 'Full Bible' : 'ሙሉ መጽሐፍ ቅዱስ',
      },
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
                    isEnglish ? 'CUSTOM PLAN BUILDER' : 'የግል ዕቅድ አዘጋጅ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: themeConfig.accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnglish ? 'Create Your Reading Plan' : 'የራስዎን የንባብ ዕቅድ ይፍጠሩ',
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: themeConfig.textColor,
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: isEnglish
                        ? GoogleFonts.inter(fontSize: 14, color: themeConfig.textColor)
                        : GoogleFonts.notoSansEthiopic(fontSize: 14, color: themeConfig.textColor),
                    decoration: InputDecoration(
                      labelText: isEnglish ? 'Plan Title' : 'የዕቅዱ ስም',
                      hintText: isEnglish ? 'e.g., Morning Gospels Reading' : 'ምሳሌ፦ የጠዋት የወንጌል ንባብ',
                      filled: true,
                      fillColor: themeConfig.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnglish ? 'Select Scope:' : 'የመጻሕፍት ክፍል ይምረጡ፦',
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
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
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
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
                    isEnglish ? 'Duration in Days:' : 'የቀናት ብዛት ይምረጡ፦',
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
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
                            isEnglish ? '$d Days' : '$d ቀናት',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
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
                          ? (isEnglish ? '$scopeLabel in $selectedDays Days' : '$scopeLabel በ$selectedDays ቀናት')
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
                      isEnglish ? 'Create & Start Plan' : 'ዕቅዱን ፍጠርና ጀምር',
                      style: isEnglish
                          ? GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            )
                          : GoogleFonts.notoSansEthiopic(
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
    String evangelistEn,
    List<ReadingPlan> allPlans,
    bool isEnglish,
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
                                isEnglish ? 'BAHIRE HASAB LITURGICAL CALENDAR' : 'የባሕረ ሐሳብ ዘመን ቀመር',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: themeConfig.goldAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEnglish ? 'Liturgical Feasts & Fasts' : 'የባሕረ ሐሳብ አጽዋማትና በዓላት',
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: themeConfig.textColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: themeConfig.textColor,
                                      ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEnglish
                                    ? '${ethDate.year} E.C. • $evangelistEn • Abektie: $abektie • Metqe: $metqe'
                                    : '${ethDate.year} ዓ.ም. • $evangelist • አበቅቴ፡ $abektie • መጥቅዕ፡ $metqe',
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: themeConfig.secondaryTextColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
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
                                      event.getDisplayCategory(isEnglish),
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: isFast
                                                  ? const Color(0xFF8B5CF6)
                                                  : themeConfig.goldAccent,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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
                                      event.getDisplayTitle(isEnglish),
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: themeConfig.textColor,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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
                                    event.date.format(isEnglish: isEnglish),
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: themeConfig.accentColor,
                                          )
                                        : GoogleFonts.notoSansEthiopic(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: themeConfig.accentColor,
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.getDisplayDescription(isEnglish),
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 12,
                                        color: themeConfig.secondaryTextColor,
                                        height: 1.4,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
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
                                      _openPlanDetailModal(context, matchingPlan, themeConfig, isEnglish);
                                    },
                                    icon: const Icon(Icons.menu_book_rounded, size: 15),
                                    label: Text(
                                      isEnglish
                                          ? 'Open ${matchingPlan.getDisplayTitle(true)}'
                                          : 'የ${matchingPlan.getDisplayTitle(false)} ዕቅድ ክፈት',
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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

  Widget _buildActivePlanBanner(
    BuildContext context,
    ReadingPlanSessionState sessionState,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final plan = sessionState.activeSessionPlan!;
    final passage = sessionState.activePassage!;
    final day = sessionState.activeSessionDay ?? 1;
    final isDayDone = sessionState.isDayCompleted(plan.id, day);
    final completedDays = sessionState.completedDaysByPlan[plan.id] ?? <int>{};
    final progress = (completedDays.length / plan.totalDays).clamp(0.0, 1.0);
    final totalChs = (passage.endChapter - passage.startChapter + 1).clamp(1, 150);
    final readChs = sessionState.getReadChapters(plan.id, day);
    final readCount = readChs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDayDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isDayDone ? const Color(0xFF10B981) : themeConfig.goldAccent)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDayDone ? Icons.check_circle_rounded : Icons.local_fire_department_rounded,
                        size: 14,
                        color: isDayDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isEnglish ? 'Active Reading Session' : 'በሂደት ላይ ያለ ንባብ',
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDayDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDayDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
                              ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.restart_alt_rounded, size: 20, color: Colors.redAccent),
                  tooltip: isEnglish ? 'Reset Plan to Day 1' : 'ዕቅዱን እንደገና ጀምር',
                  onPressed: () => _confirmResetPlan(context, plan, themeConfig, isEnglish),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 18, color: themeConfig.secondaryTextColor),
                  tooltip: isEnglish ? 'Pause Session' : 'ዕቅድ አቁም',
                  onPressed: () {
                    ref.read(readingPlanSessionProvider.notifier).clearActiveSession();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plan.getDisplayTitle(isEnglish),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.textColor,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.textColor,
                    ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  isEnglish
                      ? 'Day $day of ${plan.totalDays} • ${passage.getPassageReference(true)}'
                      : 'ቀን $day ከ ${plan.totalDays} • ${passage.getPassageReference(false)}',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: themeConfig.accentColor,
                  ),
                ),
                if (totalChs > 1) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (readCount >= totalChs ? const Color(0xFF10B981) : themeConfig.goldAccent)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isEnglish ? '$readCount/$totalChs read' : '$readCount/$totalChs ተነቧል',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: readCount >= totalChs ? const Color(0xFF10B981) : themeConfig.goldAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: themeConfig.cardBorderColor.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? const Color(0xFF10B981) : themeConfig.accentColor,
                ),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeConfig.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _launchPlanPassageInReader(context, plan, passage),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      isEnglish ? 'Continue Reading' : 'ንባቡን ቀጥል',
                      style: isEnglish
                          ? GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)
                          : GoogleFonts.notoSansEthiopic(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeConfig.textColor,
                    side: BorderSide(color: themeConfig.cardBorderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _openPlanDetailModal(context, plan, themeConfig, isEnglish),
                  child: Text(
                    isEnglish ? 'Plan Details' : 'ዝርዝር',
                    style: isEnglish
                        ? GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)
                        : GoogleFonts.notoSansEthiopic(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final sessionState = ref.watch(readingPlanSessionProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);

    final allPlans = sessionState.allAvailablePlans;
    final liturgicalStatus = BahireHasabService.getCurrentLiturgicalStatus(DateTime.now());
    final EthiopianDate ethDate = (liturgicalStatus['ethDate'] as EthiopianDate?) ??
        BahireHasabService.fromGregorian(DateTime.now());
    final String evangelist = (liturgicalStatus['evangelist'] as String?) ?? 'ዘመነ ማቴዎስ';
    final String evangelistEn = (liturgicalStatus['evangelistEn'] as String?) ?? evangelist;
    final String seasonTitle = (liturgicalStatus['seasonTitle'] as String?) ?? 'ዘመነ ጽጌ';
    final String seasonTitleEn = (liturgicalStatus['seasonTitleEn'] as String?) ?? seasonTitle;
    final String seasonCategory = (liturgicalStatus['seasonCategory'] as String?) ?? 'ወቅት';
    final String seasonCategoryEn = (liturgicalStatus['seasonCategoryEn'] as String?) ?? 'Season';
    final String seasonDescription = (liturgicalStatus['seasonDescription'] as String?) ?? '';
    final String seasonDescriptionEn = (liturgicalStatus['seasonDescriptionEn'] as String?) ?? seasonDescription;
    final String? recommendedPlanId = liturgicalStatus['recommendedPlanId'] as String?;
    final List<LiturgicalEvent> movableEvents = liturgicalStatus['movableEvents'] != null
        ? List<LiturgicalEvent>.from(liturgicalStatus['movableEvents'] as Iterable)
        : <LiturgicalEvent>[];

    final filteredPlans = _selectedCategoryIndex == 0
        ? List<ReadingPlan>.from(allPlans)
        : allPlans.where((p) {
            switch (_selectedCategoryIndex) {
              case 1:
                return p.category == 'የኢ/ኦ/ተ/ቤ/ክ ቀኖና' || p.categoryEn == 'EOTC Canon';
              case 2:
                return p.category == 'ጾምና በዓላት' || p.categoryEn == 'Fasts & Feasts';
              case 3:
                return p.category == 'ሐዲስ ኪዳን' || p.categoryEn == 'New Testament';
              case 4:
                return p.category == 'ጥበብና መዝሙር' || p.categoryEn == 'Wisdom & Psalms';
              case 5:
                return p.category == 'ዓመታዊ' || p.categoryEn == 'Annual';
              default:
                return true;
            }
          }).toList();

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

    final categories = isEnglish ? _categoriesEn : _categoriesAm;

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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEnglish ? 'Reading Plans' : 'የንባብ ዕቅዶች',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeConfig.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _showCustomPlanBuilderSheet(context, themeConfig, isEnglish),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              isEnglish ? 'Create Plan' : 'ዕቅድ ፍጠር',
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 1.5 Active Plan In-Progress Banner
                  if (sessionState.activeSessionPlan != null && sessionState.activePassage != null)
                    SliverToBoxAdapter(
                      child: _buildActivePlanBanner(
                        context,
                        sessionState,
                        themeConfig,
                        isDark,
                        isEnglish,
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
                          evangelistEn,
                          allPlans,
                          isEnglish,
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
                                          isEnglish ? 'Bahire Hasab Calendar' : 'የባሕረ ሐሳብ ዘመን ቀመር',
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: themeConfig.goldAccent,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
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
                                      isEnglish ? evangelistEn : evangelist,
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: themeConfig.accentColor,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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
                                          ethDate.format(isEnglish: isEnglish),
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontSize: 16.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: themeConfig.textColor,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
                                                  fontSize: 16.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: themeConfig.textColor,
                                                ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isEnglish
                                              ? '$seasonTitleEn ($seasonCategoryEn) • $seasonDescriptionEn'
                                              : '$seasonTitle ($seasonCategory) • $seasonDescription',
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: themeConfig.secondaryTextColor,
                                                  height: 1.4,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
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
                                      evangelistEn,
                                      allPlans,
                                      isEnglish,
                                    ),
                                    icon: const Icon(Icons.auto_stories_outlined, size: 15),
                                    label: Text(
                                      isEnglish ? 'Feasts' : 'አጽዋማት',
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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
                                      isEnglish
                                          ? '🔥 $activePlansCount in progress • ${allPlans.length} plans'
                                          : '🔥 $activePlansCount በሂደት ላይ • ${allPlans.length} ዕቅዶች',
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              color: themeConfig.goldAccent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.5,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
                                              color: themeConfig.goldAccent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.5,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    isEnglish
                                        ? '$totalCompletedDays days completed'
                                        : '$totalCompletedDays ቀናት ተጠናቀዋል',
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            color: themeConfig.textColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          )
                                        : GoogleFonts.notoSansEthiopic(
                                            color: themeConfig.textColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isEnglish
                                        ? 'Starting any plan opens direct tracking on the reader screen.'
                                        : 'ማንኛውንም ዕቅድ ሲጀምሩ በንባብ ገጹ ላይ ቀጥታ መከታተያ ይከፈታል።',
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            color: themeConfig.secondaryTextColor,
                                            fontSize: 12,
                                            height: 1.45,
                                          )
                                        : GoogleFonts.notoSansEthiopic(
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

                  // 4. Category Filter Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryIndex = index),
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
                                  style: isEnglish
                                      ? GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? themeConfig.backgroundColor
                                              : themeConfig.textColor,
                                        )
                                      : GoogleFonts.notoSansEthiopic(
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

                  // 5. Plans List
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
                              isEnglish,
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
    bool isDark,
    bool isEnglish, {
    bool isLiturgicalMatch = false,
  }) {
    int nextDay = 1;
    for (int d = 1; d <= plan.totalDays; d++) {
      if (!completedSet.contains(d)) {
        nextDay = d;
        break;
      }
    }
    final nextPassage = plan.passages.isNotEmpty
        ? plan.passages[(nextDay - 1).clamp(0, plan.passages.length - 1)]
        : null;
    final isCustom = plan.id.startsWith('custom_');

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openPlanDetailModal(context, plan, themeConfig, isEnglish),
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
                                    isEnglish ? 'Current Season' : 'ወቅታዊ ዕቅድ',
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: themeConfig.goldAccent,
                                          )
                                        : GoogleFonts.notoSansEthiopic(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: themeConfig.goldAccent,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeConfig.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan.getDisplayBadge(isEnglish),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: themeConfig.accentColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: themeConfig.accentColor,
                                      ),
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
                        plan.getDisplayTitle(isEnglish),
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                              ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.getDisplaySubtitle(isEnglish),
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 12.5,
                                color: themeConfig.secondaryTextColor,
                                height: 1.4,
                              )
                            : GoogleFonts.notoSansEthiopic(
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
                    nextPassage != null
                        ? (isEnglish
                            ? 'Next: Day $nextDay (${nextPassage.getPassageReference(true)})'
                            : 'ቀጣይ፦ ቀን $nextDay (${nextPassage.getPassageReference(false)})')
                        : (isEnglish ? 'Day $nextDay' : 'ቀን $nextDay'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: themeConfig.secondaryTextColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
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
                  onPressed: nextPassage != null
                      ? () => _launchPlanPassageInReader(context, plan, nextPassage)
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(
                    completedSet.isEmpty
                        ? (isEnglish ? 'Start' : 'ጀምር')
                        : (isEnglish ? 'Resume (Day $nextDay)' : 'ቀጥል (ቀን $nextDay)'),
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          )
                        : GoogleFonts.notoSansEthiopic(
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
    bool isEnglish,
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
                                    plan.getDisplayTitle(isEnglish),
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: themeConfig.textColor,
                                          )
                                        : GoogleFonts.notoSansEthiopic(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: themeConfig.textColor,
                                          ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isEnglish
                                        ? '${completedSet.length} of ${plan.totalDays} days completed'
                                        : '${completedSet.length} ከ ${plan.totalDays} ቀናት ተጠናቋል',
                                    style: isEnglish
                                        ? GoogleFonts.inter(
                                            fontSize: 12.5,
                                            color: themeConfig.secondaryTextColor,
                                          )
                                        : TextStyle(
                                            fontSize: 12.5,
                                            color: themeConfig.secondaryTextColor,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            if (completedSet.isNotEmpty || sessionState.getReadChaptersCount(plan.id, 1) > 0)
                              IconButton(
                                icon: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 22),
                                tooltip: isEnglish ? 'Reset Plan to Day 1' : 'ዕቅዱን እንደገና ጀምር',
                                onPressed: () => _confirmResetPlan(context, plan, themeConfig, isEnglish),
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
                                          isEnglish && passage.titleEn.isNotEmpty
                                              ? passage.titleEn
                                              : passage.title,
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13.5,
                                                  color: themeConfig.textColor,
                                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13.5,
                                                  color: themeConfig.textColor,
                                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                                ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          passage.getPassageReference(isEnglish),
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: themeConfig.accentColor,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: themeConfig.accentColor,
                                                ),
                                        ),
                                        if (!isDone && (passage.endChapter - passage.startChapter + 1) > 1)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              isEnglish
                                                  ? '${sessionState.getReadChaptersCount(plan.id, passage.day)} of ${passage.endChapter - passage.startChapter + 1} chapters read'
                                                  : '${sessionState.getReadChaptersCount(plan.id, passage.day)} ከ ${passage.endChapter - passage.startChapter + 1} ምዕራፎች ተነበዋል',
                                              style: GoogleFonts.notoSansEthiopic(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: sessionState.getReadChaptersCount(plan.id, passage.day) > 0
                                                    ? themeConfig.goldAccent
                                                    : themeConfig.secondaryTextColor,
                                              ),
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
                                      isEnglish ? 'Read' : 'አንብብ',
                                      style: isEnglish
                                          ? GoogleFonts.inter(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            )
                                          : GoogleFonts.notoSansEthiopic(
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
