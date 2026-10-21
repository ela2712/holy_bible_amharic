import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/translation.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/ethiopian_cross_painter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);
    final themeNotifier = ref.read(themeConfigProvider.notifier);
    final bibleState = ref.watch(bibleStateProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);
    final languageMode = ref.watch(appLanguageProvider);
    final notifState = ref.watch(dailyNotificationProvider);
    final notifNotifier = ref.read(dailyNotificationProvider.notifier);

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // 1. Editorial Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeConfig.accentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(22, 22),
                          painter: EthiopianCrossPainter(
                            style: EthiopianCrossStyle.lalibela,
                            color: themeConfig.accentColor,
                            strokeWidth: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isEnglish ? 'Settings' : 'ማስተካከያዎች',
                      style: isEnglish
                          ? GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.textColor,
                            )
                          : GoogleFonts.notoSansEthiopic(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.textColor,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Settings Content List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Section: Translation Selection
                  _buildSectionHeader(
                    isEnglish ? 'Bible Translation' : 'የመጽሐፍ ቅዱስ ትርጉም',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Column(
                      children: bibleState.translations.map((t) {
                        final isSelected = bibleState.currentTranslation?.id == t.id;
                        return _buildTranslationCard(
                          translation: t,
                          isSelected: isSelected,
                          themeConfig: themeConfig,
                          isEnglish: isEnglish,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(bibleStateProvider.notifier).selectTranslation(t);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Interface Language
                  _buildSectionHeader(
                    isEnglish ? 'Interface Language' : 'የመተግበሪያ ቋንቋ',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          _buildLanguageOption(
                            label: isEnglish ? 'Auto' : 'አውቶማቲክ',
                            subtitle: isEnglish ? 'Match Bible' : 'ከመጽሐፉ ጋር',
                            icon: Icons.sync_rounded,
                            isSelected: languageMode == AppLanguageMode.auto,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () => ref
                                .read(appLanguageProvider.notifier)
                                .setLanguageMode(AppLanguageMode.auto),
                          ),
                          const SizedBox(width: 8),
                          _buildLanguageOption(
                            label: 'አማርኛ',
                            subtitle: isEnglish ? 'Amharic UI' : 'ቋሚ አማርኛ',
                            icon: Icons.translate_rounded,
                            isSelected: languageMode == AppLanguageMode.amharic,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () => ref
                                .read(appLanguageProvider.notifier)
                                .setLanguageMode(AppLanguageMode.amharic),
                          ),
                          const SizedBox(width: 8),
                          _buildLanguageOption(
                            label: 'English',
                            subtitle: isEnglish ? 'English UI' : 'ቋሚ እንግሊዝኛ',
                            icon: Icons.language_rounded,
                            isSelected: languageMode == AppLanguageMode.english,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () => ref
                                .read(appLanguageProvider.notifier)
                                .setLanguageMode(AppLanguageMode.english),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Reading Theme
                  _buildSectionHeader(
                    isEnglish ? 'Reading Theme' : 'የንባብ ገጽታ',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildThemeOption(
                            label: isEnglish ? 'Light' : 'ቀን',
                            previewBg: const Color(0xFFFAF9F6),
                            previewInk: const Color(0xFF18181B),
                            isSelected: themeConfig.mode == ReaderThemeMode.light,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeNotifier.setMode(ReaderThemeMode.light);
                            },
                          ),
                          _buildThemeOption(
                            label: isEnglish ? 'Sepia' : 'ብራና',
                            previewBg: const Color(0xFFF4EFE6),
                            previewInk: const Color(0xFF26221E),
                            isSelected: themeConfig.mode == ReaderThemeMode.sepia,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeNotifier.setMode(ReaderThemeMode.sepia);
                            },
                          ),
                          _buildThemeOption(
                            label: isEnglish ? 'Dark' : 'ጨለማ',
                            previewBg: const Color(0xFF0E1014),
                            previewInk: const Color(0xFFF3F4F6),
                            isSelected: themeConfig.mode == ReaderThemeMode.dark,
                            themeConfig: themeConfig,
                            isEnglish: isEnglish,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeNotifier.setMode(ReaderThemeMode.dark);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Font Family Selection
                  _buildSectionHeader(
                    isEnglish ? 'Font Family' : 'የፊደል ቅርጽ',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildFontFamilyItem(
                              label: 'ሴሪፍ',
                              subLabel: 'Noto Serif',
                              sampleText: 'በመጀመሪያ',
                              sampleStyle: GoogleFonts.notoSerifEthiopic(fontWeight: FontWeight.w700),
                              isSelected: themeConfig.fontFamily == 'Serif',
                              themeConfig: themeConfig,
                              onTap: () => themeNotifier.setFontFamily('Serif'),
                            ),
                            const SizedBox(width: 8),
                            _buildFontFamilyItem(
                              label: 'ሳንስ',
                              subLabel: 'Noto Sans',
                              sampleText: 'በመጀመሪያ',
                              sampleStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700),
                              isSelected: themeConfig.fontFamily == 'Sans',
                              themeConfig: themeConfig,
                              onTap: () => themeNotifier.setFontFamily('Sans'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildFontFamilyItem(
                              label: 'አቢሲኒካ',
                              subLabel: 'Abyssinica',
                              sampleText: 'በመጀመሪያ',
                              sampleStyle: GoogleFonts.abyssinicaSil(fontWeight: FontWeight.w700),
                              isSelected: themeConfig.fontFamily == 'Abyssinica',
                              themeConfig: themeConfig,
                              onTap: () => themeNotifier.setFontFamily('Abyssinica'),
                            ),
                            const SizedBox(width: 8),
                            _buildFontFamilyItem(
                              label: 'ፓወር ግዕዝ',
                              subLabel: 'Power Ge\'ez',
                              sampleText: 'በመጀመሪያ',
                              sampleStyle: const TextStyle(
                                fontFamily: 'Power Ge\'ez Unicode',
                                fontFamilyFallback: [
                                  'PowerGeez',
                                  'Power Ge\'ez',
                                  'Nyala',
                                  'WashRa',
                                  'Abyssinica SIL',
                                  'Noto Serif Ethiopic',
                                ],
                                fontWeight: FontWeight.w700,
                              ),
                              isSelected: themeConfig.fontFamily == 'PowerGeez',
                              themeConfig: themeConfig,
                              onTap: () => themeNotifier.setFontFamily('PowerGeez'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Typography & Layout Options
                  _buildSectionHeader(
                    isEnglish ? 'Typography & Reading Mode' : 'የፊደል መጠንና አቀራረብ',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Column(
                      children: [
                        // Font Size Slider
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? 'Font Size' : 'የፊደል መጠን',
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: themeConfig.textColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: themeConfig.textColor,
                                      ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: themeConfig.accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${themeConfig.fontSize.toInt()} pt',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: themeConfig.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: themeConfig.accentColor,
                            inactiveTrackColor: themeConfig.cardBorderColor,
                            thumbColor: themeConfig.accentColor,
                            overlayColor: themeConfig.accentColor.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: themeConfig.fontSize,
                            min: 14.0,
                            max: 34.0,
                            divisions: 20,
                            onChanged: (val) => themeNotifier.setFontSize(val),
                          ),
                        ),
                        Divider(color: themeConfig.cardBorderColor.withValues(alpha: 0.5), height: 16),

                        // Ge'ez Numerals Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isEnglish ? 'Ge\'ez Numerals' : 'የግዕዝ ቁጥሮች',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          subtitle: Text(
                            isEnglish
                                ? 'Displays chapter and verse numbers as ፩, ፪, ፫, ፬...'
                                : '፩, ፪, ፫, ፬... በምዕራፍና በቁጥሮች ላይ ያሳያል',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                          ),
                          activeThumbColor: themeConfig.accentColor,
                          value: themeConfig.useGeezNumerals,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            themeNotifier.toggleGeezNumerals();
                          },
                        ),
                        Divider(color: themeConfig.cardBorderColor.withValues(alpha: 0.5), height: 16),

                        // Continuous Paragraph Mode Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isEnglish ? 'Continuous Paragraph Mode' : 'ተከታታይ አንቀጽ',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          subtitle: Text(
                            isEnglish
                                ? 'Flows scripture as continuous paragraphs without line breaks'
                                : 'ቁጥሮችን ሳይቆራርጡ እንደ መጽሐፍ አንቀጽ ያነባል',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                          ),
                          activeThumbColor: themeConfig.accentColor,
                          value: themeConfig.isParagraphMode,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            themeNotifier.toggleParagraphMode(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Daily Verse Push Notification
                  _buildSectionHeader(
                    isEnglish ? 'Daily Verse Reminder' : 'ዕለታዊ የጥቅስ ማስታወሻ',
                    themeConfig,
                    isEnglish,
                  ),
                  _buildSettingContainer(
                    themeConfig: themeConfig,
                    isDark: isDark,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isEnglish ? 'Daily Verse Notification' : 'የዕለት ጥቅስ ማሳወቂያ',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          subtitle: Text(
                            isEnglish
                                ? 'Receive an inspiring scripture every morning at scheduled time'
                                : 'በተመረጠው ሰዓት አነቃቂ የዕለት ጥቅስ ማስታወሻ ይደርስዎታል',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 12,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                          ),
                          activeThumbColor: themeConfig.accentColor,
                          value: notifState.isEnabled,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            notifNotifier.toggleDailyNotification(val, isEnglish: isEnglish);
                          },
                        ),
                        if (notifState.isEnabled) ...[
                          Divider(color: themeConfig.cardBorderColor.withValues(alpha: 0.5), height: 16),
                          InkWell(
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: notifState.hour,
                                  minute: notifState.minute,
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme(
                                        brightness: isDark ? Brightness.dark : Brightness.light,
                                        primary: themeConfig.accentColor,
                                        onPrimary: Colors.white,
                                        surface: themeConfig.surfaceColor,
                                        onSurface: themeConfig.textColor,
                                        secondary: themeConfig.accentColor,
                                        onSecondary: Colors.white,
                                        error: Colors.redAccent,
                                        onError: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                notifNotifier.updateTime(picked, isEnglish: isEnglish);
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.alarm_rounded,
                                        size: 20,
                                        color: themeConfig.accentColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        isEnglish ? 'Delivery Time' : 'የሚላክበት ሰዓት',
                                        style: isEnglish
                                            ? GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                                color: themeConfig.textColor,
                                              )
                                            : GoogleFonts.notoSansEthiopic(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                                color: themeConfig.textColor,
                                              ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: themeConfig.accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: themeConfig.accentColor.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          notifState.formatDisplayTime(isEnglish),
                                          style: isEnglish
                                              ? GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.5,
                                                  color: themeConfig.accentColor,
                                                )
                                              : GoogleFonts.notoSansEthiopic(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.5,
                                                  color: themeConfig.accentColor,
                                                ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_right_rounded,
                                          size: 16,
                                          color: themeConfig.accentColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                notifNotifier.sendTestNotification(isEnglish: isEnglish);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEnglish
                                          ? 'Sample verse notification sent'
                                          : 'የሙከራ የዕለት ጥቅስ ማሳወቂያ ተልኳል',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.send_rounded,
                                size: 14,
                                color: themeConfig.accentColor,
                              ),
                              label: Text(
                                isEnglish ? 'Preview Notification' : 'ማሳወቂያውን ሞክር',
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: themeConfig.accentColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: themeConfig.accentColor,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // App Brand Footer (Reverent, no technical jargon!)
                  Center(
                    child: Column(
                      children: [
                        CustomPaint(
                          size: const Size(24, 24),
                          painter: EthiopianCrossPainter(
                            style: EthiopianCrossStyle.lalibela,
                            color: themeConfig.accentColor.withValues(alpha: 0.6),
                            strokeWidth: 1.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isEnglish
                              ? 'Holy Bible — Ethiopian Orthodox 81 Canon'
                              : 'መጽሐፍ ቅዱስ — 81 ቀኖና',
                          textAlign: TextAlign.center,
                          style: isEnglish
                              ? GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: themeConfig.textColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: themeConfig.textColor,
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEnglish
                              ? 'Ethiopian Orthodox Tewahedo Church'
                              : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን',
                          textAlign: TextAlign.center,
                          style: isEnglish
                              ? GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: themeConfig.secondaryTextColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: themeConfig.secondaryTextColor,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEnglish
                              ? 'Version 1.0.0 (Build 1)'
                              : 'ስሪት 1.0.0 (ቅጂ 1)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: themeConfig.secondaryTextColor.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ReaderThemeConfig themeConfig, bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: isEnglish
            ? GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: themeConfig.accentColor,
              )
            : GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: themeConfig.accentColor,
              ),
      ),
    );
  }

  Widget _buildSettingContainer({
    required ReaderThemeConfig themeConfig,
    required bool isDark,
    required Widget child,
  }) {
    return Material(
      color: themeConfig.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: themeConfig.cardBorderColor,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildTranslationCard({
    required Translation translation,
    required bool isSelected,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
    required VoidCallback onTap,
  }) {
    final subtitleText = translation.id == 2
        ? (isEnglish
            ? 'Ethiopian Orthodox Tewahedo 81 Books Canon'
            : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና')
        : (translation.id == 1
            ? (isEnglish
                ? 'Emperor Haile Selassie 1954 Translation (66 Books)'
                : 'የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም (66 መጻሕፍት)')
            : (isEnglish
                ? 'Authorized King James Version (Classic English)'
                : 'የኪንግ ጀምስ 1611 የእንግሊዝኛ ትርጉም'));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeConfig.accentColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        translation.name,
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14.5,
                                color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                              ),
                      ),
                      if (translation.id == 2) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeConfig.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEnglish ? 'Primary' : 'ዋና ቀኖና',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: themeConfig.accentColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: themeConfig.accentColor,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitleText,
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 11.5,
                            color: themeConfig.secondaryTextColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 12,
                            color: themeConfig.secondaryTextColor,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? themeConfig.accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? themeConfig.accentColor : themeConfig.secondaryTextColor.withValues(alpha: 0.4),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required Color previewBg,
    required Color previewInk,
    required bool isSelected,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 52,
            decoration: BoxDecoration(
              color: previewBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: themeConfig.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isEnglish ? 'Aa' : 'ሀሁ',
              style: isEnglish
                  ? GoogleFonts.inter(
                      color: previewInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      color: previewInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: isEnglish
                ? GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                  )
                : GoogleFonts.notoSansEthiopic(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontFamilyItem({
    required String label,
    required String subLabel,
    required String sampleText,
    required TextStyle sampleStyle,
    required bool isSelected,
    required ReaderThemeConfig themeConfig,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? themeConfig.accentColor.withValues(alpha: 0.08)
                : themeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, size: 16, color: themeConfig.accentColor),
                ],
              ),
              Text(
                subLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: themeConfig.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sampleText,
                style: sampleStyle.copyWith(
                  fontSize: 15,
                  color: themeConfig.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? themeConfig.accentColor.withValues(alpha: 0.10)
                : themeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? themeConfig.accentColor : themeConfig.secondaryTextColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isEnglish
                    ? GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                      )
                    : GoogleFonts.notoSansEthiopic(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                      ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isEnglish
                    ? GoogleFonts.inter(
                        fontSize: 10,
                        color: themeConfig.secondaryTextColor,
                      )
                    : GoogleFonts.notoSansEthiopic(
                        fontSize: 9.5,
                        color: themeConfig.secondaryTextColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
