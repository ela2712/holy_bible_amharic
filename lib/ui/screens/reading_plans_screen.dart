import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../data/reading_plans_data.dart';
import '../../models/reading_plan.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';

class ReadingPlansScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToReader;

  const ReadingPlansScreen({
    super.key,
    this.onNavigateToReader,
  });

  @override
  ConsumerState<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends ConsumerState<ReadingPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Set<int>> _completedDaysByPlan = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'ሁሉም',
    'ጾምና በዓላት',
    'ሐዲስ ኪዳን',
    'ጥበብና መዝሙር',
    'ዓመታዊ',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadAllPlansProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPlansProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final plan in ReadingPlansData.allPlans) {
      final key = 'plan_${plan.id}_completed';
      final completed = prefs.getStringList(key) ?? [];
      _completedDaysByPlan[plan.id] = completed.map((e) => int.tryParse(e) ?? 0).toSet();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleDayComplete(String planId, int day) async {
    final prefs = await SharedPreferences.getInstance();
    final planSet = _completedDaysByPlan[planId] ?? <int>{};

    setState(() {
      if (planSet.contains(day)) {
        planSet.remove(day);
      } else {
        planSet.add(day);
      }
      _completedDaysByPlan[planId] = planSet;
    });

    await prefs.setStringList(
      'plan_${planId}_completed',
      planSet.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'የመንፈሳዊ ንባብ ዕቅዶች',
              style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Liturgical & Devotional Reading Plans',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: themeConfig.accentColor,
          labelColor: themeConfig.accentColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final plans = category == 'ሁሉም'
                    ? ReadingPlansData.allPlans
                    : ReadingPlansData.allPlans.where((p) => p.category == category).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Spotlight Banner
                    if (category == 'ሁሉም') ...[
                      _buildHeaderBanner(context, themeConfig, isDark),
                      const SizedBox(height: 18),
                    ],

                    // Plans List
                    ...plans.map((plan) => _buildPlanCard(context, plan, themeConfig, isDark)),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, ReaderThemeConfig themeConfig, bool isDark) {
    int totalCompleted = 0;
    int totalTarget = 0;
    for (final plan in ReadingPlansData.allPlans) {
      totalCompleted += (_completedDaysByPlan[plan.id]?.length ?? 0);
      totalTarget += plan.totalDays;
    }
    final overallRatio = totalTarget > 0 ? (totalCompleted / totalTarget) : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1810), Color(0xFF7D1A25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_stories, color: Color(0xFFFFD54F), size: 22),
              SizedBox(width: 8),
              Text(
                'የ10 የተመረጡ የንባብ ዕቅዶች ማህደር',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ከታላቁ ጾመ ሁዳዴ እስከ ሰሙነ ሕማማት፣ ከመጽሐፈ ምሳሌ እስከ ሐዲስ ኪዳን የተዘጋጁ ሥርዓተ ንባባት።',
            style: GoogleFonts.notoSansEthiopic(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallRatio,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'አጠቃላይ የተጠናቀቁ ንባቦች፦ $totalCompleted ቀናት (${(overallRatio * 100).toStringAsFixed(1)}%)',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    ReadingPlan plan,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final completedDays = _completedDaysByPlan[plan.id] ?? <int>{};
    final progress = plan.totalDays > 0 ? (completedDays.length / plan.totalDays) : 0.0;
    final isDone = completedDays.length >= plan.totalDays && plan.totalDays > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone
              ? Colors.green.withValues(alpha: 0.5)
              : const Color(0xFFC5A059).withValues(alpha: 0.25),
        ),
      ),
      color: themeConfig.surfaceColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPlanDetailModal(context, plan, themeConfig, isDark),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category tag + Days badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D1A25).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan.category,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7D1A25),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan.badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A641A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title and Subtitle
              Text(
                plan.title,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeConfig.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan.subtitle,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 12.5,
                  height: 1.45,
                  color: themeConfig.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 14),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? Colors.green : const Color(0xFF7D1A25),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Bottom status and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${completedDays.length} / ${plan.totalDays} ቀናት ተጠናቀዋል (${(progress * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isDone ? 'ተጠናቋል' : 'ዕቅዱን ክፈት',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7D1A25),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF7D1A25)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlanDetailModal(
    BuildContext context,
    ReadingPlan plan,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final completedDays = _completedDaysByPlan[plan.id] ?? <int>{};
            final progress = plan.totalDays > 0 ? (completedDays.length / plan.totalDays) : 0.0;

            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF191716) : const Color(0xFFFAF8F5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Column(
                    children: [
                      // Drag Bar
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Plan Modal Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.title,
                                    style: GoogleFonts.notoSansEthiopic(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF7D1A25),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${plan.category} • ${plan.totalDays} ቀናት',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeConfig.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Progress Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF24201E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'የእድገት ደረጃ (Progress)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeConfig.textColor),
                                  ),
                                  Text(
                                    '${completedDays.length} / ${plan.totalDays} ቀናት (${(progress * 100).toStringAsFixed(0)}%)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7D1A25)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: Colors.black12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7D1A25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),

                      // Daily Passage List
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: plan.passages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final passage = plan.passages[idx];
                            final isCompleted = completedDays.contains(passage.day);

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF221F1D) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCompleted
                                      ? Colors.green.withValues(alpha: 0.4)
                                      : Colors.black12,
                                ),
                              ),
                              child: ListTile(
                                leading: InkWell(
                                  onTap: () async {
                                    await _toggleDayComplete(plan.id, passage.day);
                                    setModalState(() {});
                                  },
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isCompleted
                                        ? Colors.green
                                        : themeConfig.accentColor.withValues(alpha: 0.12),
                                    foregroundColor: isCompleted ? Colors.white : themeConfig.accentColor,
                                    child: isCompleted
                                        ? const Icon(Icons.check, size: 18)
                                        : Text(
                                            '${passage.day}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  passage.passageReference,
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Text(
                                  passage.title,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7D1A25),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    minimumSize: const Size(0, 30),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    final bibleState = ref.read(bibleStateProvider);
                                    final targetBook = bibleState.books.firstWhere(
                                      (b) => b.bookNumber == passage.bookNumber,
                                      orElse: () => bibleState.books.first,
                                    );
                                    await ref.read(bibleStateProvider.notifier).selectBook(
                                          targetBook,
                                          chapter: passage.startChapter,
                                        );
                                    if (widget.onNavigateToReader != null) {
                                      widget.onNavigateToReader!(1);
                                    }
                                  },
                                  child: const Text('አንብብ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                ),
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
