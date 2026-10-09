import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPlansScreen extends StatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  State<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends State<ReadingPlansScreen> {
  final Set<int> _completedCanonicalDays = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('plan_canonical_completed') ?? [];

    setState(() {
      _completedCanonicalDays.addAll(completed.map((e) => int.tryParse(e) ?? 0));
    });
  }

  Future<void> _toggleDayComplete(int day) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_completedCanonicalDays.contains(day)) {
        _completedCanonicalDays.remove(day);
      } else {
        _completedCanonicalDays.add(day);
      }
    });
    await prefs.setStringList(
      'plan_canonical_completed',
      _completedCanonicalDays.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('የንባብ ዕቅዶች (Reading Plans)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'መጽሐፍ ቅዱስን በዓመት አንብበው ይጨርሱ',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ዕለታዊ የ3 ምዕራፍ ንባብ በማድረግ በ365 ቀናት ውስጥ መጽሐፍ ቅዱስን ሙሉ በሙሉ ማንበብ ይችላሉ።',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      height: 1.5,
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _completedCanonicalDays.length / 365,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_completedCanonicalDays.length} / 365 ቀናት ተጠናቀዋል (${((_completedCanonicalDays.length / 365) * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'የ365 ቀናት ዝርዝር (Daily Schedule)',
            style: GoogleFonts.notoSansEthiopic(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Daily list (all 365 days)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 365,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isCompleted = _completedCanonicalDays.contains(day);

              final startChapter = (day - 1) * 3 + 1;
              final endChapter = day * 3;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted
                        ? Colors.green
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: isCompleted
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 20)
                        : Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    'ቀን $day — ምዕራፍ $startChapter - $endChapter',
                    style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleDayComplete(day),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
