import 'package:elden_world_cup/app/mobile_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const childKey = Key('child');
  final child = Container(key: childKey);

  group('MobileFrame', () {
    testWidgets('on web, constrains the child to phone width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MobileFrame(isWeb: true, child: child)),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(ConstrainedBox),
        ).first,
      );

      expect(constrained.constraints.maxWidth, MobileFrame.maxWidth);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('on native, returns the child without a width limit',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MobileFrame(isWeb: false, child: child)),
      );

      // The frame itself adds no ConstrainedBox around the child on native.
      expect(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(ConstrainedBox),
        ),
        findsNothing,
      );
      expect(find.byKey(childKey), findsOneWidget);
    });
  });
}
