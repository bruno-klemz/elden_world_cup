import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';
import 'package:elden_world_cup/presentation/boss/boss_sheet.dart';

const _json = '''
{"regions":[{"id":"haligtree","name":"Haligtree","order":1}],
 "bosses":[{"id":"malenia","name":"Malenia","subtitle":"Boss opcional",
   "region":"haligtree","art":"images/malenia.webp",
   "locationName":"Elphael","mapCoord":{"x":0.6,"y":0.4},
   "strongVs":["holy"],"weakTo":["fire"],
   "loot":[{"name":"Lembrança"}],"lore":"Filha de Marika."}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sheet shows sections and toggles defeat via button',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final c = AlbumController(
        repo: BossRepository.withLoader((_) async => _json),
        store: ProgressStore());
    await c.init();
    final boss = c.data.bossById('malenia');

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: c,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => BossSheet.show(context, boss),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Filha de Marika.'), findsOneWidget);
    expect(find.text('Lembrança'), findsOneWidget);
    expect(find.text('MAIS FORTE VS'), findsOneWidget);
    expect(find.text('👁 Revelar mapa'), findsOneWidget);

    expect(find.text('⚔️ Marcar como derrotado'), findsOneWidget);
    await tester.tap(find.text('⚔️ Marcar como derrotado'));
    await tester.pumpAndSettle();

    expect(c.isDefeated('malenia'), isTrue);
    expect(find.text('✓ Conquista registrada'), findsOneWidget);
  });
}
