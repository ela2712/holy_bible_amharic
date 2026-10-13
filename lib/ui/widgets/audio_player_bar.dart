import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_player_service.dart';

class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerServiceProvider);
    final audioNotifier = ref.read(audioPlayerServiceProvider.notifier);

    if (audioState.currentTrackTitle == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1917) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track Info Row
            Row(
              children: [
                Icon(
                  Icons.headphones_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        audioState.currentTrackTitle!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (audioState.isCurrentTrackCached) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.offline_pin_rounded,
                                    size: 11,
                                    color: Color(0xFF10B981),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'ከመስመር ውጭ (Offline)',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Text(
                              'ቀጥታ ስርጭት (Streaming)',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Download button for native platforms
                if (!kIsWeb) ...[
                  if (audioState.isDownloading) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: audioState.downloadProgress > 0
                                  ? audioState.downloadProgress
                                  : null,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${(audioState.downloadProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (!audioState.isCurrentTrackCached) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.download_for_offline_outlined, size: 20),
                      tooltip: 'ከመስመር ውጭ ለማዳመጥ አውርድ (Save Offline)',
                      onPressed: () => audioNotifier.downloadCurrentChapter(),
                    ),
                  ],
                ],
                // Speed Selector
                TextButton(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () {
                    final nextSpeed = audioState.speed == 1.0
                        ? 1.25
                        : audioState.speed == 1.25
                            ? 1.5
                            : audioState.speed == 1.5
                                ? 0.75
                                : 1.0;
                    audioNotifier.setSpeed(nextSpeed);
                  },
                  child: Text(
                    '${audioState.speed}x',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => audioNotifier.stop(),
                ),
              ],
            ),
            // Progress Bar and Controls
            Row(
              children: [
                Text(
                  _formatDuration(audioState.position),
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
                Expanded(
                  child: Slider(
                    value: audioState.duration.inMilliseconds > 0
                        ? (audioState.position.inMilliseconds /
                                audioState.duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (val) {
                      final newPos = Duration(
                        milliseconds: (val * audioState.duration.inMilliseconds).toInt(),
                      );
                      audioNotifier.seek(newPos);
                    },
                  ),
                ),
                Text(
                  _formatDuration(audioState.duration),
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
                if (audioState.isLoading)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      audioState.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      size: 34,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => audioNotifier.togglePlayPause(),
                  ),
              ],
            ),
            if (audioState.error != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  audioState.error!,
                  style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
