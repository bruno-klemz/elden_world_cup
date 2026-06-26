import 'package:elden_world_cup/album/presenter/search/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows rounded percentage', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: ProgressRing(progress: 0.21))),
    ));
    expect(find.text('21%'), findsOneWidget);
  });

  testWidgets('clamps and rounds to 100%', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: ProgressRing(progress: 1.5))),
    ));
    expect(find.text('100%'), findsOneWidget);
  });
}
