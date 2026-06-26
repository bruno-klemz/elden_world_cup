import '../entity/progress.dart';
import '../repository/progress_repository.dart';

abstract class LoadProgressUsecase {
  Future<Progress> call();
}

class LoadProgressUsecaseImpl implements LoadProgressUsecase {
  final ProgressRepository _repository;

  LoadProgressUsecaseImpl({required ProgressRepository repository})
      : _repository = repository;

  @override
  Future<Progress> call() => _repository.load();
}
