import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/domain/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save then load round-trips defeated and revealedMap', () async {
    final store = ProgressStore();
    final p = const Progress(defeated: {'malenia'}, revealedMap: {'godrick'});

    await store.save(p);
    final loaded = await store.load();

    expect(loaded.isDefeated('malenia'), isTrue);
    expect(loaded.isMapRevealed('godrick'), isTrue);
    expect(loaded.isDefeated('godrick'), isFalse);
  });

  test('load on empty prefs returns empty progress', () async {
    final loaded = await ProgressStore().load();
    expect(loaded.defeated, isEmpty);
    expect(loaded.revealedMap, isEmpty);
  });
}
