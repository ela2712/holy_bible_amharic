import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
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
  bool _useGeezNumerals = false;
  bool _useRubrication = true;
  String _fontFamily = 'Serif'; // 'Serif', 'Sans', 'Abyssinica'
  double _fontSize = 18.0;
  TextAlign _alignment = TextAlign.center;
  bool _isGenerating = false;
  Uint8List? _customBackgroundBytes;

  static const List<CardThemePreset> _presets = [
    // 1. Ancient Parchment (ጥንታዊ ብራና)
    CardThemePreset(
      name: 'ጥንታዊ ብራና',
      nameEn: 'Ancient Parchment',
      backgroundColors: [Color(0xFFF9F5EB), Color(0xFFEFE5CE), Color(0xFFE2D3B3)],
      textColor: Color(0xFF1E1712),
      accentColor: Color(0xFF991B1B), // Vermilion rubrication accent
      watermarkColor: Color(0xFFB48A3C), // Gondar gold
      haragPrimary: Color(0xFF991B1B), // Vermilion cinnabar ink
      haragSecondary: Color(0xFF047857), // Malachite green ink
    ),

    // 2. Lalibela (ላሊበላ)
    CardThemePreset(
      name: 'ላሊበላ',
      nameEn: 'Lalibela',
      backgroundColors: [Color(0xFF2C1810), Color(0xFF4A1F18)],
      textColor: Color(0xFFFDFBF7),
      accentColor: Color(0xFFFFD54F),
      watermarkColor: Color(0xFFFFD54F),
      haragPrimary: Color(0xFFFFD54F),
      haragSecondary: Color(0xFFC5A059),
    ),
    // 3. Axumite (አክሱም)
    CardThemePreset(
      name: 'አክሱም',
      nameEn: 'Axumite',
      backgroundColors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      textColor: Color(0xFFF8FAFC),
      accentColor: Color(0xFF38BDF8),
      watermarkColor: Color(0xFF38BDF8),
      haragPrimary: Color(0xFF38BDF8),
      haragSecondary: Color(0xFF818CF8),
    ),
    // 4. Gondar (ጎንደር)
    CardThemePreset(
      name: 'ጎንደር',
      nameEn: 'Gondar',
      backgroundColors: [Color(0xFF3B0B13), Color(0xFF6B1422)],
      textColor: Color(0xFFFFF7ED),
      accentColor: Color(0xFFFBBF24),
      watermarkColor: Color(0xFFFBBF24),
      haragPrimary: Color(0xFFFBBF24),
      haragSecondary: Color(0xFFEA580C),
    ),
    // 5. Debre Damo (ደብረ ዳሞ)
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
    // 6. Obsidian (ስሌት)
    CardThemePreset(
      name: 'ስሌት',
      nameEn: 'Obsidian',
      backgroundColors: [Color(0xFF090A0F), Color(0xFF161824)],
      textColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFE2E8F0),
      watermarkColor: Color(0xFF94A3B8),
      haragPrimary: Color(0xFF64748B),
      haragSecondary: Color(0xFF94A3B8),
    ),
  ];

  Future<void> _pickCustomImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _customBackgroundBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking background image: $e');
    }
  }

  TextStyle _getScriptureStyle({
    required Color textColor,
    required double fontSize,
    required bool isEnglish,
  }) {
    if (isEnglish) {
      switch (_fontFamily) {
        case 'Sans':
          return GoogleFonts.inter(
            fontSize: fontSize,
            height: 1.55,
            fontWeight: FontWeight.w600,
            color: textColor,
          );
        case 'Abyssinica':
          return GoogleFonts.cormorantGaramond(
            fontSize: fontSize * 1.1,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          );
        case 'Serif':
        default:
          return GoogleFonts.merriweather(
            fontSize: fontSize,
            height: 1.6,
            fontWeight: FontWeight.w700,
            color: textColor,
          );
      }
    } else {
      switch (_fontFamily) {
        case 'Sans':
          return TextStyle(
            fontFamily: 'NotoSansEthiopic',
            fontFamilyFallback: const ['Noto Sans Ethiopic', 'Nyala', 'sans-serif'],
            fontSize: fontSize,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: textColor,
          );
        case 'Abyssinica':
          return TextStyle(
            fontFamily: 'AbyssinicaSIL',
            fontFamilyFallback: const ['Abyssinica SIL', 'Nyala', 'Noto Serif Ethiopic'],
            fontSize: fontSize * 1.05,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: textColor,
          );
        case 'Serif':
        default:
          return TextStyle(
            fontFamily: 'NotoSerifEthiopic',
            fontFamilyFallback: const ['Noto Serif Ethiopic', 'Nyala', 'serif'],
            fontSize: fontSize,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: textColor,
          );
      }
    }
  }

  String _formatCitation(String originalRef, bool useGeez) {
    if (!useGeez) return originalRef;
    final regex = RegExp(r'(\d+)\s*[:፡]\s*(\d+)(?:\s*[-–]\s*(\d+))?');
    final match = regex.firstMatch(originalRef);
    if (match == null) return originalRef;

    final chNum = int.tryParse(match.group(1) ?? '') ?? 1;
    final vNum = int.tryParse(match.group(2) ?? '') ?? 1;
    final endVStr = match.group(3);
    final endVNum = endVStr != null ? int.tryParse(endVStr) : null;

    final chGeez = GeezNumbers.toGeez(chNum);
    final vGeez = GeezNumbers.toGeez(vNum);
    String geezRefPart = '$chGeez፥$vGeez';
    if (endVNum != null) {
      geezRefPart += '–${GeezNumbers.toGeez(endVNum)}';
    }

    return originalRef.replaceRange(match.start, match.end, geezRefPart);
  }

  Widget _buildScriptureContent({
    required String text,
    required TextStyle baseStyle,
    required Color rubricColor,
    required bool useRubrication,
    required TextAlign alignment,
  }) {
    if (!useRubrication) {
      return Text(
        '«$text»',
        textAlign: alignment,
        style: baseStyle,
      );
    }

    final regex = RegExp(r'(እግዚአብሔር|ኢየሱስ|ክርስቶስ|ማርያም|መንፈስ ቅዱስ|እግዚእነ|God|Jesus|Christ|Lord)');
    final fullText = '«$text»';
    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in regex.allMatches(fullText)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: fullText.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: baseStyle.copyWith(
          color: rubricColor,
          fontWeight: FontWeight.w800,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < fullText.length) {
      spans.add(TextSpan(
        text: fullText.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      textAlign: alignment,
      text: TextSpan(children: spans),
    );
  }

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

      final effectiveRef = _formatCitation(widget.reference, _useGeezNumerals);
      final shareText = isEnglish
          ? '$effectiveRef\n«${widget.verseText}»\n— Holy Bible App'
          : '$effectiveRef\n«${widget.verseText}»\n— ከመጽሐፍ ቅዱስ መተግበሪያ';

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

    final scriptureTextStyle = _getScriptureStyle(
      textColor: preset.textColor,
      fontSize: _fontSize,
      isEnglish: isEnglish,
    );

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
              isEnglish ? 'SCRIPTURE CARD CREATOR' : 'የመጽሐፍ ቅዱስ ጥቅስ ምስል',
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
                        // A. Custom Gallery Background Photo (if selected)
                        if (_customBackgroundBytes != null) ...[
                          Positioned.fill(
                            child: Image.memory(
                              _customBackgroundBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.48),
                            ),
                          ),
                        ],

                        // B. Orthodox Cross Watermark Layer
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

                        // C. Traditional Illuminated Haräg Border Layer
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

                        // D. Main Content Layer (Verse, Reference, Emblem)
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
                                    child: _buildScriptureContent(
                                      text: widget.verseText,
                                      baseStyle: scriptureTextStyle,
                                      rubricColor: preset.accentColor,
                                      useRubrication: _useRubrication,
                                      alignment: _alignment,
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
                                        _formatCitation(widget.reference, _useGeezNumerals),
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
                                      isEnglish ? 'HOLY BIBLE' : 'መጽሐፍ ቅዱስ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                        color: preset.textColor.withValues(alpha: 0.65),
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

            // 2. Preset Background Themes + Custom Gallery Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(
                  isEnglish ? 'Preset Texture:' : 'የጀርባ ገጽታ፦',
                  isEnglish,
                  themeConfig,
                ),
                TextButton.icon(
                  onPressed: _pickCustomImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                  label: Text(
                    isEnglish ? 'Gallery Photo' : 'ከጋለሪ ምረጥ',
                    style: isEnglish
                        ? GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)
                        : GoogleFonts.notoSansEthiopic(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (_customBackgroundBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: themeConfig.accentColor),
                          const SizedBox(width: 5),
                          Text(
                            isEnglish ? 'Custom Photo Applied' : 'የግል ፎቶ ተመርጧል',
                            style: isEnglish
                                ? GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor)
                                : GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() => _customBackgroundBytes = null),
                      child: Text(
                        isEnglish ? 'Remove Photo' : 'ፎቶውን አስወግድ',
                        style: const TextStyle(fontSize: 11.5, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final item = _presets[idx];
                  final isSelected = _selectedPresetIndex == idx && _customBackgroundBytes == null;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPresetIndex = idx;
                        _customBackgroundBytes = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: item.textColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 12.5,
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

            // 3. Font Family Selector (Serif, Sans, Abyssinica)
            _buildSectionTitle(
              isEnglish ? 'Font Family:' : 'የፊደል ቅርጽ (ፎንት)፦',
              isEnglish,
              themeConfig,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFontChip(
                  id: 'Serif',
                  label: isEnglish ? 'Noto Serif' : 'ኖቶ ሰሪፍ',
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
                const SizedBox(width: 8),
                _buildFontChip(
                  id: 'Sans',
                  label: isEnglish ? 'Noto Sans' : 'ኖቶ ሳንስ',
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
                const SizedBox(width: 8),
                _buildFontChip(
                  id: 'Abyssinica',
                  label: isEnglish ? 'Abyssinica' : 'አቢሲኒካ',
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Orthodox Cross Watermark Selector
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

            // 5. Aspect Ratio & Haräg Border Toggles
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
            const SizedBox(height: 14),

            // Authentic Manuscript Options: Ge'ez Numerals & Sacred Rubrication
            _buildSectionTitle(
              isEnglish ? 'Manuscript Heritage Options:' : 'የብራና ቅርስ አማራጮች፦',
              isEnglish,
              themeConfig,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    selected: _useGeezNumerals,
                    backgroundColor: themeConfig.surfaceColor,
                    selectedColor: themeConfig.accentColor.withValues(alpha: 0.18),
                    checkmarkColor: themeConfig.accentColor,
                    avatar: Icon(Icons.pin_outlined, size: 16, color: themeConfig.accentColor),
                    label: Text(
                      isEnglish ? "Ge'ez Numeral (፫፥፲፮)" : 'ግዕዝ ቁጥር (፫፥፲፮)',
                      style: isEnglish
                          ? GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor)
                          : GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor),
                    ),
                    onSelected: (val) => setState(() => _useGeezNumerals = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    selected: _useRubrication,
                    backgroundColor: themeConfig.surfaceColor,
                    selectedColor: const Color(0xFFDC2626).withValues(alpha: 0.18),
                    checkmarkColor: const Color(0xFFDC2626),
                    avatar: const Icon(Icons.format_color_text_rounded, size: 16, color: Color(0xFFDC2626)),
                    label: Text(
                      isEnglish ? 'Rubrication (Red Ink)' : 'ቀይ ጽሕፈት (ቀይ ቀለም)',
                      style: isEnglish
                          ? GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor)
                          : GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w700, color: themeConfig.textColor),
                    ),
                    onSelected: (val) => setState(() => _useRubrication = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 6. Text Alignment & Font Size Controls
            _buildSectionTitle(isEnglish ? 'Text Alignment & Size:' : 'አቀማመጥና መጠን፦', isEnglish, themeConfig),
            const SizedBox(height: 8),
            Row(
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
                const SizedBox(width: 10),
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

  Widget _buildFontChip({
    required String id,
    required String label,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _fontFamily == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _fontFamily = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : themeConfig.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : themeConfig.textColor,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : themeConfig.textColor,
                    ),
            ),
          ),
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
