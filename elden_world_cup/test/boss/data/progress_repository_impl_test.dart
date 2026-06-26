import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/boss/data/repository/progress_repository_impl.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save then load round-trips defeated and revealedMap', () async {
    final repo = ProgressRepositoryImpl();
    final p = const Progress(defeated: {'malenia'}, revealedMap: {'godrick'});

    await repo.save(p);
    final loaded = await repo.load();

    expect(loaded.isDefeated('malenia'), isTrue);
    expect(loaded.isMapRevealed('godrick'), isTrue);
    expect(loaded.isDefeated('godrick'), isFalse);
  });

  test('load on empty prefs returns empty progress', () async {
    final loaded = await ProgressRepositoryImpl().load();
    expect(loaded.defeated, isEmpty);
    expect(loaded.revealedMap, isEmpty);
  });
}
