import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/canonical_book_map.dart';
import '../models/translation.dart';
import '../models/book.dart';
import '../models/verse.dart';
import '../services/bible_repository.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

class BibleViewState {
  final List<Translation> translations;
  final Translation? currentTranslation;
  final List<Book> books;
  final Book? currentBook;
  final int currentChapter;
  final List<Verse> verses;
  final List<SectionHeading> headings;
  final bool isLoading;
  final String? errorMessage;
  final int? targetVerse;

  const BibleViewState({
    this.translations = const [],
    this.currentTranslation,
    this.books = const [],
    this.currentBook,
    this.currentChapter = 1,
    this.verses = const [],
    this.headings = const [],
    this.isLoading = true,
    this.errorMessage,
    this.targetVerse,
  });

  BibleViewState copyWith({
    List<Translation>? translations,
    Translation? currentTranslation,
    List<Book>? books,
    Book? currentBook,
    int? currentChapter,
    List<Verse>? verses,
    List<SectionHeading>? headings,
    bool? isLoading,
    String? errorMessage,
    int? targetVerse,
    bool clearTargetVerse = false,
  }) {
    return BibleViewState(
      translations: translations ?? this.translations,
      currentTranslation: currentTranslation ?? this.currentTranslation,
      books: books ?? this.books,
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      verses: verses ?? this.verses,
      headings: headings ?? this.headings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      targetVerse: clearTargetVerse ? null : (targetVerse ?? this.targetVerse),
    );
  }
}

final bibleStateProvider =
    StateNotifierProvider<BibleStateNotifier, BibleViewState>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return BibleStateNotifier(repo);
});

class BibleStateNotifier extends StateNotifier<BibleViewState> {
  final BibleRepository _repo;

