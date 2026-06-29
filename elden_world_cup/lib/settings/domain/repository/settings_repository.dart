import '../entity/settings.dart';

/// Contract for reading/writing display settings. Impl in the data layer.
abstract class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);
}
