import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/ethiopian_cross_painter.dart';

enum CardAspectRatio {
  square(1.0, 'ካሬ (1:1)', 'Square (1:1)'),
  portrait(4 / 5, 'ፖርትሬት (4:5)', 'Portrait (4:5)'),
  story(9 / 16, 'ስቶሪ (9:16)', 'Story (9:16)'),
  landscape(16 / 9, 'ሰፊ (16:9)', 'Wide (16:9)');

  final double ratio;
  final String labelAm;
  final String labelEn;
  const CardAspectRatio(this.ratio, this.labelAm, this.labelEn);

  String getDisplayLabel(bool isEnglish) => isEnglish ? labelEn : labelAm;
}

class CardThemePreset {
  final String name;
  final String nameEn;
  final List<Color> backgroundColors;
  final Color textColor;
  final Color accentColor;
  final Color watermarkColor;
  final Color haragPrimary;
  final Color haragSecondary;

  const CardThemePreset({
    required this.name,
    required this.nameEn,
    required this.backgroundColors,
    required this.textColor,
    required this.accentColor,
    required this.watermarkColor,
    required this.haragPrimary,
    required this.haragSecondary,
  });

  String getDisplayName(bool isEnglish) => isEnglish ? nameEn : name;
}

class VerseCardMakerScreen extends ConsumerStatefulWidget {
  final String reference;
  final String verseText;

  const VerseCardMakerScreen({
    super.key,
    required this.reference,
    required this.verseText,
  });

  @override
  ConsumerState<VerseCardMakerScreen> createState() => _VerseCardMakerScreenState();
}

class _VerseCardMakerScreenState extends ConsumerState<VerseCardMakerScreen> {
  final GlobalKey _cardKey = GlobalKey();

  int _selectedPresetIndex = 0;
  CardAspectRatio _aspectRatio = CardAspectRatio.square;
  EthiopianCrossStyle _crossStyle = EthiopianCrossStyle.lalibela;
  double _crossOpacity = 0.18;
  bool _showHaragBorder = true;
  String _fontFamily = 'Serif'; // 'Serif' = Noto Serif Ethiopic, 'Sans' = Noto Sans Ethiopic
  double _fontSize = 18.0;
  TextAlign _alignment = TextAlign.center;
  bool _isGenerating = false;

