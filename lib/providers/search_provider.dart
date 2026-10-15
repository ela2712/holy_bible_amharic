import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bible_repository.dart';
import 'bible_state.dart';

class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final List<String> recentSearches;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    List<String>? recentSearches,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  final bibleState = ref.watch(bibleStateProvider);
  return SearchNotifier(repo, bibleState.currentTranslation?.id ?? 2);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final BibleRepository _repo;
  final int _translationId;

  SearchNotifier(this._repo, this._translationId) : super(const SearchState()) {
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recents = prefs.getStringList('recent_bible_searches') ?? [];
    state = state.copyWith(recentSearches: recents);
  }

  Future<void> executeSearch(String query, {int? bookId}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(query: '', results: [], isSearching: false);
      return;
    }

    state = state.copyWith(query: trimmed, isSearching: true, error: null);

    try {
      final results = await _repo.searchVerses(
        query: trimmed,
        translationId: _translationId,
        bookId: bookId,
        limit: 100,
      );

      // Save to search history (deduped, max 20)
      final updatedHistory = [trimmed, ...state.recentSearches.where((s) => s != trimmed)].take(20).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_bible_searches', updatedHistory);

      state = state.copyWith(
        results: results,
        recentSearches: updatedHistory,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_bible_searches');
    state = state.copyWith(recentSearches: []);
  }

  Future<void> removeRecentSearch(String term) async {
    final updated = state.recentSearches.where((s) => s != term).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_bible_searches', updated);
    state = state.copyWith(recentSearches: updated);
  }
}
