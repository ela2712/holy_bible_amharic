import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VerseCardMakerScreen extends StatefulWidget {
  final String reference;
  final String verseText;

  const VerseCardMakerScreen({
    super.key,
    required this.reference,
    required this.verseText,
  });

  @override
  State<VerseCardMakerScreen> createState() => _VerseCardMakerScreenState();
}

class _VerseCardMakerScreenState extends State<VerseCardMakerScreen> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedGradientIndex = 0;
  double _fontSize = 20.0;
  TextAlign _alignment = TextAlign.center;
  bool _isGenerating = false;

  static const List<List<Color>> _backgroundGradients = [
    // Parchment / Gold
    [Color(0xFF2C1B0B), Color(0xFF6B4226)],
    // Deep Ethiopian Royal Crimson
    [Color(0xFF3E0A10), Color(0xFF8B1E2B)],
    // Midnight Royal Blue
    [Color(0xFF0D1B2A), Color(0xFF1B263B)],
    // Forest Emerald
    [Color(0xFF0F2B1D), Color(0xFF1F4E38)],
    // Sunset Warmth
    [Color(0xFF4A192C), Color(0xFF8C3A50)],
    // True Black & Charcoal
    [Color(0xFF111111), Color(0xFF222222)],
  ];

  Future<void> _captureAndShare() async {
    setState(() => _isGenerating = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/verse_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.reference}\n"${widget.verseText}"\n— መጽሐፍ ቅዱስ',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ምስሉን ማጋራት አልተቻለም: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የጥቅስ ምስል አዘጋጅ (Verse Card)'),
        actions: [
          IconButton(
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: 'Share Image',
            onPressed: _isGenerating ? null : _captureAndShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Preview Card with RepaintBoundary
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: 340,
                  height: 380,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _backgroundGradients[_selectedGradientIndex],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Icon(Icons.format_quote, color: Colors.white38, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.verseText,
                            textAlign: _alignment,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.reference,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD54F), // Gold accent
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'መጽሐፍ ቅዱስ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Background Palette Chooser
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('የጀርባ ቀለም (Card Background):', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _backgroundGradients.length,
                itemBuilder: (context, idx) {
                  final isSelected = _selectedGradientIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGradientIndex = idx),
                    child: Container(
                      width: 44,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: _backgroundGradients[idx]),
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Font Size Slider
            Row(
              children: [
                const Icon(Icons.format_size),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 14.0,
                    max: 28.0,
                    divisions: 14,
                    label: '${_fontSize.toInt()}',
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                ),
                Text('${_fontSize.toInt()}sp'),
              ],
            ),

            // Text Alignment Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  color: _alignment == TextAlign.left ? Colors.amber : null,
                  onPressed: () => setState(() => _alignment = TextAlign.left),
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_center),
                  color: _alignment == TextAlign.center ? Colors.amber : null,
                  onPressed: () => setState(() => _alignment = TextAlign.center),
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_right),
                  color: _alignment == TextAlign.right ? Colors.amber : null,
                  onPressed: () => setState(() => _alignment = TextAlign.right),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isGenerating ? null : _captureAndShare,
              icon: const Icon(Icons.share),
              label: const Text('ምስሉን አጋራ (Share Verse Card)', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
