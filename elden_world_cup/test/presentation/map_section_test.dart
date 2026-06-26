import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/boss/widgets/map_section.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', region: 'haligtree',
  art: 'images/malenia.webp', locationName: 'Elphael, Braço da Haligtree',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('locked state shows reveal button and hides location',
      (tester) async {
    var revealed = false;
    await tester.pumpWidget(_host(MapSection(
      boss: _boss, revealed: false,
      onReveal: () => revealed = true, onHide: () {}, onOpenFullscreen: () {},
    )));
    expect(find.text('👁 Revelar mapa'), findsOneWidget);
    expect(find.text('Elphael, Braço da Haligtree'), findsNothing);

    await tester.tap(find.text('👁 Revelar mapa'));
    expect(revealed, isTrue);
  });

  testWidgets('revealed state shows location and amplify control',
      (tester) async {
    await tester.pumpWidget(_host(MapSection(
      boss: _boss, revealed: true,
      onReveal: () {}, onHide: () {}, onOpenFullscreen: () {},
    )));
    expect(find.text('Elphael, Braço da Haligtree'), findsOneWidget);
    expect(find.textContaining('Ampliar'), findsOneWidget);
  });
}
