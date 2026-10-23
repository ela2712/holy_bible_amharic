import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test vertical scroll with onScale', (tester) async {
    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onScaleUpdate: (details) {},
            child: ListView.builder(
              controller: scrollController,
              itemCount: 100,
              itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      ),
    );

    // Test normal vertical drag scroll
    await tester.drag(find.text('Item 0'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0), reason: 'ListView should still scroll vertically');
  });

  testWidgets('Test nested GestureDetector: Outer onHorizontalDragEnd + Inner onScale', (tester) async {
    bool nextChapterCalled = false;
    double fontSize = 18.0;
    double baseFontSize = 18.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                nextChapterCalled = true;
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (details) {
                baseFontSize = fontSize;
              },
              onScaleUpdate: (details) {
                if (details.pointerCount >= 2) {
                  final newSize = (baseFontSize * details.scale).clamp(13.0, 36.0);
                  fontSize = newSize;
                }
              },
              child: Center(child: Text('Scripture Text', style: TextStyle(fontSize: fontSize))),
            ),
          ),
        ),
      ),
    );

    // Perform horizontal swipe
    await tester.fling(find.text('Scripture Text'), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(nextChapterCalled, isTrue, reason: 'Outer onHorizontalDragEnd should trigger on swipe');
  });
}
