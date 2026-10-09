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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.headphones, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    audioState.currentTrackTitle!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
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
                  child: Text('${audioState.speed}x', style: const TextStyle(fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => audioNotifier.stop(),
                ),
              ],
            ),
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
                      audioState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => audioNotifier.togglePlayPause(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
