import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/search_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../widgets/built_in_geez_keyboard.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToReader;

  const SearchScreen({
    super.key,
    this.onNavigateToReader,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _showCustomKeyboard = false;
  String _testamentFilter = 'ALL'; // 'ALL', 'OT', 'NT'

  static const List<String> _suggestedKeywords = [
    'ፍቅር',
    'እምነት',
    'ተስፋ',
    'ሰላም',
    'ጸሎት',
    'ጥበብ',
    'ምሕረት',
    'ትንሣኤ',
    'መንፈስ ቅዱስ',
    'ብርሃን',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _performSearch() {
    ref.read(searchProvider.notifier).executeSearch(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;

    // Filter results by testament if selected
    final filteredResults = searchState.results.where((item) {
      if (_testamentFilter == 'ALL') return true;
      final testament = item['testament'] as String? ?? 'OT';
      return testament == _testamentFilter;
    }).toList();

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Modern Editorial Search Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOMOPHONE-AWARE GEEZ SEARCH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: themeConfig.accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'የቃላትና ጥቅሶች ፍለጋ',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: themeConfig.textColor,
                        ),
                      ),
                    ],
                  ),
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: themeConfig.textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),

            // 2. Modern Search Input Capsule
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _queryController.text.isNotEmpty
                        ? themeConfig.accentColor
                        : themeConfig.cardBorderColor,
                    width: _queryController.text.isNotEmpty ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _queryController,
                  textInputAction: TextInputAction.search,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: themeConfig.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ቃላትን ወይም ጥቅሶችን ይፈልጉ...',
                    hintStyle: GoogleFonts.notoSansEthiopic(
                      fontSize: 13.5,
                      color: themeConfig.secondaryTextColor,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, size: 21, color: themeConfig.accentColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_queryController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear_rounded, size: 18, color: themeConfig.secondaryTextColor),
                            onPressed: () {
                              _queryController.clear();
                              ref.read(searchProvider.notifier).executeSearch('');
                              setState(() {});
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _showCustomKeyboard ? Icons.keyboard_rounded : Icons.keyboard_alt_outlined,
                            size: 20,
                            color: _showCustomKeyboard ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                          ),
                          tooltip: 'የግዕዝ ኪቦርድ (Ge\'ez Keyboard)',
                          onPressed: () => setState(() => _showCustomKeyboard = !_showCustomKeyboard),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    if (val.trim().length >= 2) {
                      _performSearch();
                    }
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ),

            // 3. Testament Filter Pills
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
              child: Row(
                children: [
                  _buildFilterPill('ሁሉም (All)', 'ALL', themeConfig),
                  const SizedBox(width: 8),
                  _buildFilterPill('ብሉይ ኪዳን (OT)', 'OT', themeConfig),
                  const SizedBox(width: 8),
                  _buildFilterPill('ሐዲስ ኪዳን (NT)', 'NT', themeConfig),
                ],
              ),
            ),

            // 4. Results or Discovery View
            Expanded(
              child: searchState.isSearching
                  ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
                  : filteredResults.isNotEmpty
                      ? _buildResultsList(context, filteredResults, themeConfig, isDark)
                      : _buildDiscoveryAndHistoryView(context, searchState.recentSearches, themeConfig, isDark),
            ),
            if (_showCustomKeyboard)
              BuiltInGeezKeyboard(
                controller: _queryController,
                onSearchOrSubmit: () {
                  setState(() {});
                  _performSearch();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String value, ReaderThemeConfig themeConfig) {
    final isSelected = _testamentFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _testamentFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? themeConfig.accentColor : themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : themeConfig.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<Map<String, dynamic>> results,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} ጥቅሶች ተገኝተዋል',
                style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: themeConfig.accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ሞክሼ ፊደላት ንቁ (Normalized)',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = results[index];
              final bookName = item['book_name'] as String;
              final bookNumber = item['book_number'] as int;
              final chapter = item['chapter'] as int;
              final verse = item['verse'] as int;
              final text = item['text'] as String;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  final bibleState = ref.read(bibleStateProvider);
                  final targetBook = bibleState.books.firstWhere(
                    (b) => b.bookNumber == bookNumber,
                    orElse: () => bibleState.books.first,
                  );
                  await ref.read(bibleStateProvider.notifier).selectBook(
                        targetBook,
                        chapter: chapter,
                      );
                  if (!context.mounted) return;
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (widget.onNavigateToReader != null) {
                    widget.onNavigateToReader!(0);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeConfig.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$bookName $chapter:$verse',
                              style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: themeConfig.accentColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: themeConfig.secondaryTextColor),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text,
                        style: GoogleFonts.notoSerifEthiopic(
                          fontSize: 15,
                          height: 1.6,
                          color: themeConfig.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryAndHistoryView(
    BuildContext context,
    List<String> recents,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        Text(
          'ታዋቂ የጥናት ርዕሶች (Popular Topics)',
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: themeConfig.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedKeywords.map((word) {
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _queryController.text = word;
                setState(() {});
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: themeConfig.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      word,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: themeConfig.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        if (recents.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'የቅርብ ጊዜ ፍለጋዎች (Recent Searches)',
                style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: themeConfig.textColor,
                ),
              ),
              TextButton(
                onPressed: () => ref.read(searchProvider.notifier).clearRecentSearches(),
                child: Text(
                  'ሁሉንም አጽዳ',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: themeConfig.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recents.map((query) {
              return InputChip(
                backgroundColor: themeConfig.surfaceColor,
                side: BorderSide(color: themeConfig.cardBorderColor),
                label: Text(query, style: GoogleFonts.notoSansEthiopic(fontSize: 12.5)),
                onPressed: () {
                  _queryController.text = query;
                  setState(() {});
                  _performSearch();
                },
                onDeleted: () => ref.read(searchProvider.notifier).removeRecentSearch(query),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