  static const List<CardThemePreset> _presets = [
    // 1. Ancient Ethiopian Parchment (ብራና)
    CardThemePreset(
      name: 'የጥንት ብራና',
      nameEn: 'Ancient Parchment',
      backgroundColors: [Color(0xFFF7F2E7), Color(0xFFEBE0CC)],
      textColor: Color(0xFF1F1A14),
      accentColor: Color(0xFF065F46),
      watermarkColor: Color(0xFF047857),
      haragPrimary: Color(0xFF047857),
      haragSecondary: Color(0xFF0D9488),
    ),
    // 2. Lalibela Rock-Hewn Sandstone & Gold (ላሊበላ)
    CardThemePreset(
      name: 'የላሊበላ ድንጋይ',
      nameEn: 'Lalibela Rock',
      backgroundColors: [Color(0xFF2C1810), Color(0xFF4A1F18)],
      textColor: Color(0xFFFDFBF7),
      accentColor: Color(0xFFFFD54F),
      watermarkColor: Color(0xFFFFD54F),
      haragPrimary: Color(0xFFFFD54F),
      haragSecondary: Color(0xFFC5A059),
    ),
    // 3. Axumite Monastic Obsidian & Gold Leaf (አክሱም)
    CardThemePreset(
      name: 'የአክሱም ጽላት',
      nameEn: 'Axumite Tablet',
      backgroundColors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      textColor: Color(0xFFF8FAFC),
      accentColor: Color(0xFF38BDF8),
      watermarkColor: Color(0xFF38BDF8),
      haragPrimary: Color(0xFF38BDF8),
      haragSecondary: Color(0xFF818CF8),
    ),
    // 4. Gondar Imperial Velvet Crimson (ጎንደር)
    CardThemePreset(
      name: 'የጎንደር ሐር',
      nameEn: 'Gondar Velvet',
      backgroundColors: [Color(0xFF3B0B13), Color(0xFF6B1422)],
      textColor: Color(0xFFFFF7ED),
      accentColor: Color(0xFFFBBF24),
      watermarkColor: Color(0xFFFBBF24),
      haragPrimary: Color(0xFFFBBF24),
      haragSecondary: Color(0xFFEA580C),
    ),
    // 5. Debre Damo Mountain Mist & Emerald (ደብረ ዳሞ)
    CardThemePreset(
      name: 'ደብረ ዳሞ',
      nameEn: 'Debre Damo',
      backgroundColors: [Color(0xFF062C20), Color(0xFF0E4D3A)],
      textColor: Color(0xFFF0FDF4),
      accentColor: Color(0xFF34D399),
      watermarkColor: Color(0xFF34D399),
      haragPrimary: Color(0xFF34D399),
      haragSecondary: Color(0xFFA7F3D0),
    ),
    // 6. Modern Editorial Obsidian & Titanium (ዘመናዊ ስሌት)
    CardThemePreset(
      name: 'ዘመናዊ ስሌት',
      nameEn: 'Modern Obsidian',
      backgroundColors: [Color(0xFF090A0F), Color(0xFF161824)],
      textColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFE2E8F0),
      watermarkColor: Color(0xFF94A3B8),
      haragPrimary: Color(0xFF64748B),
      haragSecondary: Color(0xFF94A3B8),
    ),
  ];

  Future<void> _captureAndShare(bool isEnglish) async {
    setState(() => _isGenerating = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'verse_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      final shareText = isEnglish
          ? '${widget.reference}\n«${widget.verseText}»\n— Holy Bible App'
          : '${widget.reference}\n«${widget.verseText}»\n— ከመጽሐፍ ቅዱስ መተግበሪያ';

      await Share.shareXFiles(
        [xFile],
        text: shareText,
      );
    } catch (e) {
      if (mounted) {
        final errorMsg = isEnglish
            ? 'Unable to share image: $e'
            : 'ምስሉን ማጋራት አልተቻለም: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isEnglish = ref.watch(isEnglishUiProvider);
    final theme = Theme.of(context);
    final preset = _presets[_selectedPresetIndex];

    final cardWidth = 330.0;
    final cardHeight = cardWidth / _aspectRatio.ratio;

    final bodyFont = _fontFamily == 'Serif'
        ? (isEnglish ? GoogleFonts.merriweather : GoogleFonts.notoSerifEthiopic)
        : (isEnglish ? GoogleFonts.inter : GoogleFonts.notoSansEthiopic);

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeConfig.surfaceColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Verse Card Maker' : 'የጥቅስ ምስል አዘጋጅ',
              style: isEnglish
                  ? GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: themeConfig.textColor)
                  : GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w900, color: themeConfig.textColor),
            ),
            Text(
              isEnglish ? 'ILLUMINATED MANUSCRIPT CARD' : 'የብራና ጽሑፍና የጥቅስ ምስል',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: themeConfig.accentColor,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeConfig.accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isGenerating ? null : () => _captureAndShare(isEnglish),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded, size: 16),
              label: Text(
                isEnglish ? 'Share' : 'አጋራ',
                style: isEnglish
                    ? GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)
                    : GoogleFonts.notoSansEthiopic(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Render Card with RepaintBoundary
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: preset.backgroundColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // A. Orthodox Cross Watermark Layer
                        if (_crossStyle != EthiopianCrossStyle.none)
                          Positioned.fill(
                            child: Center(
                              child: Opacity(
                                opacity: _crossOpacity,
                                child: CustomPaint(
                                  size: Size(cardWidth * 0.72, cardWidth * 0.72),
                                  painter: EthiopianCrossPainter(
                                    style: _crossStyle,
                                    color: preset.watermarkColor,
                                    strokeWidth: 2.2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // B. Traditional Illuminated Haräg Border Layer
                        if (_showHaragBorder)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: EthiopianHaragBorderPainter(
                                primaryColor: preset.haragPrimary.withValues(alpha: 0.75),
                                secondaryColor: preset.haragSecondary.withValues(alpha: 0.85),
                                borderWidth: 14,
                              ),
                            ),
                          ),

                        // C. Main Content Layer (Verse, Reference, Emblem)
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _showHaragBorder ? 28 : 22,
                              vertical: _showHaragBorder ? 26 : 22,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Ornamental Cross Emblem
                                Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: preset.accentColor.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: OrthodoxCrossIcon(
                                        size: 18,
                                        color: preset.accentColor,
                                        style: _crossStyle == EthiopianCrossStyle.none
                                            ? EthiopianCrossStyle.lalibela
                                            : _crossStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Scripture Text
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '«${widget.verseText}»',
                                      textAlign: _alignment,
                                      style: bodyFont(
                                        fontSize: _fontSize,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600,
                                        color: preset.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Reference & Signature Tag
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: preset.accentColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.reference,
                                        textAlign: TextAlign.center,
                                        style: isEnglish
                                            ? GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                color: preset.accentColor,
                                                letterSpacing: 0.4,
                                              )
                                            : GoogleFonts.notoSansEthiopic(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                color: preset.accentColor,
                                                letterSpacing: 0.4,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isEnglish ? 'HOLY BIBLE • መጽሐፍ ቅዱስ' : 'መጽሐፍ ቅዱስ • HOLY BIBLE',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                        color: preset.textColor.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Preset Background Themes (Horizontal Carousel)
            _buildSectionTitle(
              isEnglish ? 'Manuscript Preset Texture:' : 'የጀርባና የብራና ገጽታ፦',
              isEnglish,
              themeConfig,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final item = _presets[idx];
                  final isSelected = _selectedPresetIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPresetIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: item.backgroundColors),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? themeConfig.accentColor : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.getDisplayName(isEnglish),
                          style: isEnglish
                              ? GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: item.textColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: item.textColor,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 3. Orthodox Cross Watermark Selector
            _buildSectionTitle(
              isEnglish ? 'Orthodox Cross Watermark:' : 'የመስቀል ምልክት (ውኃ መልክ)፦',
              isEnglish,
              themeConfig,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCrossOption(
                  style: EthiopianCrossStyle.lalibela,
                  label: isEnglish ? 'Lalibela' : 'ላሊበላ',
                  theme: theme,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
                const SizedBox(width: 8),
                _buildCrossOption(
                  style: EthiopianCrossStyle.axum,
                  label: isEnglish ? 'Axum' : 'አክሱም',
                  theme: theme,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
                const SizedBox(width: 8),
                _buildCrossOption(
                  style: EthiopianCrossStyle.gondar,
                  label: isEnglish ? 'Gondar' : 'ጎንደር',
                  theme: theme,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
                const SizedBox(width: 8),
                _buildCrossOption(
                  style: EthiopianCrossStyle.none,
                  label: isEnglish ? 'None' : 'ያለ መስቀል',
                  theme: theme,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
              ],
            ),
            if (_crossStyle != EthiopianCrossStyle.none) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    isEnglish ? 'Opacity:' : 'የመስቀሉ ድምቀት፦',
                    style: TextStyle(fontSize: 12, color: themeConfig.secondaryTextColor),
                  ),
                  Expanded(
                    child: Slider(
                      value: _crossOpacity,
                      min: 0.05,
                      max: 0.45,
                      divisions: 8,
                      activeColor: themeConfig.accentColor,
                      label: '${(_crossOpacity * 100).toInt()}%',
                      onChanged: (val) => setState(() => _crossOpacity = val),
                    ),
                  ),
                  Text(
                    '${(_crossOpacity * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeConfig.textColor),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),

            // 4. Aspect Ratio & Haräg Border Toggles
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(isEnglish ? 'Aspect Ratio:' : 'መጠን፦', isEnglish, themeConfig),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: CardAspectRatio.values.map((r) {
                          final isSelected = _aspectRatio == r;
                          return GestureDetector(
                            onTap: () => setState(() => _aspectRatio = r),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? themeConfig.accentColor
                                    : themeConfig.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? themeConfig.accentColor
                                      : themeConfig.cardBorderColor,
                                ),
                              ),
                              child: Text(
                                r.getDisplayLabel(isEnglish),
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : themeConfig.textColor,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : themeConfig.textColor,
                                      ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(isEnglish ? 'Illuminated Border:' : 'የብራና ሐረግ፦', isEnglish, themeConfig),
                    const SizedBox(height: 6),
                    FilterChip(
                      selected: _showHaragBorder,
                      backgroundColor: themeConfig.surfaceColor,
                      selectedColor: themeConfig.goldAccent.withValues(alpha: 0.2),
                      checkmarkColor: themeConfig.goldAccent,
                      avatar: Icon(Icons.border_outer_rounded, size: 16, color: themeConfig.goldAccent),
                      label: Text(
                        _showHaragBorder
                            ? (isEnglish ? 'Border On' : 'ሐረግ አለ')
                            : (isEnglish ? 'Border Off' : 'ሐረግ የለም'),
                        style: isEnglish
                            ? GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor)
                            : GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor),
                      ),
                      onSelected: (val) => setState(() => _showHaragBorder = val),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 5. Typography Controls (Font Switcher, Size, Alignment)
            _buildSectionTitle(isEnglish ? 'Typography & Alignment:' : 'የፊደል ቅርጽና አቀማመጥ፦', isEnglish, themeConfig),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'Serif',
                        label: Text(
                          isEnglish ? 'Serif' : 'ባህላዊ ብራና',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ButtonSegment(
                        value: 'Sans',
                        label: Text(
                          isEnglish ? 'Sans' : 'ዘመናዊ',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    selected: {_fontFamily},
                    onSelectionChanged: (set) => setState(() => _fontFamily = set.first),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_align_left_rounded),
                      color: _alignment == TextAlign.left ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                      onPressed: () => setState(() => _alignment = TextAlign.left),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_align_center_rounded),
                      color: _alignment == TextAlign.center ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                      onPressed: () => setState(() => _alignment = TextAlign.center),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_align_right_rounded),
                      color: _alignment == TextAlign.right ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                      onPressed: () => setState(() => _alignment = TextAlign.right),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.format_size_rounded, size: 20, color: themeConfig.secondaryTextColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 13.0,
                    max: 26.0,
                    divisions: 13,
                    activeColor: themeConfig.accentColor,
                    label: '${_fontSize.toInt()}pt',
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                ),
                Text(
                  '${_fontSize.toInt()}pt',
                  style: TextStyle(fontWeight: FontWeight.bold, color: themeConfig.textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isEnglish, ReaderThemeConfig themeConfig) {
    return Text(
      title,
      style: isEnglish
          ? GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: themeConfig.textColor)
          : GoogleFonts.notoSansEthiopic(fontSize: 13, fontWeight: FontWeight.w800, color: themeConfig.textColor),
    );
  }

  Widget _buildCrossOption({
    required EthiopianCrossStyle style,
    required String label,
    required ThemeData theme,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _crossStyle == style;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _crossStyle = style),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : themeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              style == EthiopianCrossStyle.none
                  ? Text(
                      '—',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : themeConfig.secondaryTextColor,
                      ),
                    )
                  : OrthodoxCrossIcon(
                      size: 16,
                      color: isSelected ? Colors.white : themeConfig.accentColor,
                      style: style,
                    ),
              const SizedBox(height: 2),
              Text(
                label,
                style: isEnglish
                    ? GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      )
                    : GoogleFonts.notoSansEthiopic(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
