import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../models/verse.dart';
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
          setState(() {
            _secondaryVerses = verses;
            _isLoading = false;
          });
          return;
        }
      }
    }
    setState(() {
      _secondaryVerses = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final translations = bibleState.translations;

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'ማነፃፀሪያ (Parallel Bible) — ${bibleState.currentBook?.name} ${bibleState.currentChapter}',
          style: GoogleFonts.notoSansEthiopic(fontSize: 16),
        ),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Secondary Translation',
            icon: const Icon(Icons.compare_arrows),
            initialValue: _secondaryTranslationId,
            onSelected: (id) {
              setState(() => _secondaryTranslationId = id);
              _loadSecondaryVerses();
            },
            itemBuilder: (context) {
              return translations
                  .where((t) => t.id != bibleState.currentTranslation?.id)
                  .map((t) => PopupMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      ))
                  .toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildVerseComparisonList(bibleState.verses, _secondaryVerses, themeConfig),
    );
  }

  Widget _buildVerseComparisonList(
    List<Verse> primary,
    List<Verse> secondary,
    dynamic themeConfig,
  ) {
    final maxCount = primary.length > secondary.length ? primary.length : secondary.length;
    if (maxCount == 0) {
      return const Center(child: Text('ምንም ጥቅሶች አልተገኙም (No verses found)'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: maxCount,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final pVerse = index < primary.length ? primary[index] : null;
        final sVerse = index < secondary.length ? secondary[index] : null;
        final verseNum = (pVerse?.verse ?? sVerse?.verse ?? (index + 1));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: themeConfig.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ቁጥር $verseNum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: themeConfig.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Primary translation text
            if (pVerse != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  pVerse.text,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: themeConfig.fontSize,
                    height: themeConfig.lineSpacing,
                    color: themeConfig.textColor,
                  ),
                ),
              ),
            const SizedBox(height: 6),

            // Secondary translation text
            if (sVerse != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Text(
                  sVerse.text,
                  style: TextStyle(
                    fontSize: themeConfig.fontSize * 0.92,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: themeConfig.textColor.withOpacity(0.85),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
