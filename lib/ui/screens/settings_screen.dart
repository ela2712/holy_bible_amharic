import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(bibleRepositoryProvider);
      final bookmarks = await repo.getBookmarks();
      final highlights = await repo.getHighlights();
      final notes = await repo.getNotes();

      final backupData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'bookmarks': bookmarks
            .map((b) => {
                  'book_id': b.bookId,
                  'chapter': b.chapter,
                  'verse': b.verse,
                  'created_at': b.createdAt.toIso8601String(),
                })
            .toList(),
        'highlights': highlights
            .map((h) => {
                  'book_id': h.bookId,
                  'chapter': h.chapter,
                  'verse': h.verse,
                  'color_hex': h.colorHex,
                  'created_at': h.createdAt.toIso8601String(),
                })
            .toList(),
        'notes': notes
            .map((n) => {
                  'book_id': n.bookId,
                  'chapter': n.chapter,
                  'verse': n.verse,
                  'note_text': n.noteText,
                  'updated_at': n.updatedAt.toIso8601String(),
                })
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/amharic_bible_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'የመጽሐፍ ቅዱስ መጠባበቂያ ፋይል (Holy Bible Backup Data)',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('መጠባበቂያ ማስቀመጥ አልተቻለም: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);
    final themeNotifier = ref.read(themeConfigProvider.notifier);
    final bibleState = ref.watch(bibleStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ማስተካከያዎች (Settings)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Translation
          _buildSectionHeader('ትርጉም (Bible Translation)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: bibleState.translations.map((t) {
                final isSelected = bibleState.currentTranslation?.id == t.id;
                final subtitleText = t.id == 2
                    ? 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና'
                    : (t.id == 1
                        ? 'የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም (66 መጻሕፍት)'
                        : 'Authorized King James Version (Classic English)');

                // ignore: deprecated_member_use
                return RadioListTile<int>(
                  value: t.id,
                  // ignore: deprecated_member_use
                  groupValue: bibleState.currentTranslation?.id,
                  selected: isSelected,
                  title: Text(
                    t.name,
                    style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    subtitleText,
                    style: GoogleFonts.notoSansEthiopic(fontSize: 12),
                  ),
                  // ignore: deprecated_member_use
                  onChanged: (_) {
                    ref.read(bibleStateProvider.notifier).selectTranslation(t);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Section: Reader Theme
          _buildSectionHeader('የንባብ ገጽታ (Reading Theme)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeOption(
                    context,
                    label: 'ቀን (Day)',
                    color: const Color(0xFFFAFAF7),
                    textColor: Colors.black87,
                    isSelected: themeConfig.mode == ReaderThemeMode.light,
                    onTap: () => themeNotifier.setMode(ReaderThemeMode.light),
                  ),
                  _buildThemeOption(
                    context,
                    label: 'ብራና (Sepia)',
                    color: const Color(0xFFF4ECD8),
                    textColor: const Color(0xFF382C1E),
                    isSelected: themeConfig.mode == ReaderThemeMode.sepia,
                    onTap: () => themeNotifier.setMode(ReaderThemeMode.sepia),
                  ),
                  _buildThemeOption(
                    context,
                    label: 'ሌሊት (Dark)',
                    color: const Color(0xFF121212),
                    textColor: Colors.white70,
                    isSelected: themeConfig.mode == ReaderThemeMode.dark,
                    onTap: () => themeNotifier.setMode(ReaderThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section: Typography & Sizing
          _buildSectionHeader('የፊደል መጠንና ቁጥሮች (Typography)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size),
                      const SizedBox(width: 8),
                      Text('የፊደል መጠን (Font Size): ${themeConfig.fontSize.toInt()}sp'),
                    ],
                  ),
                  Slider(
                    value: themeConfig.fontSize,
                    min: 14.0,
                    max: 34.0,
                    divisions: 20,
                    label: '${themeConfig.fontSize.toInt()}',
                    onChanged: (val) => themeNotifier.setFontSize(val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('የግዕዝ ቁጥሮች ተጠቀም (Use Ge\'ez Numerals)'),
                    subtitle: const Text('፩, ፪, ፫, ፬... በምዕራፍና ቁጥር ላይ ያሳያል'),
                    value: themeConfig.useGeezNumerals,
                    onChanged: (_) => themeNotifier.toggleGeezNumerals(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section: Data Backup & Safety
          _buildSectionHeader('የውሂብ መጠባበቂያ (Data Backup & Safety)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blueAccent),
              title: const Text('ማስታወሻዎችንና ዕልባቶችን አውርድ (Export Backup)'),
              subtitle: const Text('እንደ JSON ፋይል ወደ ስልክ ወይም ደመና (Drive/iCloud) ያስቀምጡ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportBackup(context, ref),
            ),
          ),
          const SizedBox(height: 30),

          Center(
            child: Text(
              'መጽሐፍ ቅዱስ (Holy Bible)\nስሪት 1.0 • Multiplatform Native',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'ሀሁ',
              style: GoogleFonts.notoSansEthiopic(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
