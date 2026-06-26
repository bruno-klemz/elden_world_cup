import 'package:elden_world_cup/album/presenter/album/widgets/album_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows current/total region position (1-based)', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AlbumPageIndicator(count: 7, currentIndex: 2),
      ),
    ));

    // currentIndex 2 (0-based) -> "3 / 7"
    final text = tester.widget<Text>(find.byType(Text));
    final shown = text.textSpan!.toPlainText();
    expect(shown, '3 / 7');
  });
}
