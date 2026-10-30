import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../models/verse.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';

enum ParallelViewFilter {
  allFour,
  eotcAndGeez,
  eotcAnd1954,
  eotcAndKjv,
  haileselassieAndKjv,
}

class _AlignedParallelVerse {
  final String label;
  final int verseNumber;
  final String? text81;
  final String? textGeez;
  final String? text1954;
  final String? textKjv;

  const _AlignedParallelVerse({
    required this.label,
    required this.verseNumber,
    this.text81,
    this.textGeez,
    this.text1954,
    this.textKjv,
  });
}

class ParallelReaderScreen extends ConsumerStatefulWidget {
  final int? initialBookNumber;
  final int? initialChapter;
  final int? initialTargetVerse;
  final int? initialTranslationId;

  const ParallelReaderScreen({
    super.key,
    this.initialBookNumber,
    this.initialChapter,
    this.initialTargetVerse,
    this.initialTranslationId,
  });

  @override
  ConsumerState<ParallelReaderScreen> createState() => _ParallelReaderScreenState();
}

class _ParallelReaderScreenState extends ConsumerState<ParallelReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  ParallelViewFilter _selectedFilter = ParallelViewFilter.allFour;
  List<_AlignedParallelVerse> _alignedVerses = [];
  bool _hasGeezBook = true;
  bool _has1954Book = true;
  bool _hasKjvBook = true;
  bool _isLoading = true;
  String _customBookTitle = '';
  int _activeChapter = 1;

  @override
  void initState() {
    super.initState();
    _loadAllParallelVerses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllParallelVerses() async {
    setState(() => _isLoading = true);
    final bibleState = ref.read(bibleStateProvider);
    final repo = ref.read(bibleRepositoryProvider);
    final targetTransId = widget.initialTranslationId ?? (bibleState.currentTranslation?.id ?? 2);
    final targetBookNum = widget.initialBookNumber ?? (bibleState.currentBook?.bookNumber ?? 1);
    final targetChapter = widget.initialChapter ?? bibleState.currentChapter;
    _activeChapter = targetChapter;

    final isEnglish = ref.read(isEnglishUiProvider);
    final currentBook = await repo.getBookByNumber(targetTransId, targetBookNum) ?? bibleState.currentBook;
    _customBookTitle = currentBook?.getDisplayName(isEnglish) ?? (isEnglish ? 'Scripture' : 'መጽሐፍ');

    final canonId = CanonicalBookMap.getCanonicalId(targetTransId, targetBookNum);

    // Resolve book numbers across all 4 canons
    final bookNum81 = CanonicalBookMap.getBookNumber(2, canonId) ?? (targetTransId == 2 ? targetBookNum : null);
    final bookNumGeez = CanonicalBookMap.getBookNumber(4, canonId) ?? (targetTransId == 4 ? targetBookNum : null);
    final bookNum1954 = CanonicalBookMap.getBookNumber(1, canonId) ?? (targetTransId == 1 ? targetBookNum : null);
    final bookNumKjv = CanonicalBookMap.getBookNumber(3, canonId) ?? (targetTransId == 3 ? targetBookNum : null);

    List<Verse> verses81 = [];
    List<Verse> versesGeez = [];
    List<Verse> verses1954 = [];
    List<Verse> versesKjv = [];
    bool hasGeez = bookNumGeez != null;
    bool has1954 = bookNum1954 != null;
    bool hasKjv = bookNumKjv != null;

    final futures = <Future<void>>[];

    // 1. Fetch 81 Canon (ID: 2)
    if (bookNum81 != null) {
      futures.add(() async {
        try {
          final b = await repo.getBookByNumber(2, bookNum81);
          if (b != null) {
            final ch = targetChapter.clamp(1, b.totalChapters);
            verses81 = await repo.getVerses(bookId: b.id, chapter: ch);
          }
        } catch (_) {}
      }());
    }

    // 2. Fetch Ge'ez 81 Canon (ID: 4)
    if (bookNumGeez != null) {
      futures.add(() async {
        try {
          final b = await repo.getBookByNumber(4, bookNumGeez);
          if (b != null) {
            final ch = targetChapter.clamp(1, b.totalChapters);
            versesGeez = await repo.getVerses(bookId: b.id, chapter: ch);
          } else {
            hasGeez = false;
          }
        } catch (_) {
          hasGeez = false;
        }
      }());
    } else {
      hasGeez = false;
    }

    // 3. Fetch 1954 Translation (ID: 1)
    if (bookNum1954 != null) {
      futures.add(() async {
        try {
          final b = await repo.getBookByNumber(1, bookNum1954);
          if (b != null) {
            final ch = targetChapter.clamp(1, b.totalChapters);
            verses1954 = await repo.getVerses(bookId: b.id, chapter: ch);
          } else {
            has1954 = false;
          }
        } catch (_) {
          has1954 = false;
        }
      }());
    } else {
      has1954 = false;
    }

    // 4. Fetch KJV Translation (ID: 3)
    if (bookNumKjv != null) {
      futures.add(() async {
        try {
          final b = await repo.getBookByNumber(3, bookNumKjv);
          if (b != null) {
            final ch = targetChapter.clamp(1, b.totalChapters);
            versesKjv = await repo.getVerses(bookId: b.id, chapter: ch);
          } else {
            hasKjv = false;
          }
        } catch (_) {
          hasKjv = false;
        }
      }());
    } else {
      hasKjv = false;
    }

    await Future.wait(futures);

    // Build 100% aligned parallel verse rows
    final aligned = <_AlignedParallelVerse>[];
    if (verses81.isNotEmpty) {
      for (final v81 in verses81) {
        final startV = v81.verse;
        final endV = v81.verseEnd ?? v81.verse;
        final label = v81.isMergedRange
            ? (isEnglish ? 'Verses $startV–$endV' : 'ቁጥር $startV–$endV')
            : (isEnglish ? 'Verse $startV' : 'ቁጥር $startV');

        // Match Ge'ez
        final matchGeez = versesGeez.where((v) =>
            (v.verse >= startV && v.verse <= endV) ||
            (v.verseEnd != null && v.verse <= endV && v.verseEnd! >= startV)).toList();
        final textGeez = matchGeez.isNotEmpty
            ? matchGeez.map((v) => v.text).join(' ')
            : (hasGeez ? versesGeez.where((v) => v.verse == startV).firstOrNull?.text : null);

        // Match 1954
        final match1954 = verses1954.where((v) =>
            (v.verse >= startV && v.verse <= endV) ||
            (v.verseEnd != null && v.verse <= endV && v.verseEnd! >= startV)).toList();
        final text1954 = match1954.isNotEmpty
            ? match1954.map((v) => v.text).join(' ')
            : (has1954 ? verses1954.where((v) => v.verse == startV).firstOrNull?.text : null);

        // Match KJV
        final matchKjv = versesKjv.where((v) =>
            v.verse >= startV && v.verse <= endV).toList();
        final textKjv = matchKjv.isNotEmpty
            ? matchKjv.map((v) => v.text).join(' ')
            : (hasKjv ? versesKjv.where((v) => v.verse == startV).firstOrNull?.text : null);

        aligned.add(_AlignedParallelVerse(
          label: label,
          verseNumber: startV,
          text81: v81.text,
          textGeez: textGeez,
          text1954: text1954,
          textKjv: textKjv,
        ));
      }
    } else {
      final primary = versesGeez.isNotEmpty
          ? versesGeez
          : (verses1954.isNotEmpty ? verses1954 : versesKjv);
      for (final p in primary) {
        final label = isEnglish ? 'Verse ${p.verse}' : 'ቁጥር ${p.verse}';
        final textGeez = versesGeez.where((v) => v.verse == p.verse).firstOrNull?.text;
        final text1954 = verses1954.where((v) => v.verse == p.verse).firstOrNull?.text;
        final textKjv = versesKjv.where((v) => v.verse == p.verse).firstOrNull?.text;
        aligned.add(_AlignedParallelVerse(
          label: label,
          verseNumber: p.verse,
          text81: null,
          textGeez: textGeez,
          text1954: text1954,
          textKjv: textKjv,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _alignedVerses = aligned;
        _hasGeezBook = hasGeez;
        _has1954Book = has1954;
        _hasKjvBook = hasKjv;
        _isLoading = false;
      });

      if (widget.initialTargetVerse != null && aligned.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetIndex = aligned.indexWhere((a) => a.verseNumber >= widget.initialTargetVerse!);
          if (targetIndex > 0 && _scrollController.hasClients) {
            final targetOffset = (targetIndex * 190.0).clamp(0.0, _scrollController.position.maxScrollExtent);
            _scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final isEnglish = ref.watch(isEnglishUiProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final bookTitle = _customBookTitle.isNotEmpty
        ? _customBookTitle
        : (bibleState.currentBook?.getDisplayName(isEnglish) ?? (isEnglish ? 'Scripture' : 'መጽሐፍ'));
    final activeCh = _activeChapter > 0 ? _activeChapter : bibleState.currentChapter;
    final chapterTitle = isEnglish
        ? '$bookTitle Chapter $activeCh'
        : '$bookTitle ምዕራፍ $activeCh';

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Parallel Top Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: themeConfig.cardBorderColor.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: themeConfig.textColor),
                        tooltip: isEnglish ? 'Back' : 'ተመለስ',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'PARALLEL CANON & TRANSLATION STUDY' : 'የቀኖና እና ትርጉም ማነፃፀሪያ',
                              style: isEnglish
                                  ? GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      color: themeConfig.accentColor,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: themeConfig.accentColor,
                                    ),
                            ),
                            Text(
                              chapterTitle,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Mode Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          filter: ParallelViewFilter.allFour,
                          label: isEnglish ? 'All 4 Canons' : 'ሁሉንም 4 አነጻጽር',
                          icon: Icons.auto_awesome_mosaic_rounded,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          filter: ParallelViewFilter.eotcAndGeez,
                          label: isEnglish ? '81 & Ge\'ez' : '81 እና ግዕዝ',
                          icon: Icons.menu_book_rounded,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          filter: ParallelViewFilter.eotcAnd1954,
                          label: isEnglish ? '81 vs 1954' : '81 እና 1954',
                          icon: Icons.compare_arrows_rounded,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          filter: ParallelViewFilter.eotcAndKjv,
                          label: isEnglish ? '81 vs KJV' : '81 እና KJV',
                          icon: Icons.compare_arrows_rounded,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          filter: ParallelViewFilter.haileselassieAndKjv,
                          label: isEnglish ? '1954 vs KJV' : '1954 እና KJV',
                          icon: Icons.compare_arrows_rounded,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Parallel Comparison Stream
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
                  : _buildComparisonList(themeConfig, isEnglish, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ParallelViewFilter filter,
    required String label,
    required IconData icon,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeConfig.accentColor : themeConfig.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : themeConfig.accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : themeConfig.textColor,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : themeConfig.textColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonList(
    ReaderThemeConfig themeConfig,
    bool isEnglish,
    bool isDark,
  ) {
    if (_alignedVerses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isEnglish ? 'No verses found for this chapter' : 'ለዚህ ምዕራፍ ምንም ጥቅሶች አልተገኙም',
            style: isEnglish
                ? GoogleFonts.inter(fontSize: 14, color: themeConfig.secondaryTextColor)
                : GoogleFonts.notoSansEthiopic(fontSize: 14, color: themeConfig.secondaryTextColor),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: _alignedVerses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = _alignedVerses[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: themeConfig.cardBorderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Verse Number Bar & Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: themeConfig.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: themeConfig.accentColor,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.copy_rounded, size: 16, color: themeConfig.secondaryTextColor),
                    tooltip: isEnglish ? 'Copy verses' : 'ጥቅሶቹን ቅዳ',
                    onPressed: () {
                      final sb = StringBuffer();
                      sb.writeln('${item.label}:');
                      if (item.text81 != null) sb.writeln('[81 ቀኖና] ${item.text81}');
                      if (item.textGeez != null) sb.writeln('[ግዕዝ 81] ${item.textGeez}');
                      if (item.text1954 != null) sb.writeln('[1954] ${item.text1954}');
                      if (item.textKjv != null) sb.writeln('[KJV] ${item.textKjv}');

                      Clipboard.setData(ClipboardData(text: sb.toString().trim()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEnglish ? 'Parallel verses copied' : 'የተነጻጸሩት ጥቅሶች ተገልብጠዋል'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 1. 81 Orthodox Canon Slot
              if (_shouldShow81) ...[
                _buildTranslationBlock(
                  badgeLabel: isEnglish ? '81 Orthodox Canon' : '81 ቀኖና',
                  badgeColor: const Color(0xFF047857),
                  verseText: item.text81,
                  isEthiopic: true,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
              ],

              // 2. Ancient Ge'ez 81 Canon Slot
              if (_shouldShowGeez) ...[
                if (_shouldShow81) const SizedBox(height: 12),
                if (!_hasGeezBook)
                  _buildExclusiveDeuterocanonNotice(
                    badgeLabel: isEnglish ? "Ancient Ge'ez 81 Canon" : 'የቀደምት ግዕዝ 81 ቀኖና',
                    badgeColor: const Color(0xFF854D0E),
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  )
                else
                  _buildTranslationBlock(
                    badgeLabel: isEnglish ? "Ancient Ge'ez 81 Canon" : 'የቀደምት ግዕዝ 81 ቀኖና',
                    badgeColor: const Color(0xFF854D0E),
                    verseText: item.textGeez,
                    isEthiopic: true,
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  ),
              ],

              // 3. 1954 Translation Slot
              if (_shouldShow1954) ...[
                if (_shouldShow81 || _shouldShowGeez) const SizedBox(height: 12),
                if (!_has1954Book)
                  _buildExclusiveDeuterocanonNotice(
                    badgeLabel: isEnglish ? '1954 Translation' : '1954 ትርጉም',
                    badgeColor: const Color(0xFFB45309),
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  )
                else
                  _buildTranslationBlock(
                    badgeLabel: isEnglish ? '1954 Translation' : '1954 ትርጉም',
                    badgeColor: const Color(0xFFB45309),
                    verseText: item.text1954,
                    isEthiopic: true,
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  ),
              ],

              // 4. KJV Slot
              if (_shouldShowKjv) ...[
                if (_shouldShow81 || _shouldShowGeez || _shouldShow1954) const SizedBox(height: 12),
                if (!_hasKjvBook)
                  _buildExclusiveDeuterocanonNotice(
                    badgeLabel: 'King James Version (KJV)',
                    badgeColor: const Color(0xFF4338CA),
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  )
                else
                  _buildTranslationBlock(
                    badgeLabel: 'King James Version (KJV)',
                    badgeColor: const Color(0xFF4338CA),
                    verseText: item.textKjv,
                    isEthiopic: false,
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool get _shouldShow81 =>
      _selectedFilter == ParallelViewFilter.allFour ||
      _selectedFilter == ParallelViewFilter.eotcAndGeez ||
      _selectedFilter == ParallelViewFilter.eotcAnd1954 ||
      _selectedFilter == ParallelViewFilter.eotcAndKjv;

  bool get _shouldShowGeez =>
      _selectedFilter == ParallelViewFilter.allFour ||
      _selectedFilter == ParallelViewFilter.eotcAndGeez;

  bool get _shouldShow1954 =>
      _selectedFilter == ParallelViewFilter.allFour ||
      _selectedFilter == ParallelViewFilter.eotcAnd1954 ||
      _selectedFilter == ParallelViewFilter.haileselassieAndKjv;

  bool get _shouldShowKjv =>
      _selectedFilter == ParallelViewFilter.allFour ||
      _selectedFilter == ParallelViewFilter.eotcAndKjv ||
      _selectedFilter == ParallelViewFilter.haileselassieAndKjv;


  Widget _buildTranslationBlock({
    required String badgeLabel,
    required Color badgeColor,
    required String? verseText,
    required bool isEthiopic,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeConfig.cardBorderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            verseText ?? (isEnglish ? 'Verse not found in this canon' : 'ጥቅሱ በዚህ ቀኖና አልተገኘም'),
            style: isEthiopic
                ? const TextStyle(
                    fontFamily: 'NotoSerifEthiopic',
                    fontFamilyFallback: ['Noto Serif Ethiopic', 'Nyala', 'serif'],
                    fontSize: 15.5,
                    height: 1.6,
                  ).copyWith(color: themeConfig.textColor)
                : GoogleFonts.inter(
                    fontSize: 14.5,
                    height: 1.55,
                    color: themeConfig.textColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusiveDeuterocanonNotice({
    required String badgeLabel,
    required Color badgeColor,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: themeConfig.secondaryTextColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEnglish
                      ? 'Exclusively in 81 Orthodox Canon (Deuterocanon)'
                      : 'በ81 ቀኖና ብቻ የሚገኝ መጽሐፍ ነው',
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.secondaryTextColor,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.secondaryTextColor,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
