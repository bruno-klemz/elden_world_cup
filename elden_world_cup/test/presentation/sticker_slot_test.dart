import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/album/widgets/sticker_slot.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', region: 'haligtree',
  art: 'images/malenia.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows name in both states', (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () {})));
    expect(find.text('MALENIA'), findsOneWidget);
  });

  testWidgets('defeated shows check badge, pending does not', (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, onTap: () {})));
    expect(find.byKey(const Key('slot-check')), findsOneWidget);

    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () {})));
    expect(find.byKey(const Key('slot-check')), findsNothing);
  });

  testWidgets('tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () => tapped = true)));
    await tester.tap(find.byType(StickerSlot));
    expect(tapped, isTrue);
  });
}
