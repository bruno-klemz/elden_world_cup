import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/models/album_data.dart';
import '../domain/models/boss.dart';
import '../domain/models/region.dart';

class BossRepository {
  final Future<String> Function(String path) _loader;

  BossRepository() : _loader = rootBundle.loadString;
  BossRepository.withLoader(this._loader);

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
