import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/presenter/album/widgets/region_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _region = Region(id: 'limgrave', name: 'Limgrave', order: 1);

Boss _boss(String id, String name, {int mainOrder = 0}) => Boss(
      id: id,
      name: name,
      region: 'limgrave',
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0.1, 0.2),
      lore: 'l',
      mainOrder: mainOrder,
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows region name, progress and bosses', (tester) async {
    await tester.pumpWidget(_host(RegionPage(
      region: _region,
      mainBosses: const [],
      otherBosses: [_boss('margit', 'Margit')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('Limgrave'), findsOneWidget);
    expect(find.text('0 de 1 derrotados'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
  });

  testWidgets('renders the main-boss section when there are main bosses',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(RegionPage(
      region: _region,
      mainBosses: [_boss('godrick', 'Godrick', mainOrder: 1)],
      otherBosses: [_boss('agheel', 'Agheel')],
      defeatedCount: 0,
      totalCount: 2,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('★ Chefes principais'), findsOneWidget);
    expect(find.text('Demais chefes'), findsOneWidget);
    expect(find.text('GODRICK'), findsOneWidget);
    expect(find.text('AGHEEL'), findsOneWidget);
  });

  testWidgets('no main section when there are no main bosses', (tester) async {
    await tester.pumpWidget(_host(RegionPage(
      region: _region,
      mainBosses: const [],
      otherBosses: [_boss('agheel', 'Agheel')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('★ Chefes principais'), findsNothing);
    expect(find.text('Chefes'), findsOneWidget);
  });

  testWidgets('tapping a slot fires onBossTap', (tester) async {
    Boss? tapped;
    await tester.pumpWidget(_host(RegionPage(
      region: _region,
      mainBosses: const [],
      otherBosses: [_boss('margit', 'Margit')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (b) => tapped = b,
      onQuickDefeat: (_) {},
    )));
    await tester.pump();
    await tester.tap(find.text('MARGIT'));
    expect(tapped?.id, 'margit');
  });
}
