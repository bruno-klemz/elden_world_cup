import '../entity/progress.dart';
import '../repository/progress_repository.dart';

/// Toggles a boss's defeated state on the given progress, persists, and returns
/// the updated progress.
abstract class ToggleDefeatedUsecase {
  Future<Progress> call(Progress current, String bossId);
}

class ToggleDefeatedUsecaseImpl implements ToggleDefeatedUsecase {
  final ProgressRepository _repository;

  ToggleDefeatedUsecaseImpl({required ProgressRepository repository})
      : _repository = repository;

  @override
  Future<Progress> call(Progress current, String bossId) async {
    final next = current.toggleDefeated(bossId);
    await _repository.save(next);
    return next;
  }
}