  BibleStateNotifier(this._repo) : super(const BibleViewState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.ensureInitialized();
      final translations = await _repo.getTranslations();
      final prefs = await SharedPreferences.getInstance();

      // Default to Orthodox 81 Canon (id: 2) as the main translation
      final savedTransId = prefs.getInt('active_translation_id') ?? 2;
      final savedBookNum = prefs.getInt('active_book_number') ?? 1;
      final savedChapter = prefs.getInt('active_chapter') ?? 1;

      Translation activeTrans = translations.firstWhere(
        (t) => t.id == savedTransId,
        orElse: () => translations.first,
      );

      final books = await _repo.getBooks(translationId: activeTrans.id);
      Book activeBook = books.firstWhere(
        (b) => b.bookNumber == savedBookNum,
        orElse: () => books.first,
      );

      final safeChapter = savedChapter.clamp(1, activeBook.totalChapters);
      final verses = await _repo.getVerses(
        bookId: activeBook.id,
        chapter: safeChapter,
      );
      final headings = await _repo.getSectionHeadings(
        bookId: activeBook.id,
        chapter: safeChapter,
      );

      state = state.copyWith(
        translations: translations,
        currentTranslation: activeTrans,
        books: books,
        currentBook: activeBook,
        currentChapter: safeChapter,
        verses: verses,
        headings: headings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load Bible: $e',
      );
    }
  }

  Future<void> selectTranslation(Translation translation) async {
    if (state.currentTranslation?.id == translation.id) return;
    state = state.copyWith(isLoading: true);

    try {
      final books = await _repo.getBooks(translationId: translation.id);
      final currentBook = state.currentBook;
      final currentTransId = state.currentTranslation?.id ?? 2;
      final currentChapter = state.currentChapter;

      Book? targetBook;
      if (currentBook != null) {
        // Resolve canonical 3-letter book ID (e.g., 'MAT', 'GEN', 'ROM')
        final canonId = CanonicalBookMap.getCanonicalId(currentTransId, currentBook.bookNumber);
        if (canonId.isNotEmpty) {
          final targetBookNum = CanonicalBookMap.getBookNumber(translation.id, canonId);
          if (targetBookNum != null) {
            for (final b in books) {
              if (b.bookNumber == targetBookNum) {
                targetBook = b;
                break;
              }
            }
          }
        }
      }

      // Fallback: If current book only exists in 81 (e.g., Enoch, Jubilees, Meqabyan),
      // we can't force it to exist in 66-book editions, so land gracefully on the first book
      // in the same testament, or the first book of the translation.
      targetBook ??= books.firstWhere(
        (b) => currentBook != null && b.testament == currentBook.testament,
        orElse: () => books.first,
      );

      final targetChapter = currentChapter.clamp(1, targetBook.totalChapters);
      final verses = await _repo.getVerses(bookId: targetBook.id, chapter: targetChapter);
      final headings = await _repo.getSectionHeadings(bookId: targetBook.id, chapter: targetChapter);

      state = state.copyWith(
        currentTranslation: translation,
        books: books,
        currentBook: targetBook,
        currentChapter: targetChapter,
        verses: verses,
        headings: headings,
        isLoading: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_translation_id', translation.id);
      await prefs.setInt('active_book_number', targetBook.bookNumber);
      await prefs.setInt('active_chapter', targetChapter);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectBook(Book book, {int chapter = 1}) async {
    state = state.copyWith(isLoading: true);
    try {
      final safeChapter = chapter.clamp(1, book.totalChapters);
      final verses = await _repo.getVerses(bookId: book.id, chapter: safeChapter);
      final headings = await _repo.getSectionHeadings(bookId: book.id, chapter: safeChapter);

      state = state.copyWith(
        currentBook: book,
        currentChapter: safeChapter,
        verses: verses,
        headings: headings,
        isLoading: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_book_number', book.bookNumber);
      await prefs.setInt('active_chapter', safeChapter);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectChapter(int chapter) async {
    if (state.currentBook == null) return;
    final book = state.currentBook!;
    final safeChapter = chapter.clamp(1, book.totalChapters);
    if (safeChapter == state.currentChapter) return;

    state = state.copyWith(isLoading: true);
    try {
      final verses = await _repo.getVerses(bookId: book.id, chapter: safeChapter);
      final headings = await _repo.getSectionHeadings(bookId: book.id, chapter: safeChapter);

      state = state.copyWith(
        currentChapter: safeChapter,
        verses: verses,
        headings: headings,
        isLoading: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_chapter', safeChapter);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> nextChapter() async {
    if (state.currentBook == null) return;
    final book = state.currentBook!;
    if (state.currentChapter < book.totalChapters) {
      await selectChapter(state.currentChapter + 1);
    } else {
      // Advance to next book if available
      final currentIndex = state.books.indexWhere((b) => b.id == book.id);
      if (currentIndex != -1 && currentIndex < state.books.length - 1) {
        await selectBook(state.books[currentIndex + 1], chapter: 1);
      }
    }
  }

  Future<void> prevChapter() async {
    if (state.currentBook == null) return;
    final book = state.currentBook!;
    if (state.currentChapter > 1) {
      await selectChapter(state.currentChapter - 1);
    } else {
      // Step back to previous book's last chapter
      final currentIndex = state.books.indexWhere((b) => b.id == book.id);
      if (currentIndex > 0) {
        final prevBook = state.books[currentIndex - 1];
        await selectBook(prevBook, chapter: prevBook.totalChapters);
      }
    }
  }

  Future<void> refreshVerses() async {
    if (state.currentBook == null) return;
    final verses = await _repo.getVerses(
      bookId: state.currentBook!.id,
      chapter: state.currentChapter,
    );
    state = state.copyWith(verses: verses);
  }

  void setTargetVerse(int? verse) {
    state = state.copyWith(targetVerse: verse);
  }

  void clearTargetVerse() {
    if (state.targetVerse != null) {
      state = state.copyWith(clearTargetVerse: true);
    }
  }
}