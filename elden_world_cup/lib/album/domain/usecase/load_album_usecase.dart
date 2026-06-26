import '../entity/album_data.dart';
import '../repository/boss_repository.dart';

abstract class LoadAlbumUsecase {
  Future<AlbumData> call();
}

class LoadAlbumUsecaseImpl implements LoadAlbumUsecase {
  final BossRepository _repository;

  LoadAlbumUsecaseImpl({required BossRepository repository})
      : _repository = repository;

  @override
  Future<AlbumData> call() => _repository.load();
}
