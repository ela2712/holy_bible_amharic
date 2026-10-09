import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holy_bible_amharic/main.dart';

void main() {
  testWidgets('HolyBibleApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HolyBibleApp(),
      ),
    );
    expect(find.byType(HolyBibleApp), findsOneWidget);
  });
}
