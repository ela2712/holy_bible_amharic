import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/theme_provider.dart';
import 'ethiopian_cross_painter.dart';

/// Reverent First-Time User Experience (FTUE) Welcome Sheet
/// Introduces the Ethiopian Orthodox 81 Books Canon, gestures, homophone search, and study tools.
class FtueWelcomeSheet extends ConsumerWidget {
  final bool markAsShownOnClose;

  const FtueWelcomeSheet({
    super.key,
    this.markAsShownOnClose = true,
  });

  /// Static key for persistent storage
  static const String prefsKey = 'ftue_welcome_shown_v1';

  /// Convenience launcher
  static Future<void> show(
    BuildContext context, {
    bool markAsShown = true,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => FtueWelcomeSheet(markAsShownOnClose: markAsShown),
    );
  }

  Future<void> _recordShown() async {
    if (markAsShownOnClose) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefsKey, true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: themeConfig.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: themeConfig.accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Top Drag Handle & Close Bar
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 12, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  // Center drag pill
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: themeConfig.cardBorderColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: themeConfig.secondaryTextColor,
                    ),
                    splashRadius: 18,
                    onPressed: () async {
                      await _recordShown();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  children: [
                    // Lalibela Cross Badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeConfig.accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                        border: Border.all(
                          color: themeConfig.accentColor.withValues(alpha: 0.40),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeConfig.accentColor.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(34, 34),
                          painter: EthiopianCrossPainter(
                            style: EthiopianCrossStyle.lalibela,
                            color: themeConfig.accentColor,
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Welcome Header
                    Text(
                      isEnglish ? 'Welcome to Holy Bible' : 'እንኳን ደህና መጡ',
                      textAlign: TextAlign.center,
                      style: isEnglish
                          ? GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.textColor,
                              letterSpacing: -0.3,
                            )
                          : GoogleFonts.notoSansEthiopic(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.textColor,
                              letterSpacing: -0.3,
                            ),
                    ),
                    const SizedBox(height: 5),

                    // Subtitle
                    Text(
                      isEnglish
                          ? 'Ethiopian Orthodox Tewahedo 81 Books Canon'
                          : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና',
                      textAlign: TextAlign.center,
                      style: isEnglish
                          ? GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeConfig.accentColor,
                            )
                          : GoogleFonts.notoSansEthiopic(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeConfig.accentColor,
                            ),
                    ),
                    const SizedBox(height: 22),

                    // 4 Feature Pillars
                    _buildFeatureCard(
                      themeConfig: themeConfig,
                      isDark: isDark,
                      isEnglish: isEnglish,
                      iconWidget: CustomPaint(
                        size: const Size(20, 20),
                        painter: EthiopianCrossPainter(
                          style: EthiopianCrossStyle.lalibela,
                          color: themeConfig.accentColor,
                          strokeWidth: 1.6,
                        ),
                      ),
                      title: isEnglish ? '81 Orthodox Canon' : '81 ሙሉ ቀኖና',
                      description: isEnglish
                          ? 'Includes all 54 Old Testament and 27 New Testament books preserved by the Ethiopian Orthodox Tewahedo Church.'
                          : 'የብሉይ ኪዳን 54 እና የሐዲስ ኪዳን 27 መጻሕፍትን ያካተተ ሙሉ የቀኖና ስብስብ።',
                    ),
                    const SizedBox(height: 12),

                    _buildFeatureCard(
                      themeConfig: themeConfig,
                      isDark: isDark,
                      isEnglish: isEnglish,
                      iconWidget: Icon(
                        Icons.search_rounded,
                        size: 21,
                        color: themeConfig.accentColor,
                      ),
                      title: isEnglish ? 'Smart Homophone Search' : 'የፊደላት አንድነት ፍለጋ',
                      description: isEnglish
                          ? 'Intelligent Ge\'ez homophone search harmonizing equivalent sounds (ሀ=ሐ=ኀ, ሠ=ሰ, ዐ=አ, ጸ=ፀ) seamlessly.'
                          : 'የግዕዝ ፊደላት ድምፅ ተዛምዶ (ሀ=ሐ=ኀ፣ ሠ=ሰ፣ ዐ=አ፣ ፀ=ጸ) ያካተተ ስማርት ፍለጋ።',
                    ),
                    const SizedBox(height: 12),

                    _buildFeatureCard(
                      themeConfig: themeConfig,
                      isDark: isDark,
                      isEnglish: isEnglish,
                      iconWidget: Icon(
                        Icons.touch_app_rounded,
                        size: 21,
                        color: themeConfig.accentColor,
                      ),
                      title: isEnglish ? 'Intuitive Reading & Study' : 'የንባብ ምልክቶችና ማስታወሻ',
                      description: isEnglish
                          ? 'Tap any verse for personal notes, 4-translation parallel comparison (Amharic 81, Ge\'ez 81, 1954, KJV), cross-references & verse cards; swipe horizontally to switch chapters.'
                          : 'ጥቅሶችን በመጫን ማስታወሻ፣ የ 4 ትርጉም ማነፃፀሪያ (81 ቀኖና፣ ግዕዝ 81፣ 1954፣ KJV)፣ ተዛማጅ ጥቅሶች እና የጥቅስ ካርድ ያግኙ፤ በጣቶችዎ በማንሸራተት ምዕራፎችን ይቀይሩ።',
                    ),
                    const SizedBox(height: 12),

                    _buildFeatureCard(
                      themeConfig: themeConfig,
                      isDark: isDark,
                      isEnglish: isEnglish,
                      iconWidget: Icon(
                        Icons.shield_outlined,
                        size: 21,
                        color: themeConfig.accentColor,
                      ),
                      title: isEnglish ? '100% Offline & Ad-Free' : 'ኦፍላይንና ከማስታወቂያ የጸዳ',
                      description: isEnglish
                          ? 'Works entirely offline with zero advertisements, preserving a holy, uninterrupted prayer and study environment.'
                          : 'ያለ ኢንተርኔት የሚሰራ፣ ከማንኛውም ማስታወቂያ የጸዳ ንጹሕ የጸሎት እና የንባብ መተግበሪያ።',
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await _recordShown();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeConfig.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEnglish ? 'Start Reading' : 'ወደ ንባብ ግባ',
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required ReaderThemeConfig themeConfig,
    required bool isDark,
    required bool isEnglish,
    required Widget iconWidget,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : themeConfig.backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeConfig.cardBorderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: themeConfig.accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: themeConfig.accentColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: themeConfig.textColor,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: themeConfig.textColor,
                        ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                          color: themeConfig.secondaryTextColor,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          color: themeConfig.secondaryTextColor,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
