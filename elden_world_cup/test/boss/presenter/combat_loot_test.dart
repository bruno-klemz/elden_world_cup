import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/album/domain/entity/damage_type.dart';
import 'package:elden_world_cup/album/domain/entity/loot_item.dart';
import 'package:elden_world_cup/boss/presenter/boss_details/widgets/combat_section.dart';
import 'package:elden_world_cup/boss/presenter/boss_details/widgets/loot_section.dart';

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('combat shows both columns and damage labels', (tester) async {
    await tester.pumpWidget(_host(const CombatSection(
      strongVs: [DamageType.holy],
      weakTo: [DamageType.fire],
    )));
    expect(find.text('MAIS FORTE VS'), findsOneWidget);
    expect(find.text('MAIS FRACO PARA'), findsOneWidget);
    expect(find.text('Sagrado'), findsOneWidget);
    expect(find.text('Fogo'), findsOneWidget);
  });

  testWidgets('loot lists each item name', (tester) async {
    await tester.pumpWidget(_host(const LootSection(
      loot: [LootItem(name: 'Lembrança'), LootItem(name: 'Grande Runa')],
    )));
    expect(find.text('Lembrança'), findsOneWidget);
    expect(find.text('Grande Runa'), findsOneWidget);
  });
}
