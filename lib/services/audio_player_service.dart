import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_cache_storage.dart';

class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? currentTrackTitle;
  final int? currentBookNumber;
  final int? currentChapter;
  final bool isCurrentTrackCached;
  final bool isDownloading;
  final double downloadProgress;
  final Set<String> cachedChapterKeys;
  final String? error;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.currentTrackTitle,
    this.currentBookNumber,
    this.currentChapter,
    this.isCurrentTrackCached = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.cachedChapterKeys = const <String>{},
    this.error,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentTrackTitle,
    int? currentBookNumber,
    int? currentChapter,
    bool? isCurrentTrackCached,
    bool? isDownloading,
    double? downloadProgress,
    Set<String>? cachedChapterKeys,
    String? error,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentTrackTitle: currentTrackTitle ?? this.currentTrackTitle,
      currentBookNumber: currentBookNumber ?? this.currentBookNumber,
      currentChapter: currentChapter ?? this.currentChapter,
      isCurrentTrackCached: isCurrentTrackCached ?? this.isCurrentTrackCached,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      cachedChapterKeys: cachedChapterKeys ?? this.cachedChapterKeys,
      error: error,
    );
  }
}

final audioPlayerServiceProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioState>((ref) {
  return AudioPlayerNotifier();
});

class AudioPlayerNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _playerStateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  AudioPlayerNotifier() : super(const AudioState()) {
    _initStreams();
    _initCache();
  }

  void _initStreams() {
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      final isLoading = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;

      state = state.copyWith(
        isPlaying: isPlaying,
        isLoading: isLoading,
      );
    });

    _posSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _durSub = _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });
  }

  Future<void> _initCache() async {
    await AudioCacheStorage.init();
    final keys = await AudioCacheStorage.getCachedKeys();
    state = state.copyWith(cachedChapterKeys: keys);
  }

  /// Generates the standard key for a book and chapter (e.g. B01_001)
  String getChapterKey(int bookNumber, int chapter) {
    final b = bookNumber.toString().padLeft(2, '0');
    final c = chapter.toString().padLeft(3, '0');
    return 'B${b}_$c';
  }

  /// CDN URL for audio streaming
  String getAudioUrl(int bookNumber, int chapter) {
    final key = getChapterKey(bookNumber, chapter);
    return 'https://media.faithcomesbyhearing.com/mp3audiobibles2/AMHWTC/$key.mp3';
  }

  /// Checks if a chapter is downloaded and available offline
  bool isChapterCached(int bookNumber, int chapter) {
    final key = getChapterKey(bookNumber, chapter);
    return state.cachedChapterKeys.contains(key);
  }

  /// Play audio for a specific book and chapter (prefers offline file if cached)
  Future<void> playChapterAudio({
    required int bookNumber,
    required int chapter,
    required String bookName,
  }) async {
    final key = getChapterKey(bookNumber, chapter);
    final cached = state.cachedChapterKeys.contains(key);

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentTrackTitle: '$bookName ምዕራፍ $chapter',
      currentBookNumber: bookNumber,
      currentChapter: chapter,
      isCurrentTrackCached: cached,
    );

    try {
      final localPath = await AudioCacheStorage.getCachedFilePath(key);
      if (localPath != null) {
        // Play directly from local disk with zero latency and full offline capability
        await _player.setFilePath(localPath);
        await _player.play();
        state = state.copyWith(
          isLoading: false,
          isCurrentTrackCached: true,
        );
      } else {
        // Stream from high-quality remote CDN
        final url = getAudioUrl(bookNumber, chapter);
        await _player.setUrl(url);
        await _player.play();
        state = state.copyWith(
          isLoading: false,
          isCurrentTrackCached: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'ድምፅ ማጫወት አልተቻለም። የበይነመረብ ግንኙነት የለም ወይም ይህ ምዕራፍ አልወረደም።',
      );
    }
  }

  /// Downloads the current playing chapter for offline listening
  Future<bool> downloadCurrentChapter() async {
    if (state.currentBookNumber == null || state.currentChapter == null) {
      return false;
    }
    return downloadChapterAudio(
      bookNumber: state.currentBookNumber!,
      chapter: state.currentChapter!,
      bookName: state.currentTrackTitle ?? 'ምዕራፍ ${state.currentChapter}',
    );
  }

  /// Downloads a chapter to local storage with progress reporting
  Future<bool> downloadChapterAudio({
    required int bookNumber,
    required int chapter,
    required String bookName,
  }) async {
    final key = getChapterKey(bookNumber, chapter);
    if (state.cachedChapterKeys.contains(key)) {
      return true;
    }

    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      error: null,
    );

    final url = getAudioUrl(bookNumber, chapter);
    final success = await AudioCacheStorage.downloadAudioFile(
      url: url,
      key: key,
      onProgress: (prog) {
        state = state.copyWith(downloadProgress: prog);
      },
    );

    if (success) {
      final updatedKeys = Set<String>.from(state.cachedChapterKeys)..add(key);
      final isCurrent = state.currentBookNumber == bookNumber && state.currentChapter == chapter;
      state = state.copyWith(
        isDownloading: false,
        downloadProgress: 1.0,
        cachedChapterKeys: updatedKeys,
        isCurrentTrackCached: isCurrent ? true : state.isCurrentTrackCached,
      );
      return true;
    } else {
      state = state.copyWith(
        isDownloading: false,
        error: 'ምዕራፉን ማውረድ አልተቻለም። የበይነመረብ ግንኙነትዎን ያረጋግጡ።',
      );
      return false;
    }
  }

  /// Deletes a cached chapter file
  Future<void> deleteCachedChapter(int bookNumber, int chapter) async {
    final key = getChapterKey(bookNumber, chapter);
    await AudioCacheStorage.deleteCachedFile(key);
    final updatedKeys = Set<String>.from(state.cachedChapterKeys)..remove(key);
    final isCurrent = state.currentBookNumber == bookNumber && state.currentChapter == chapter;
    state = state.copyWith(
      cachedChapterKeys: updatedKeys,
      isCurrentTrackCached: isCurrent ? false : state.isCurrentTrackCached,
    );
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      isPlaying: false,
      isLoading: false,
      position: Duration.zero,
      currentTrackTitle: null,
      currentBookNumber: null,
      currentChapter: null,
      isCurrentTrackCached: false,
    );
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
