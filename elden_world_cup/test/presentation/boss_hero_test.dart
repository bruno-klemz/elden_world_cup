import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/boss/widgets/boss_hero.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', subtitle: 'Boss opcional',
  region: 'haligtree', art: 'images/malenia.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('pending shows "Derrote para revelar"', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: false)));
    expect(find.textContaining('Derrote para revelar'), findsOneWidget);
    expect(find.text('Malenia'), findsOneWidget);
  });

  testWidgets('defeated does not show the reveal hint', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: true)));
    expect(find.textContaining('Derrote para revelar'), findsNothing);
  });
}
