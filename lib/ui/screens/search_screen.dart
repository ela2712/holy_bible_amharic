import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/search_provider.dart';
import '../../providers/bible_state.dart';
import '../widgets/built_in_geez_keyboard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _showCustomKeyboard = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _performSearch(WidgetRef ref) {
    ref.read(searchProvider.notifier).executeSearch(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final searchState = ref.watch(searchProvider);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _queryController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'በመጽሐፍ ቅዱስ ውስጥ ፈልግ (Search)...',
                border: InputBorder.none,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_queryController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _queryController.clear();
                          ref.read(searchProvider.notifier).executeSearch('');
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _showCustomKeyboard ? Icons.keyboard : Icons.keyboard_alt_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Toggle Ge\'ez Keyboard',
                      onPressed: () => setState(() => _showCustomKeyboard = !_showCustomKeyboard),
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _performSearch(ref),
            ),
          ),
          body: Column(
            children: [
              // Results, Loading, or History view
              Expanded(
                child: searchState.isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : searchState.results.isNotEmpty
                        ? _buildResultsList(context, ref, searchState.results)
                        : _buildHistoryView(context, ref, searchState.recentSearches),
              ),

              // Built-in Ge'ez Keyboard
              if (_showCustomKeyboard)
                BuiltInGeezKeyboard(
                  controller: _queryController,
                  onSearchOrSubmit: () => _performSearch(ref),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> results,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${results.length} ጥቅሶች ተገኝተዋል (Found)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = results[index];
              final bookName = item['book_name'] as String;
              final bookNumber = item['book_number'] as int;
              final chapter = item['chapter'] as int;
              final verse = item['verse'] as int;
              final text = item['text'] as String;

              return ListTile(
                title: SelectableText(
                  '$bookName $chapter:$verse',
                  style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: SelectableText(
                    text,
                    style: GoogleFonts.notoSansEthiopic(fontSize: 15, height: 1.5),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView(
    BuildContext context,
    WidgetRef ref,
    List<String> recents,
  ) {
    if (recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'ቃላትን ወይም አረፍተ ነገር ይፈልጉ\n(Search for words or verses)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'የቅርብ ጊዜ ፍለጋዎች (Recent Searches)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            TextButton(
              onPressed: () => ref.read(searchProvider.notifier).clearRecentSearches(),
              child: const Text('ሁሉንም አጽዳ (Clear)'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recents.map((query) {
            return InputChip(
              label: Text(query, style: GoogleFonts.notoSansEthiopic()),
              onPressed: () {
                _queryController.text = query;
                ref.read(searchProvider.notifier).executeSearch(query);
              },
              onDeleted: () => ref.read(searchProvider.notifier).removeRecentSearch(query),
            );
          }).toList(),
        ),
      ],
    );
  }
}
