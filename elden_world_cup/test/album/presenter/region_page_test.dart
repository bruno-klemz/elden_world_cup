import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/presenter/album/widgets/region_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _region = Region(id: 'limgrave', name: 'Limgrave', order: 1);
const _bosses = [
  Boss(
      id: 'margit',
      name: 'Margit',
      region: 'limgrave',
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: MapCoord(0.1, 0.2),
      lore: 'l'),
];

void main() {
  testWidgets('shows region name, progress and boss slot', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RegionPage(
          region: _region,
          bosses: _bosses,
          defeatedCount: 0,
          isDefeated: (_) => false,
          onBossTap: (_) {},
          onQuickDefeat: (_) {},
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('Limgrave'), findsOneWidget);
    expect(find.text('0 de 1 derrotados'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
  });

  testWidgets('tapping a slot fires onBossTap', (tester) async {
    Boss? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RegionPage(
          region: _region,
          bosses: _bosses,
          defeatedCount: 0,
          isDefeated: (_) => false,
          onBossTap: (b) => tapped = b,
          onQuickDefeat: (_) {},
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('MARGIT'));
    expect(tapped?.id, 'margit');
  });
}
