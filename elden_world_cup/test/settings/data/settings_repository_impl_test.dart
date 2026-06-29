import 'package:elden_world_cup/settings/data/repository/settings_repository_impl.dart';
import 'package:elden_world_cup/settings/domain/entity/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save then load round-trips blurPending', () async {
    final repo = SettingsRepositoryImpl();

    await repo.save(const Settings(blurPending: false));
    final loaded = await repo.load();

    expect(loaded.blurPending, isFalse);
  });

  test('load on empty prefs defaults blurPending to true', () async {
    final loaded = await SettingsRepositoryImpl().load();
    expect(loaded.blurPending, isTrue);
  });
}
