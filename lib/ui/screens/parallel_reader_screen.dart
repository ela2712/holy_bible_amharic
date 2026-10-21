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

class ParallelReaderScreen extends ConsumerStatefulWidget {
  const ParallelReaderScreen({super.key});

  @override
  ConsumerState<ParallelReaderScreen> createState() => _ParallelReaderScreenState();
}

class _ParallelReaderScreenState extends ConsumerState<ParallelReaderScreen> {
  int _secondaryTranslationId = 1; // Defaults to 1954 (or KJV if 1954 is primary)
  List<Verse> _secondaryVerses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentTransId = ref.read(bibleStateProvider).currentTranslation?.id ?? 2;
    // Default secondary to 1954 if primary is 81, or 81 if primary is 1954/KJV
    _secondaryTranslationId = currentTransId == 2 ? 1 : 2;
    _loadSecondaryVerses();
  }

  Future<void> _loadSecondaryVerses() async {
    setState(() => _isLoading = true);
    final bibleState = ref.read(bibleStateProvider);
    final repo = ref.read(bibleRepositoryProvider);

    if (bibleState.currentBook != null) {
      final currentTransId = bibleState.currentTranslation?.id ?? 2;
      final canonId = CanonicalBookMap.getCanonicalId(currentTransId, bibleState.currentBook!.bookNumber);
      final targetBookNum = CanonicalBookMap.getBookNumber(_secondaryTranslationId, canonId);

      if (targetBookNum != null) {
        final secondaryBook = await repo.getBookByNumber(
          _secondaryTranslationId,
          targetBookNum,
        );

        if (secondaryBook != null) {
          final verses = await repo.getVerses(
            bookId: secondaryBook.id,
            chapter: bibleState.currentChapter.clamp(1, secondaryBook.totalChapters),
          );
          if (mounted) {
            setState(() {
              _secondaryVerses = verses;
              _isLoading = false;
            });
          }
          return;
        }
      }
    }
    if (mounted) {
      setState(() {
        _secondaryVerses = [];
        _isLoading = false;
      });
    }
  }

  String _getTranslationShortName(int id) {
    switch (id) {
      case 2:
        return '81 ቀኖና';
      case 1:
        return '1954';
      case 3:
        return 'KJV';
      default:
        return 'ትርጉም';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final translations = bibleState.translations;
    final primaryTrans = bibleState.currentTranslation;
    final isEnglish = ref.watch(isEnglishUiProvider);
    final secondaryTrans = translations.firstWhere(
      (t) => t.id == _secondaryTranslationId,
      orElse: () => translations.first,
    );

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Modern Parallel Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: themeConfig.cardBorderColor.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: themeConfig.textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish ? 'PARALLEL TRANSLATION STUDY' : 'የትርጉሞች ማነፃፀሪያ',
                          style: isEnglish
                              ? GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: themeConfig.accentColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: themeConfig.accentColor,
                                ),
                        ),
                        Text(
                          isEnglish
                              ? '${bibleState.currentBook?.name ?? ''} Chapter ${bibleState.currentChapter}'
                              : '${bibleState.currentBook?.name ?? ''} ምዕራፍ ${bibleState.currentChapter}',
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

                  // Secondary Translation Dropdown Pill
                  PopupMenuButton<int>(
                    tooltip: 'Secondary Translation',
                    initialValue: _secondaryTranslationId,
                    onSelected: (id) {
                      HapticFeedback.selectionClick();
                      setState(() => _secondaryTranslationId = id);
                      _loadSecondaryVerses();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: themeConfig.cardBorderColor),
                    ),
                    color: themeConfig.surfaceColor,
                    itemBuilder: (context) {
                      return translations
                          .where((t) => t.id != bibleState.currentTranslation?.id)
                          .map((t) => PopupMenuItem(
                                value: t.id,
                                child: Text(
                                  t.name,
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontWeight: t.id == _secondaryTranslationId
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: t.id == _secondaryTranslationId
                                        ? themeConfig.accentColor
                                        : themeConfig.textColor,
                                  ),
                                ),
                              ))
                          .toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: themeConfig.accentColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.compare_arrows_rounded, size: 16, color: themeConfig.accentColor),
                          const SizedBox(width: 4),
                          Text(
                            _getTranslationShortName(_secondaryTranslationId),
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.accentColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: themeConfig.accentColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Comparison Stream
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
                  : _buildVerseComparisonList(
                      bibleState.verses,
                      _secondaryVerses,
                      primaryTrans?.name ?? 'ዋና ትርጉም',
                      secondaryTrans.name,
                      themeConfig,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseComparisonList(
    List<Verse> primary,
    List<Verse> secondary,
    String primaryName,
    String secondaryName,
    ReaderThemeConfig themeConfig,
  ) {
    final maxCount = primary.length > secondary.length ? primary.length : secondary.length;
    if (maxCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'ምንም ጥቅሶች አልተገኙም (No verses found)',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 14,
              color: themeConfig.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: maxCount,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final pVerse = index < primary.length ? primary[index] : null;
        final sVerse = index < secondary.length ? secondary[index] : null;
        final verseNum = (pVerse?.verse ?? sVerse?.verse ?? (index + 1));
        final verseRangeLabel = pVerse != null && pVerse.isMergedRange
            ? 'ቁጥር ${pVerse.verse}–${pVerse.verseEnd}'
            : 'ቁጥር $verseNum';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: themeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeConfig.cardBorderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verse Number Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: themeConfig.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      verseRangeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: themeConfig.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Primary Translation Block
              if (pVerse != null) ...[
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      primaryName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: themeConfig.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pVerse.text,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: themeConfig.fontSize,
                    height: 1.6,
                    color: themeConfig.textColor,
                  ),
                ),
              ],

              if (pVerse != null && sVerse != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: themeConfig.cardBorderColor.withValues(alpha: 0.5),
                    height: 1,
                  ),
                ),

              // Secondary Translation Block
              if (sVerse != null) ...[
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: themeConfig.secondaryTextColor.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      secondaryName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: themeConfig.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sVerse.text,
                  style: _secondaryTranslationId == 3
                      ? GoogleFonts.inter(
                          fontSize: themeConfig.fontSize * 0.94,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.textColor.withValues(alpha: 0.88),
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: themeConfig.fontSize * 0.94,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.textColor.withValues(alpha: 0.88),
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
