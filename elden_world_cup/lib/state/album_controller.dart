import 'package:flutter/foundation.dart';
import '../data/boss_repository.dart';
import '../data/progress_store.dart';
import '../domain/models/album_data.dart';
import '../domain/models/region.dart';
import '../domain/progress.dart';

class AlbumController extends ChangeNotifier {
  AlbumController({required BossRepository repo, required ProgressStore store})
      : _repo = repo,
        _store = store;

  final BossRepository _repo;
  final ProgressStore _store;

  AlbumData? _data;
  Progress _progress = const Progress();

  bool get isLoaded => _data != null;
  AlbumData get data => _data!;
  List<Region> get regions => _data!.regions;

  int get totalBosses => _data!.bosses.length;
  int get totalDefeated => _progress.defeated.length;

  int countIn(String regionId) => _data!.bossesIn(regionId).length;
  int defeatedIn(String regionId) =>
      _progress.defeatedCountIn(_data!.bossesIn(regionId).map((b) => b.id));

  bool isDefeated(String id) => _progress.isDefeated(id);
  bool isMapRevealed(String id) => _progress.isMapRevealed(id);

  Future<void> init() async {
    _data = await _repo.load();
    _progress = await _store.load();
    notifyListeners();
  }

  Future<void> toggleDefeated(String id) =>
      _apply(_progress.toggleDefeated(id));
  Future<void> revealMap(String id) => _apply(_progress.revealMap(id));
  Future<void> hideMap(String id) => _apply(_progress.hideMap(id));

  Future<void> _apply(Progress next) async {
    _progress = next;
    notifyListeners();
    await _store.save(next);
  }
}
