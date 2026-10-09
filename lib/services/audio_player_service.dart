import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? currentTrackTitle;
  final String? error;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.currentTrackTitle,
    this.error,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentTrackTitle,
    String? error,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentTrackTitle: currentTrackTitle ?? this.currentTrackTitle,
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

  /// Play audio stream for a specific book and chapter
  Future<void> playChapterAudio({
    required int bookNumber,
    required int chapter,
    required String bookName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentTrackTitle: '$bookName ምዕራፍ $chapter',
    );

    try {
      // Audio stream URL pattern from open audio bible feeds (with fallback)
      final bookFormatted = bookNumber.toString().padLeft(2, '0');
      final chapterFormatted = chapter.toString().padLeft(3, '0');
      final url =
          'https://media.faithcomesbyhearing.com/mp3audiobibles2/AMHWTC/B${bookFormatted}_$chapterFormatted.mp3';

      await _player.setUrl(url);
      await _player.play();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'ድምፅ ማጫወት አልተቻለም። እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ።',
      );
    }
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
    state = const AudioState();
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
