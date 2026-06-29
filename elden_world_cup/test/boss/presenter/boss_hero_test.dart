import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/boss/presenter/boss_details/widgets/boss_hero.dart';

import '../../support/settings_bloc_harness.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', subtitle: 'Boss opcional',
  region: 'haligtree', art: 'images/malenia.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget c) =>
    MaterialApp(home: Scaffold(body: withSettings(c)));

void main() {
  testWidgets('shows boss name in both states', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: false)));
    expect(find.text('Malenia'), findsOneWidget);

    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: true)));
    expect(find.text('Malenia'), findsOneWidget);
  });

  testWidgets('does not render a redundant reveal hint', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: false)));
    expect(find.textContaining('Derrote para revelar'), findsNothing);
  });
}
