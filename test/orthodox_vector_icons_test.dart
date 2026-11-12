import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/data/reading_plans_data.dart';
import 'package:holy_bible_amharic/ui/widgets/modern_bible_icons.dart';

void main() {
  testWidgets('All OrthodoxVectorIcon kinds and reading plan cover icons render cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in OrthodoxIconKind.values)
                OrthodoxVectorIcon(kind: kind, size: 24, color: Colors.amber),
              for (final plan in ReadingPlansData.allPlans)
                OrthodoxVectorIcon(
                  kind: OrthodoxVectorIcon.kindForPlanCover(plan.coverIcon),
                  size: 22,
                  color: Colors.indigo,
                ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(OrthodoxVectorIcon), findsNWidgets(OrthodoxIconKind.values.length + ReadingPlansData.allPlans.length));
  });
}
