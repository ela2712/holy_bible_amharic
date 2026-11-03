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

  Future<void> markChapterRead(int bookNumber, int chapter) async {
    final updated = await ReadingProgressService.instance.markChapterRead(bookNumber, chapter);
    state = updated;
  }
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressNotifier, ReadingProgressState>((ref) {
  return ReadingProgressNotifier();
});
