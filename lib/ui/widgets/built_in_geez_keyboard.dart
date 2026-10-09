import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuiltInGeezKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSearchOrSubmit;

  const BuiltInGeezKeyboard({
    super.key,
    required this.controller,
    this.onSearchOrSubmit,
  });

  @override
  State<BuiltInGeezKeyboard> createState() => _BuiltInGeezKeyboardState();
}

class _BuiltInGeezKeyboardState extends State<BuiltInGeezKeyboard> {
  String? _activeFamily;
  List<String> _currentVowels = [];

  // 7 orders for each Ethiopic base letter
  static const Map<String, List<String>> _geezFamilies = {
    'ሀ': ['ሀ', 'ሁ', 'ሂ', 'ሃ', 'ሄ', 'ህ', 'ሆ'],
    'ለ': ['ለ', 'ሉ', 'ሊ', 'ላ', 'ሌ', 'ል', 'ሎ'],
    'ሐ': ['ሐ', 'ሑ', 'ሒ', 'ሓ', 'ሔ', 'ሕ', 'ሖ'],
    'መ': ['መ', 'ሙ', 'ሚ', 'ማ', 'ሜ', 'ም', 'ሞ'],
    'ሠ': ['ሠ', 'ሡ', 'ሢ', 'ሣ', 'ሤ', 'ሥ', 'ሦ'],
    'ረ': ['ረ', 'ሩ', 'ሪ', 'ራ', 'ሬ', 'ር', 'ሮ'],
    'ሰ': ['ሰ', 'ሱ', 'ሲ', 'ሳ', 'ሴ', 'ስ', 'ሶ'],
    'ሸ': ['ሸ', 'ሹ', 'ሺ', 'ሻ', 'ሼ', 'ሽ', 'ሾ'],
    'ቀ': ['ቀ', 'ቁ', 'ቂ', 'ቃ', 'ቄ', 'ቅ', 'ቆ'],
    'በ': ['በ', 'ቡ', 'ቢ', 'ባ', 'ቤ', 'ብ', 'ቦ'],
    'ተ': ['ተ', 'ቱ', 'ቲ', 'ታ', 'ቴ', 'ት', 'ቶ'],
    'ቸ': ['ቸ', 'ቹ', 'ቺ', 'ቻ', 'ቼ', 'ች', 'ቾ'],
    'ኀ': ['ኀ', 'ኁ', 'ኂ', 'ኃ', 'ኄ', 'ኅ', 'ኆ'],
    'ነ': ['ነ', 'ኑ', 'ኒ', 'ና', 'ኔ', 'ን', 'ኖ'],
    'ኘ': ['ኘ', 'ኙ', 'ኚ', 'ኛ', 'ኜ', 'ኝ', 'ኞ'],
    'አ': ['አ', 'ኡ', 'ኢ', 'ኣ', 'ኤ', 'እ', 'ኦ'],
    'ከ': ['ከ', 'ኩ', 'ኪ', 'ካ', 'ኬ', 'ክ', 'ኮ'],
    'ኸ': ['ኸ', 'ኹ', 'ኺ', 'ኻ', 'ኼ', 'ኽ', 'ኾ'],
    'ወ': ['ወ', 'ዉ', 'ዊ', 'ዋ', 'ዌ', 'ው', 'ዎ'],
    'ዐ': ['ዐ', 'ዑ', 'ዒ', 'ዓ', 'ዔ', 'ዕ', 'ዖ'],
    'ዘ': ['ዘ', 'ዙ', 'ዚ', 'ዛ', 'ዜ', 'ዝ', 'ዞ'],
    'ዠ': ['ዠ', 'ዡ', 'ዢ', 'ዣ', 'ዤ', 'ዥ', 'ዦ'],
    'የ': ['የ', 'ዩ', 'ዪ', 'ያ', 'ዬ', 'ይ', 'ዮ'],
    'ደ': ['ደ', 'ዱ', 'ዲ', 'ዳ', 'ዴ', 'ድ', 'ዶ'],
    'ጀ': ['ጀ', 'ጁ', 'ጂ', 'ጃ', 'ጄ', 'ጅ', 'ጆ'],
    'ገ': ['ገ', 'ጉ', 'ጊ', 'ጋ', 'ጌ', 'ግ', 'ጎ'],
    'ጠ': ['ጠ', 'ጡ', 'ጢ', 'ጣ', 'ጤ', 'ጥ', 'ጦ'],
    'ጨ': ['ጨ', 'ጩ', 'ጪ', 'ጫ', 'ጬ', 'ጭ', 'ጮ'],
    'ጰ': ['ጰ', 'ጱ', 'ጲ', 'ጳ', 'ጴ', 'ጵ', 'ጶ'],
    'ጸ': ['ጸ', 'ጹ', 'ጺ', 'ጻ', 'ጼ', 'ጽ', 'ጾ'],
    'ፀ': ['ፀ', 'ፁ', 'ፂ', 'ፃ', 'ፄ', 'ፅ', 'ፆ'],
    'ፈ': ['ፈ', 'ፉ', 'ፊ', 'ፋ', 'ፌ', 'ፍ', 'ፎ'],
    'ፐ': ['ፐ', 'ፑ', 'ፒ', 'ፓ', 'ፔ', 'ፕ', 'ፖ'],
  };

  void _insertChar(String char) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(
      selection.start >= 0 ? selection.start : text.length,
      selection.end >= 0 ? selection.end : text.length,
      char,
    );
    final cursorIndex = (selection.start >= 0 ? selection.start : text.length) + char.length;
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorIndex),
    );
  }

  void _backspace() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    if (text.isEmpty) return;

    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.start, '');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    } else if (selection.start != selection.end) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
  }

  void _onBaseKeyPressed(String base) {
    setState(() {
      _activeFamily = base;
      _currentVowels = _geezFamilies[base] ?? [base];
    });
  }

  void _onVowelSelected(String vowel) {
    _insertChar(vowel);
    setState(() {
      _activeFamily = null;
      _currentVowels = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Sub-vowel popup bar when a base consonant is tapped
          if (_activeFamily != null)
            Container(
              height: 48,
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _currentVowels.map((v) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isDark ? const Color(0xFF424242) : Colors.white,
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _onVowelSelected(v),
                        child: Text(
                          v,
                          style: GoogleFonts.notoSansEthiopic(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Main Consonants Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: _geezFamilies.keys.length,
                itemBuilder: (context, index) {
                  final base = _geezFamilies.keys.elementAt(index);
                  final isSelected = _activeFamily == base;
                  return InkWell(
                    onTap: () => _onBaseKeyPressed(base),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? const Color(0xFF2E2E2E) : Colors.white),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        base,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Action row: Space, Punctuation, Backspace, Search
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'ቃል መለያ (፡)',
                  onPressed: () => _insertChar('፡'),
                  icon: const Text('፡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  tooltip: 'አረፍተ ነገር (።)',
                  onPressed: () => _insertChar('።'),
                  icon: const Text('።', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF383838) : Colors.white,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _insertChar(' '),
                    child: const Text('Space (ክፍተት)'),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Backspace',
                  onPressed: _backspace,
                  icon: const Icon(Icons.backspace_outlined),
                ),
                if (widget.onSearchOrSubmit != null)
                  IconButton(
                    tooltip: 'Search / ፈልግ',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onSearchOrSubmit,
                    icon: const Icon(Icons.search),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
