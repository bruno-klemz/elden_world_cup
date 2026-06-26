import '../entity/progress.dart';

/// Contract for reading/writing the user's progress. Impl in the data layer.
abstract class ProgressRepository {
  Future<Progress> load();
  Future<void> save(Progress progress);
}
