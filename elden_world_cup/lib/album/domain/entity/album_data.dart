import 'boss.dart';
import 'region.dart';

class AlbumData {
  final List<Region> regions;
  final List<Boss> bosses;
  const AlbumData({required this.regions, required this.bosses});

  List<Boss> bossesIn(String regionId) =>
      bosses.where((b) => b.region == regionId).toList();

  Boss bossById(String id) => bosses.firstWhere((b) => b.id == id);
}
