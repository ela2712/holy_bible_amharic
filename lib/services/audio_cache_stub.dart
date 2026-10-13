class AudioCacheStorage {
  static Future<void> init() async {}
  static Future<bool> isCached(String key) async => false;
  static Future<String?> getCachedFilePath(String key) async => null;
  static Future<Set<String>> getCachedKeys() async => <String>{};
  static Future<bool> downloadAudioFile({
    required String url,
    required String key,
    required void Function(double progress) onProgress,
  }) async => false;
  static Future<bool> deleteCachedFile(String key) async => false;
  static Future<int> getCachedSize() async => 0;
  static Future<void> clearAllCache() async {}
}
