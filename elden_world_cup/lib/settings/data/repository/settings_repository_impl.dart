import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entity/settings.dart';
import '../../domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _kBlurPending = 'blurPending';

  @override
  Future<Settings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Settings(blurPending: prefs.getBool(_kBlurPending) ?? true);
  }

  @override
  Future<void> save(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBlurPending, settings.blurPending);
  }
}
