import '../entity/progress.dart';
import '../repository/progress_repository.dart';

/// Reveals or hides a boss's map on the given progress, persists, and returns
/// the updated progress.
abstract class SetMapRevealedUsecase {
  Future<Progress> call(Progress current, String bossId, {required bool revealed});
}

class SetMapRevealedUsecaseImpl implements SetMapRevealedUsecase {
  final ProgressRepository _repository;

  SetMapRevealedUsecaseImpl({required ProgressRepository repository})
      : _repository = repository;

  @override
  Future<Progress> call(Progress current, String bossId,
      {required bool revealed}) async {
    final next =
        revealed ? current.revealMap(bossId) : current.hideMap(bossId);
    await _repository.save(next);
    return next;
  }
}
