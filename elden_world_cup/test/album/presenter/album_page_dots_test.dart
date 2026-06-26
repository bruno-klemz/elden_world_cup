import 'package:elden_world_cup/album/presenter/album/widgets/album_page_dots.dart';
import 'package:elden_world_cup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders one dot per region with the current one highlighted',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AlbumPageDots(count: 4, currentIndex: 2),
      ),
    ));

    // 4 animated dots
    final dots = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer));
    expect(dots.length, 4);

    // the active dot uses the gold color
    final active = dots.elementAt(2);
    final decoration = active.decoration as BoxDecoration;
    expect(decoration.color, AppColors.gold);
  });
}
