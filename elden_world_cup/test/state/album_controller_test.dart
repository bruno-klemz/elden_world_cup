import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[
   {"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
    "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"},
   {"id":"godrick","name":"Godrick","region":"limgrave","art":"a.webp",
    "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

AlbumController _make() => AlbumController(
      repo: BossRepository.withLoader((_) async => _json),
      store: ProgressStore(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('init loads data and starts empty', () async {
    final c = _make();
    await c.init();
    expect(c.isLoaded, isTrue);
    expect(c.totalBosses, 2);
    expect(c.totalDefeated, 0);
    expect(c.countIn('limgrave'), 2);
  });

  test('toggleDefeated updates counts and persists', () async {
    final c = _make();
    await c.init();
    await c.toggleDefeated('margit');
    expect(c.isDefeated('margit'), isTrue);
    expect(c.totalDefeated, 1);
    expect(c.defeatedIn('limgrave'), 1);

    final c2 = _make();
    await c2.init();
    expect(c2.isDefeated('margit'), isTrue);
  });

  test('defeated boss is map-revealed', () async {
    final c = _make();
    await c.init();
    await c.toggleDefeated('margit');
    expect(c.isMapRevealed('margit'), isTrue);
  });
}
