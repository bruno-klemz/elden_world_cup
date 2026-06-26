import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entity/album_data.dart';
import '../../domain/entity/boss.dart';
import '../../domain/entity/region.dart';
import '../../domain/repository/boss_repository.dart';

class BossRepositoryImpl implements BossRepository {
  final Future<String> Function(String path) _loader;

  BossRepositoryImpl() : _loader = rootBundle.loadString;
  BossRepositoryImpl.withLoader(this._loader);

  @override
  Future<AlbumData> load() async {
    final raw = await _loader('assets/bosses.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final regions = (map['regions'] as List)
        .map((e) => Region.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final bosses = (map['bosses'] as List)
        .map((e) => Boss.fromJson(e as Map<String, dynamic>))
        .toList();
    return AlbumData(regions: regions, bosses: bosses);
  }
}
