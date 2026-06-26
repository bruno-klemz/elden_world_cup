import '../entity/album_data.dart';

/// Contract for loading boss/region content. Implemented in the data layer.
abstract class BossRepository {
  Future<AlbumData> load();
}
