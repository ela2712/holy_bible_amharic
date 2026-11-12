import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reading_progress_service.dart';

class ReadingProgressNotifier extends StateNotifier<ReadingProgressState> {
  ReadingProgressNotifier() : super(const ReadingProgressState()) {
    load();
  }

  Future<void> load() async {
    final stateData = await ReadingProgressService.instance.loadState();
    state = stateData;
  }

  Future<void> markChapterRead(int bookNumber, int chapter, {String? canonicalId}) async {
    if (state.isChapterReadToday(bookNumber, chapter, canonicalId: canonicalId) &&
        state.isChapterRead(bookNumber, chapter)) {
      return;
    }
    final updated = await ReadingProgressService.instance.markChapterRead(
      bookNumber,
      chapter,
      canonicalId: canonicalId,
    );
    state = updated;
  }
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressNotifier, ReadingProgressState>((ref) {
  return ReadingProgressNotifier();
});
