import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioCacheStorage {
  static Directory? _cacheDir;

  static Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/audio_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  static Future<void> init() async {
    try {
      await _getCacheDirectory();
    } catch (_) {}
  }

  static Future<String?> getCachedFilePath(String key) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/$key.mp3');
      if (await file.exists() && (await file.length()) > 1024) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> isCached(String key) async {
    final path = await getCachedFilePath(key);
    return path != null;
  }

  static Future<Set<String>> getCachedKeys() async {
    final keys = <String>{};
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        final list = dir.listSync();
        for (final entity in list) {
          if (entity is File && entity.path.endsWith('.mp3')) {
            final filename = entity.uri.pathSegments.last;
            final key = filename.replaceAll('.mp3', '');
            if (entity.lengthSync() > 1024) {
              keys.add(key);
            }
          }
        }
      }
    } catch (_) {}
    return keys;
  }

  static Future<bool> downloadAudioFile({
    required String url,
    required String key,
    required void Function(double progress) onProgress,
  }) async {
    HttpClient? client;
    IOSink? sink;
    try {
      final dir = await _getCacheDirectory();
      final tempFile = File('${dir.path}/$key.tmp');
      final targetFile = File('${dir.path}/$key.mp3');

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        client.close(force: true);
        return false;
      }

      final contentLength = response.contentLength;
      sink = tempFile.openWrite();
      int received = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          onProgress((received / contentLength).clamp(0.0, 1.0));
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;
      client.close();
      client = null;

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      onProgress(1.0);
      return true;
    } catch (_) {
      sink?.close();
      client?.close(force: true);
      return false;
    }
  }

  static Future<bool> deleteCachedFile(String key) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/$key.mp3');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<int> getCachedSize() async {
    int total = 0;
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        for (final entity in dir.listSync()) {
          if (entity is File) total += entity.lengthSync();
        }
      }
    } catch (_) {}
    return total;
  }

  static Future<void> clearAllCache() async {
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (_) {}
  }
}
