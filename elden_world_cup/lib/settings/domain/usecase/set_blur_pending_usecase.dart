import '../entity/settings.dart';
import '../repository/settings_repository.dart';

/// Persists the blur-pending preference and returns the updated settings.
abstract class SetBlurPendingUsecase {
  Future<Settings> call({required bool blurPending});
}

class SetBlurPendingUsecaseImpl implements SetBlurPendingUsecase {
  final SettingsRepository _repository;

  SetBlurPendingUsecaseImpl({required SettingsRepository repository})
      : _repository = repository;

  @override
  Future<Settings> call({required bool blurPending}) async {
    final next = Settings(blurPending: blurPending);
    await _repository.save(next);
    return next;
  }
}
