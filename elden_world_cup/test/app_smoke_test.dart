import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';
import 'package:elden_world_cup/presentation/album/album_screen.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[{"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
   "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app boots into album with content', (tester) async {
    final c = AlbumController(
        repo: BossRepository.withLoader((_) async => _json),
        store: ProgressStore());
    await c.init();

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: c,
      child: const MaterialApp(home: AlbumScreen()),
    ));
    await tester.pump();

    expect(find.text('⚔️ Elden Album'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
  });
}
