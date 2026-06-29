import '../entity/settings.dart';
import '../repository/settings_repository.dart';

abstract class LoadSettingsUsecase {
  Future<Settings> call();
}

class LoadSettingsUsecaseImpl implements LoadSettingsUsecase {
  final SettingsRepository _repository;

  LoadSettingsUsecaseImpl({required SettingsRepository repository})
      : _repository = repository;

  @override
  Future<Settings> call() => _repository.load();
}
