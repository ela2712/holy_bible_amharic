import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/book.dart';
import '../../providers/bible_state.dart';
import '../../core/utils/geez_numbers.dart';
import '../../providers/theme_provider.dart';

class BookSelectorScreen extends StatefulWidget {
  const BookSelectorScreen({super.key});

  @override
  State<BookSelectorScreen> createState() => _BookSelectorScreenState();
}

class _BookSelectorScreenState extends State<BookSelectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showChapterPicker(BuildContext context, WidgetRef ref, Book book) {
    final themeConfig = ref.read(themeConfigProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${book.name} (${book.totalChapters} ምዕራፎች)',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: book.totalChapters,
                      itemBuilder: (context, index) {
                        final ch = index + 1;
                        final label = themeConfig.useGeezNumerals
                            ? GeezNumbers.toGeez(ch)
                            : '$ch';
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            ref.read(bibleStateProvider.notifier).selectBook(book, chapter: ch);
                            Navigator.pop(ctx); // Close sheet
                            Navigator.pop(context); // Close book selector
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final bibleState = ref.watch(bibleStateProvider);
        final books = bibleState.books;

        final filteredBooks = books.where((b) {
          if (_filter.isEmpty) return true;
          return b.name.toLowerCase().contains(_filter.toLowerCase()) ||
              b.nameEn.toLowerCase().contains(_filter.toLowerCase()) ||
              b.shortName.toLowerCase().contains(_filter.toLowerCase());
        }).toList();

        final otBooks = filteredBooks.where((b) => b.isOldTestament).toList();
        final ntBooks = filteredBooks.where((b) => b.isNewTestament).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('መጻሕፍት (Books)'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(104),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'መጽሐፍ ፈልግ (Search book)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _filter.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _filter = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        filled: true,
                      ),
                      onChanged: (val) => setState(() => _filter = val),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'ብሉይ ኪዳን (${otBooks.length})'),
                      Tab(text: 'ሐዲስ ኪዳን (${ntBooks.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBookList(otBooks, ref),
              _buildBookList(ntBooks, ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookList(List<Book> books, WidgetRef ref) {
    if (books.isEmpty) {
      return const Center(child: Text('ምንም መጽሐፍ አልተገኘም (No books found)'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: books.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              book.shortName.isNotEmpty ? book.shortName : '${book.bookNumber}',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            book.name,
            style: GoogleFonts.notoSansEthiopic(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${book.nameEn.isNotEmpty ? "${book.nameEn} • " : ""}${book.totalChapters} ምዕራፎች (chapters)',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showChapterPicker(context, ref, book),
        );
      },
    );
  }
}
